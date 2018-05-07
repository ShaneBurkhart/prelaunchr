.PHONY: db

NAME=prelaunchr
DEV_FILE=docker-compose.dev.yml

BASE_TAG=shaneburkhart/${NAME}

all: run

build:
	 docker build -t ${BASE_TAG} .
	 docker build -t ${BASE_TAG}:dev -f Dockerfile.dev .

db:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle exec rake db:migrate
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle exec rake db:seed

run:
	docker-compose -f ${DEV_FILE} -p ${NAME} up -d

up:
	docker-machine start default
	docker-machine env
	eval $(docker-machine env)

stop:
	docker-compose -f ${DEV_FILE} -p ${NAME} stop

clean:
	docker-compose -f ${DEV_FILE} -p ${NAME} down

wipe: clean
	rm -rf data
	$(MAKE) db || echo "\n\nDatabase needs a minute to start...\nWaiting 7 seconds for Postgres to start...\n\n"
	sleep 7
	$(MAKE) db

ps:
	docker-compose -f ${DEV_FILE} ps

c:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web /bin/bash

t:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle exec rspec ${FILE}

tr:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle exec rspec spec/requests

tc:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle exec rspec spec/controllers

tm:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle exec rspec spec/models

ta:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle exec rspec spec/models/*ability_spec.rb

pg:
	echo "Enter 'postgres'..."
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm pg psql -h pg -d mydb -U postgres --password

prod:
	git checkout master
	git pull origin master
	$(MAKE) build_prod
	$(MAKE) migrate_prod
	$(MAKE) run_prod

run_prod:
	docker-compose -p ${NAME} up -d

build_prod:
	 docker build -t ${BASE_TAG} .

migrate_prod:
	docker-compose -p ${NAME} run --rm web rake db:migrate

clean_prod:
	docker-compose -p ${NAME} down

c_prod:
	docker-compose run --rm web /bin/bash

logs_prod:
	docker-compose -p ${NAME} logs -f

ps_prod:
	docker-compose ps


bundle:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web bundle

logs:
	docker-compose -f ${DEV_FILE} -p ${NAME} logs -f

heroku_deploy:
	docker-compose -f ${DEV_FILE} -p ${NAME} run --rm web true
	docker cp $$(docker ps -a | grep web | head -n 1 | awk '{print $$1}'):/app/Gemfile.lock .
	git add Gemfile.lock
	git commit -m "Added Gemfile.lock for Heroku deploy."
	git push -f heroku master
	heroku run --app currentdocs rake db:migrate
	heroku restart --app currentdocs
	rm Gemfile.lock
	git rm Gemfile.lock
	git commit -m "Removed Gemfile.lock from Heroku deploy."

