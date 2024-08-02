# Build and Run the Go binary locally
.PHONY: run-local
run-local:
	@echo "Building and Running the Go binary locally..."
	@bash ./scripts/run-local.sh

# Run integration tests
.PHONY: test-integration
test-integration:
	@echo "Running integration tests..."
	@bash ./scripts/test-integration.sh

# Clean up all Docker images and containers
.PHONY: clean
clean:
	@echo "Cleaning up all Docker images and containers..."
	@bash ./scripts/clean-docker.sh

# Run dev
.PHONY: run-dev
run-dev:
	@echo "Running integration tests..."
	@bash ./scripts/run-dev.sh

# Run lint
.PHONY: lint
lint:
	@echo "Running linter..."
	@bash ./scripts/test-lint.sh

# Display help
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  run-local       	Build and Run the Go binary locally"
	@echo "  run-dev       	Build and Run using Docker"
	@echo "  test-integration   	Run integration tests using Docker"
	@echo "  clean              	Clean up all Docker images and containers"
	@echo "  lint               	Run linter"
	@echo "  help               	Display this help message"