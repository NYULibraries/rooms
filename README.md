# Rooms

[![Build Status](https://travis-ci.org/NYULibraries/rooms.png?branch=development)](https://travis-ci.org/NYULibraries/rooms)
[![Dependency Status](https://gemnasium.com/NYULibraries/rooms.png)](https://gemnasium.com/NYULibraries/rooms)
[![Code Climate](https://codeclimate.com/github/NYULibraries/rooms.png)](https://codeclimate.com/github/NYULibraries/rooms)
[![Coverage Status](https://coveralls.io/repos/NYULibraries/rooms/badge.png?branch=development)](https://coveralls.io/r/NYULibraries/rooms)

The Rooms app allows authorized users to book rooms.

## Read the [wiki](https://github.com/NYULibraries/rooms/wiki)

## Notes

- ElasticSearch index with Tire gem for searching room availability 
- Memcached through Dalli for robust caching
- CanCan for role authorization
- Authpds-nyu for NYU authentication through Shibboleth
- nyulibraries_assets for Bootstrap themed styles
- nyulibraries_deploy for capistrano deploy