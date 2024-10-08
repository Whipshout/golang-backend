package main

import (
	"context"
	"errors"
	"net/http"
	"os"
	"os/signal"
	"time"

	"golang-backend/pkg/log"
	"golang-backend/pkg/middlewares"

	"github.com/labstack/echo-contrib/echoprometheus"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"go.uber.org/zap"
)

func main() {
	logger, err := log.NewLogger("dev", zap.DebugLevel)
	if err != nil {
		panic(err)
	}
	defer func(logger *zap.Logger) {
		if err := logger.Sync(); err != nil && err.Error() != "sync /dev/stderr: invalid argument" {
			logger.Fatal("Failed to sync logger", zap.Error(err))
		}
	}(logger)

	e := echo.New()
	e.Use(middleware.RequestID())
	e.Use(middleware.Secure())
	e.Use(middleware.Recover())
	e.Use(log.NewRequestLoggerMiddleware(logger))
	e.Use(middleware.RateLimiterWithConfig(middlewares.RateLimiterConfig()))
	e.Use(middleware.TimeoutWithConfig(middlewares.TimeoutConfig()))
	e.Use(echoprometheus.NewMiddleware("backend"))

	// To avoid random error with prometheus requesting a favicon O_O
	e.GET("/favicon.ico", func(c echo.Context) error {
		return c.NoContent(http.StatusNoContent)
	})
	e.GET("/metrics", echoprometheus.NewHandler())

	e.GET("/ping", func(c echo.Context) error {
		return c.String(http.StatusOK, "pong")
	})

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	go func() {
		if err := e.Start(":8080"); err != nil && !errors.Is(err, http.ErrServerClosed) {
			e.Logger.Fatal("shutting down the server: %d", zap.Error(err))
		}
	}()

	<-ctx.Done()

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := e.Shutdown(ctx); err != nil {
		e.Logger.Fatal(err)
	}
}
