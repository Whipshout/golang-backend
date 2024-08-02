DOCKER_COMPOSE_FILE_TEST = docker/test/docker-compose.yml
DOCKER_COMPOSE_TEST = docker-compose -f $(DOCKER_COMPOSE_FILE_TEST)
DOCKER_COMPOSE_FILE_DEV = docker/dev/docker-compose.yml
DOCKER_COMPOSE_DEV = docker-compose -f $(DOCKER_COMPOSE_FILE_DEV)

# Build the Go binary locally
.PHONY: local-build
local-build:
	@echo "Building the Go binary locally..."
	CGO_ENABLED=0 GOOS=linux go build -o ./bin/server ./cmd/server

# Run the Go binary locally
.PHONY: local-run
local-run:
	@echo "Running the Go binary locally..."
	./bin/server

# Build and Run the Go binary locally
.PHONY: local
local: local-build local-run
	@echo "Building and Running the Go binary locally..."

# Run integration tests
.PHONY: integration-tests
integration-tests:
	@echo "Building Docker images..."
	@$(DOCKER_COMPOSE_TEST) build --no-cache
	@echo "Running integration tests..."
	@$(DOCKER_COMPOSE_TEST) up --abort-on-container-exit --exit-code-from test || (echo "Tests failed. Showing logs:" && $(DOCKER_COMPOSE_TEST) logs -t)
	@$(DOCKER_COMPOSE_TEST) down

# Clean up test Docker images and containers
.PHONY: clean-tests
clean-tests:
	@echo "Cleaning up test Docker images and containers..."
	docker-compose -f $(DOCKER_COMPOSE_FILE_TEST) down --rmi all --volumes --remove-orphans

# Clean up local Docker images and containers
.PHONY: clean-dev
clean-dev:
	@echo "Cleaning up dev Docker images and containers..."
	docker-compose -f $(DOCKER_COMPOSE_FILE_DEV) down --rmi all --volumes --remove-orphans

# Run dev
.PHONY: run-dev
run-dev:
	@echo "Running integration tests..."
	@$(DOCKER_COMPOSE_DEV) up --abort-on-container-exit
	@$(DOCKER_COMPOSE_DEV) down

# Run lint
.PHONY: lint
lint:
	@echo "Running linter..."
	golangci-lint run

# Display help
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  local-build       	Build the Go binary locally"
	@echo "  local-run       	Run the Go binary locally"
	@echo "  local       		Build and Run the Go binary locally"
	@echo "  integration-test   	Run integration tests using Docker"
	@echo "  clean              	Clean up Docker images and containers"
	@echo "  lint               	Run linter"
	@echo "  help               	Display this help message"