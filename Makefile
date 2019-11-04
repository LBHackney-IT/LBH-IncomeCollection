INCOME_API_DIR  ?= ../lbh-income-api
UHSIM_DIR       ?= ../universal-housing-simulator
TENANCY_API_DIR ?= ../LBHTenancyAPI

ifneq (, $(wildcard ${INCOME_API_DIR}/.env))
-include ${INCOME_API_DIR}/.env
export
endif


.PHONY: docker-build
docker-build:
	docker-compose build

.PHONY: docker-down
docker-down:
	docker-compose down

.PHONY: bundle
bundle:
	docker-compose run --rm app bundle install

setup: docker-build

serve-staging:
	docker-compose run -e RAILS_ENV=staging RACK_ENV=staging --service-ports --rm app

serve:
	rm tmp/pids/server.pid || echo ""
	docker-compose up

lint:
	docker-compose run --rm app rubocop

test:
	docker-compose run --rm app rspec

check: lint test
	echo 'Deployable!'

run-all:
	docker build --tag managearrears .
	cd ${INCOME_API_DIR} && docker build --tag incomeapi .
	cd ${TENANCY_API_DIR} && docker build --tag tenancyapi -f ./LBHTenancyAPI/Dockerfile .
	docker-compose -f ${UHSIM_DIR}/docker-compose.service.yml \
		-f ${INCOME_API_DIR}/docker-compose.service.yml \
		-f ${TENANCY_API_DIR}/docker-compose.service.yml \
		-f docker-compose.service.yml \
		up

shell:
	docker-compose run --rm app /bin/bash

guard:
	docker-compose run --rm app guard

