package log

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

func NewLogger(environment string, level zapcore.Level) (*zap.Logger, error) {
	config := zap.NewDevelopmentConfig()
	config.Level = zap.NewAtomicLevelAt(level)
	config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder

	logger, err := config.Build()
	if err != nil {
		return nil, err
	}

	return logger.With(zap.String("environment", environment)), nil
}

func NewRequestLoggerMiddleware(logger *zap.Logger) echo.MiddlewareFunc {
	return middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogStatus:  true,
		LogURI:     true,
		LogMethod:  true,
		LogLatency: true,
		LogValuesFunc: func(c echo.Context, v middleware.RequestLoggerValues) error {
			requestID := c.Response().Header().Get(echo.HeaderXRequestID)

			logFields := []zap.Field{
				zap.String("request_id", requestID),
				zap.String("method", v.Method),
				zap.String("uri", v.URI),
				zap.Int("status", v.Status),
				zap.Duration("latency", v.Latency),
			}

			if v.Status >= 400 {
				logger.Error("Request Error", logFields...)
			} else {
				logger.Info("Request", logFields...)
			}

			return nil
		},
	})
}
