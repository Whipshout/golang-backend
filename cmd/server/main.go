package main

import (
	"context"
	"errors"
	"net/http"
	"os"
	"os/signal"
	"time"

	"golang-backend/pkg/log"

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
