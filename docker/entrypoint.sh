#!/bin/sh

set -e

## Prepare variables
VEDEM_ENV="${VEDEM_ENV:-}"

## Build database configuration
## FIXME: use ENV to fill configuration
cp config/database.yml.sample config/database.yml
yq d -i config/database.yml production
yq d -i config/database.yml development
yq d -i config/database.yml test

if [ "$VEDEM_ENV" = "production" ]; then
	>&2 echo "ERROR: no VEDEM_ENV implemented for production !"
	exit 1
	# TODO

elif [ "$VEDEM_ENV" = "development" ]; then
	yq w -i config/database.yml development.adapter postgresql
	yq w -i config/database.yml development.database vdmsmart
	yq w -i config/database.yml development.encoding utf8
	yq w -i config/database.yml development.username vdmsmart
	yq w -i config/database.yml development.password vdmsmart
	yq w -i config/database.yml development.host db
	yq w -i config/database.yml development.port 5432

elif [ "$VEDEM_ENV" = "test" ]; then
	yq w -i config/database.yml test.adapter postgresql
	yq w -i config/database.yml test.database vdmsmart-test
	yq w -i config/database.yml test.encoding utf8
	yq w -i config/database.yml test.username vdmsmart
	yq w -i config/database.yml test.password vdmsmart
	yq w -i config/database.yml test.host db
	yq w -i config/database.yml test.port 5432
else
	>&2 echo "ERROR: no VEDEM_ENV defined!"
	exit 1
fi


yq r config/database.yml

## Build mailer configuration
cp config/mailer.yml.sample config/mailer.yml

## Install dependencies if missing
bundle install

## Wait for database to be ready (FIXME: use ENV instead)
./docker/tcp-port-wait.sh "postgresql database" "db" "5432"

## Setup database
echo "**"
echo "* Database setup for ${VEDEM_ENV}!"
echo "**"

if [ "$VEDEM_ENV" = "production" ]; then
	>&2 echo "ERROR: no VEDEM_ENV implemented for production !"
	exit 1
	# TODO

elif [ "$VEDEM_ENV" = "development" ]; then
	CURRENT_DB_VERSION="$(bin/rails db:version 2>&1 | grep Current | sed 's/Current version: \(.*\)/\1/')"
	echo "CURRENT_DB_VERSION = [$CURRENT_DB_VERSION]"
	if [ -z "$CURRENT_DB_VERSION" ] || [ "$CURRENT_DB_VERSION" = "0" ]; then
		DB_INIT="true"
	else
		DB_INIT="false"
	fi
	if [ "$DB_INIT" = "true" ]; then
  	  bundle exec rake db:create
  	  bundle exec rake db:schema:load
  	  bundle exec rake db:seed
	fi
elif [ "$VEDEM_ENV" = "test" ]; then
	# Force init (no data is ever stored on disk)
  	bundle exec rake db:create
  	bundle exec rake db:schema:load
  	bundle exec rake db:seed
else
	>&2 echo "ERROR: no VEDEM_ENV defined!"
	exit 1
fi
bundle exec rake db:migrate

## Run app
bundle exec procodile start -f
