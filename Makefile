build:
	docker-compose build

setup: build
	docker-compose run --rm app rails db:create db:migrate db:seed

test_migrate:
	docker-compose run --rm app rails db:migrate RAILS_ENV=test

serve-staging:
	docker-compose run -e RAILS_ENV=staging RACK_ENV=staging --service-ports --rm app

serve:
	rm tmp/pids/server.pid || echo ""
	docker-compose up

lint:
	docker-compose run --rm app rubocop

test:
	docker-compose run --rm app rspec

shell:
	docker-compose exec app /bin/bash

check: lint test
	echo 'Deployable!'

bundle:
	docker-compose run --rm app bundle
	make build
