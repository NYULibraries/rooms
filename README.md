# Rooms

[![Build Status](https://travis-ci.org/NYULibraries/rooms.png?branch=master)](https://travis-ci.org/NYULibraries/rooms)
[![Dependency Status](https://gemnasium.com/NYULibraries/rooms.png)](https://gemnasium.com/NYULibraries/rooms)
[![Code Climate](https://codeclimate.com/github/NYULibraries/rooms.png)](https://codeclimate.com/github/NYULibraries/rooms)
[![Coverage Status](https://coveralls.io/repos/NYULibraries/rooms/badge.png?branch=master)](https://coveralls.io/r/NYULibraries/rooms)

Allows authorized users to book rooms.

## Read the [wiki](https://github.com/NYULibraries/rooms/wiki)

## Notes

- ElasticSearch index with Tire gem for searching room availability
- Memcached through Dalli for robust caching
- CanCanCan for role authorization
- Authpds-nyu for NYU authentication through Shibboleth
- nyulibraries-assets for Bootstrap themed styles
- formaggio for Capistrano deploy
