# Rooms

[![Build Status](https://travis-ci.org/NYULibraries/rooms.png?branch=development)](https://travis-ci.org/NYULibraries/rooms)
[![Dependency Status](https://gemnasium.com/NYULibraries/rooms.png)](https://gemnasium.com/NYULibraries/rooms)
[![Code Climate](https://codeclimate.com/github/NYULibraries/rooms.png)](https://codeclimate.com/github/NYULibraries/rooms)
[![Coverage Status](https://coveralls.io/repos/NYULibraries/rooms/badge.png?branch=development)](https://coveralls.io/r/NYULibraries/rooms)

The Rooms app allows NYU users to book rooms for which they are authorized.

## Read the [wiki](/NYULibraries/rooms/wiki)

## Benchmarking

### Before ElasticSearch index:

### After ElasticSearch index (now):

	ReservationTest#test_getting_availabilty_grid (79 ms warmup)
	        process_time: 35 ms
	              memory: 0 Bytes
	             objects: 0

## Notes

- ElasticSearch index with Tire gem for searching room availability 
- Memcached through Dalli for robust caching
- CanCan for role authorization
- Authpds-nyu for NYU authentication through Shibboleth
- nyulibraries_assets for Bootstrap themed styles
- nyulibraries_deploy for capistrano deploy