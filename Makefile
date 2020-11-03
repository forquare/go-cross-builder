
user=forquare
repo=go-cross-builder

version ?= latest

latest: ## Build with latest tag
	docker build -t ${user}/${repo}:latest .

build: ## Build image (locally)
	docker build -t ${user}/${repo}:${version} -t ${user}/${repo}:latest .

build-no-cache: ## Build without cache
	docker build --no-cache -t ${user}/${repo}:${version} -t ${user}/${repo}:latest .

install: build ## Push image to Dockerhub
	docker push ${user}/${repo}:${version}
	docker push ${user}/${repo}:latest

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
