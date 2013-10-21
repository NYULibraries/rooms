# Graduate Collaborative Room Reservation System

[![Build Status](https://travis-ci.org/NYULibraries/rooms.png?branch=development)](https://travis-ci.org/NYULibraries/rooms)
[![Dependency Status](https://gemnasium.com/NYULibraries/rooms.png)](https://gemnasium.com/NYULibraries/rooms)
[![Code Climate](https://codeclimate.com/github/NYULibraries/rooms.png)](https://codeclimate.com/github/NYULibraries/rooms)
[![Coverage Status](https://coveralls.io/repos/NYULibraries/rooms/badge.png?branch=development)](https://coveralls.io/r/NYULibraries/rooms)

The Graduate Collaborative Room Reservation System is a Rails 3 application that allows authorized user to view available graduate rooms and book them for private or collaborative study.

## Rooms Search with ElasticSearch (ES)

The rooms search uses indexed searching courtesy of [ElasticSearch](http://www.elasticsearch.org/) with the gem [tire](https://github.com/karmi/tire) which exposes the ElasticSearch DSL to blend easily with ActiveRecord.

### Install ES

If you are locally hosting ES or setting it up for development, download [the latest distribution](http://www.elasticsearch.org/guide/reference/setup/installation/).

Or install it from homebrew on a Mac:

	brew install elasticsearch

### Start up ES

To start it up run the following command `bin/elasticsearch` or `bin/elasticsearch -f` to run it in the fore-ground. Alternatively you can start it up with a custom config file:

	sudo elasticsearch -f -D es.config=/usr/local/opt/elasticsearch/config/elasticsearch.yml

You can find ElasticSearch by visiting:

	http://localhost:9200/

### ES on Rails

Tire
Flex

### Index records in ES

	bundle exec rake environment tire:import CLASS=Room FORCE=true
	bundle exec rake environment tire:import CLASS=Reservation FORCE=true
	
### Environment specific ElasticSearch indexes

When using webmock/vcr in test environment you cannot make physical web requests even when trying to run a tire import with the `RAILS_ENV=test` variable. A workaround for this would be to make the local settings the same as test settings and hardcode the `index_name` in each tire model to your test indexes. Then run the above import commands without a `RAILS_ENV` specified.

### Cloud-hosted ES

[Bonsai](http://www.bonsai.io/) is a cloud-hosted ES service.

## Scheduled Jobs

Every year at **4am on September 1st** the cleanup script runs to clear out users who have been inactive for over a year. The definition of an inactive user is a user who hasn't made a reservation.

## Time Zones

wtf?

## To-do

This application is in production and has recently been upgraded to Rails 3. However, the next version of the application is in development and will expand authorization to all students and have tiers of reservation access.

* Many things are not done 'the rails way'
* Expanded roles
* Full RESTful implementation
* Sunspot indexing or ElasticSearch