package integration

import (
	"io"
	"net/http"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestPingRoute(t *testing.T) {
	url := "http://service:8080/ping"

	resp, err := http.Get(url)

	if assert.NoError(t, err) {
		defer resp.Body.Close()

		assert.Equal(t, http.StatusOK, resp.StatusCode)

		body, err := io.ReadAll(resp.Body)
		assert.NoError(t, err)

		assert.Equal(t, "pong", string(body))
	}
}
