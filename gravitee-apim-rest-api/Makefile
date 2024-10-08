# -----------------------------------------------------------------------------
#                              CUSTOM FUNCTION
# -----------------------------------------------------------------------------
define prepare
	echo "preparing working $(1) directory version $(2) \n"
	mkdir -p .working/$(1)
	cp gravitee-$(1)-standalone/gravitee-$(1)-standalone-distribution/gravitee-$(1)-standalone-distribution-zip/target/graviteeio-$(1)-distribution-$(2).zip .working/$(1)
	unzip -uj .working/$(1)/graviteeio-$(1)-distribution-$(2).zip '*/config/*' -d .working/$(1)/config
	cp docker/Dockerfile-dev .working/$(1)/Dockerfile
	sed -i.bkp 's/<appender-ref ref=\"async-file\" \/>/<appender-ref ref=\"async-console\" \/>/' .working/$(1)/config/logback.xml
	sed -i.bkp 's/<appender-ref ref=\"FILE\" \/>/<appender-ref ref=\"STDOUT\" \/>/' .working/$(1)/config/logback.xml
	echo "$(1) working directory preparation is done.\n"
endef

define addNetworkToCompose
	echo "adding network $(1) to docker compose file"
	echo "" >> $(1)
	echo "" >> $(1)
	echo "networks:" >> $(1)
	echo "  default:" >> $(1)
	echo "    external:" >> $(1)
	echo "      name: $(2)" >> $(1)
endef

# -----------------------------------------------------------------------------
#                                ENV VARIABLE
# -----------------------------------------------------------------------------

# API Management release retrieved asking maven to retrieve it
GIO_APIM_VERSION:=$(shell cat .working/.version 2>/dev/null)
GIO_APIM_NETWORK:=gio_apim_network
GIO_APIM_MANAGEMENT_API_IMAGE:=graviteeio/apim-management-api
GIO_APIM_MANAGEMENT_API_PLUGINS:=gravitee-apim-rest-api-standalone/gravitee-apim-rest-api-standalone-distribution/src/main/resources/plugins/

# Retrieve current file name, must be done before doing "include .env" ...
makefile := $(MAKEFILE_LIST)
# Projects list (extracted from .env file, looking for every XXX_REPOSITORY variables)

# -----------------------------------------------------------------------------
#                                 Main targets
# -----------------------------------------------------------------------------

help: ## Print this message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

gravitee: ## Stop and delete containers if exists, then install and run new ones, you can skip test by doing : make OPTIONS=-DskipTests install
ifneq ($(wildcard .working/compose),)
	@echo "Stopping gravitee and cleaning containers and images"
	@make stop
	@make prune
else
	@echo "No previous gravitee .working/compose dir, no docker content to delete..."
	@echo "Deleting working dir"
	rm -rf .working
endif
	@make version
	@make install OPTIONS=$(OPTIONS)
	@make run

clean: # remove .working directory
	@rm -rf .working/apim-rest-api

version: # Get version and save it into a file
	@mkdir -p .working
	@rm -f .working/.version
	@echo "$(shell mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version 2> /dev/null | grep '^[0-9]\+\.[0-9]\+\.[0-9]\+.*')" > .working/.version

install: clean ## Compile, test, package then Set up working folder, you can skip test by doing : make OPTIONS=-DskipTests install
ifeq ($(GIO_APIM_VERSION),)
	@echo "Current build version is : $(GIO_APIM_VERSION)"
	@echo "no version found, retrieving current maven version"
	@make version
	@make install
else
	@echo "Current build version is : $(GIO_APIM_VERSION)"
	@mvn clean install $(OPTIONS)
	@$(foreach project,apim-rest-api, $(call prepare,$(project),$(GIO_APIM_VERSION)))
endif

build: # Build docker images (require install to be run before)
	cd .working/apim-rest-api && docker build --build-arg GRAVITEEIO_VERSION=$(GIO_APIM_VERSION) -t $(GIO_APIM_MANAGEMENT_API_IMAGE):$(GIO_APIM_VERSION) .

env: # Set up .env file for gravitee nerdctl compose
	@mkdir -p .working/compose
	@echo "GIO_APIM_VERSION=$(GIO_APIM_VERSION)" > .working/compose/.env

network: # Create and add an external network to gravitee access management nerdctl compose
	@cp docker/compose/nerdctl compose-dev.yml .working/compose/nerdctl compose.yml
	@$(call addNetworkToCompose, ".working/compose/nerdctl compose.yml",${GIO_APIM_NETWORK});
	@docker network inspect $(GIO_APIM_NETWORK) &>/dev/null || docker network create --driver bridge $(GIO_APIM_NETWORK)

run: build env network ## Create .env and network then start gravitee API management container
	@cd .working/compose; nerdctl compose up -d management_api
	@echo "To start and stop, use \"make stop; make start\" command"

start: ## Start gravitee API Management containers
ifneq ($(wildcard .working/compose),)
	@cd .working/compose; nerdctl compose start mongodb elasticsearch management_api
else
	@echo "Please use \"make run\" for the first time."
endif

startMongo: ## Start gravitee API Management mongo container only
ifneq ($(wildcard .working/compose),)
	@cd .working/compose; nerdctl compose start mongodb
else
	@echo "Please use \"make run\" for the first time."
endif

startElastic: ## Start gravitee API Management elasticsearch container only
ifneq ($(wildcard .working/compose),)
	@cd .working/compose; nerdctl compose start elasticsearch
else
	@echo "Please use \"make run\" for the first time."
endif

stop: ## Stop gravitee API Management running containers
ifneq ($(wildcard .working/compose),)
	@cd .working/compose; nerdctl compose stop || true
endif

status: ## See API Management containers status
ifneq ($(wildcard .working/compose),)
	@cd .working/compose; nerdctl compose ps
endif

connectMongo: ## Connect to mongo repository on gravitee database
	@docker exec -ti gio_apim_mongodb mongo gravitee

reset: stop deleteData start ## Stop containers, delete mongodb data and restart container

license: ## Generate license header
	@mvn license:format

ifneq ($(env),$(filter $(env), nightly demo)) # Check if environment is valid
	@echo "\033[0;31m '$(env)' is not a valid env. Please provide 'ENV=nightly|demo' or let it empty for 'localhost' testing \033[0m"
	@exit 1
endif

startAll: start ## Start all running containers

stopAll: stop ## Stop all running containers

deleteData: deleteMongoData deleteElasticData ## Remove mongodb and elasticsearch data

deleteMongoData: # remove mongodb data
	@rm -rf .working/compose/data/data-mongo

deleteElasticData: # remove mongodb data
	@rm -rf .working/compose/data/data-elasticsearch

deleteContainer: # delete container
ifneq ($(wildcard .working/compose),)
	@$(shell nerdctl compose -f .working/compose/nerdctl compose.yml down &>/dev/null || true)
endif

deleteImage: # delete image
ifneq ($(GIO_APIM_VERSION),)
	@docker rmi -f $(GIO_APIM_MANAGEMENT_API_IMAGE):$(GIO_APIM_VERSION) || true
endif

deleteNetwork: # delete network
	@$(shell docker network rm $(GIO_APIM_NETWORK) &>/dev/null || true)

prune: deleteData deleteContainer deleteImage deleteNetwork ## /!\ Erase all (repositories folder & volumes, containers, images & data)
	@rm -rf .working

.DEFAULT_GOAL := help
.PHONY: all test clean build version
