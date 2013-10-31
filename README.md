# Graduate Collaborative Room Reservation System

[![Build Status](https://travis-ci.org/NYULibraries/rooms.png?branch=development)](https://travis-ci.org/NYULibraries/rooms)
[![Dependency Status](https://gemnasium.com/NYULibraries/rooms.png)](https://gemnasium.com/NYULibraries/rooms)
[![Code Climate](https://codeclimate.com/github/NYULibraries/rooms.png)](https://codeclimate.com/github/NYULibraries/rooms)
[![Coverage Status](https://coveralls.io/repos/NYULibraries/rooms/badge.png?branch=development)](https://coveralls.io/r/NYULibraries/rooms)

The Graduate Collaborative Room Reservation System is an that allows authorized user to view available graduate rooms and book them for private or collaborative study.



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