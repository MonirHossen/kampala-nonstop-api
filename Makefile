.DEFAULT_GOAL := help

COMPOSE       := docker compose --env-file .env.docker
COMPOSE_DEV   := $(COMPOSE) -f docker-compose.yml
COMPOSE_PROD  := $(COMPOSE) -f docker-compose.yml -f docker-compose.prod.yml
APP_SERVICE   := app
NGINX_SERVICE := nginx
DB_SERVICE    := postgres

.PHONY: help init build up down restart logs ps shell artisan composer migrate fresh test clean prod-build prod-up prod-down

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

init: ## Copy env templates and build images
	@if [ ! -f .env ]; then cp .env.example .env && echo "Created .env from .env.example"; fi
	@if [ ! -f .env.docker ]; then cp .env.docker.example .env.docker && echo "Created .env.docker"; fi
	$(MAKE) build

build: ## Build development Docker images
	$(COMPOSE_DEV) build

up: ## Start development stack (API + PostgreSQL + Nginx)
	$(COMPOSE_DEV) up -d

down: ## Stop development stack
	$(COMPOSE_DEV) down

restart: down up ## Restart development stack

logs: ## Tail logs from all services
	$(COMPOSE_DEV) logs -f

ps: ## Show running containers
	$(COMPOSE_DEV) ps

shell: ## Open bash shell in the app container
	$(COMPOSE_DEV) exec $(APP_SERVICE) bash

artisan: ## Run artisan command (usage: make artisan cmd="route:list")
	$(COMPOSE_DEV) exec $(APP_SERVICE) php artisan $(cmd)

composer: ## Run composer command (usage: make composer cmd="require package/name")
	$(COMPOSE_DEV) exec $(APP_SERVICE) composer $(cmd)

migrate: ## Run database migrations
	$(COMPOSE_DEV) exec $(APP_SERVICE) php artisan migrate --force

fresh: ## Reset database and re-run migrations
	$(COMPOSE_DEV) exec $(APP_SERVICE) php artisan migrate:fresh --force

test: ## Run PHPUnit tests
	$(COMPOSE_DEV) exec $(APP_SERVICE) php artisan test

clean: ## Stop stack and remove volumes
	$(COMPOSE_DEV) down -v --remove-orphans

prod-build: ## Build production Docker images
	$(COMPOSE_PROD) build

prod-up: ## Start production stack
	$(COMPOSE_PROD) up -d

prod-down: ## Stop production stack
	$(COMPOSE_PROD) down
