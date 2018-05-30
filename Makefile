build:
	docker-compose build

setup: build
	docker-compose run --rm app rails db:setup db:migrate

serve-staging:
	docker-compose run -e RAILS_ENV=staging RACK_ENV=staging --service-ports --rm app

serve:
	rm tmp/pids/server.pid || echo ""
	docker-compose up

test:
	docker-compose run --rm app rspec

bundle:
	docker-compose run --rm app bundle
	make build
