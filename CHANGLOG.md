# Change Log

## 2013-11-01

### Functional Changes
- Authorization
	- Opened up to authorized patron statuses, each in their own group with access to room belonging to that group
- Search
	- Search has been refactored with an index backend to scale for more classrooms and wider user community
- Time Zones
	- Implemented local timezones when booking so users will have a seamless interaction in Shanghai and other places around the world. See the [time zones wiki article](/NYULibraries/rooms/wiki/Time-Zones) for more info.
- Admin
	- Changed Room management format to be searchable and sortable with a separate view for changing the view sort order.
	- Filter by room groups for admins with access to more than one group

### Technical Changes
- Major code refactor
	- Rails-ified many methods: usage of respond_with/to, decorators, and removed custom functions for lightweight gems, among other changes
	- Moved helper functions mainly to models where it made sense for more MVC conformity
	- Implemented Cancan for building out roles
- Testing coverage
	- Built out significantly but more work to do

## 2013-10-25

### Functional Changes
- __Shibboleth Integration__  
  We've integrated the [PDS Shibboleth integration](https://github.com/NYULibraries/pds-custom/wiki/NYU-Shibboleth-Integration)
  into this release.

### Technical Changes
- :gem: __Updates__: Most gems are up to date. We're not on Rails 4, so that's the exception, but Rails 3.2.15 security vulnerability closed.

- __Update authpds-nyu__: Use the Shibboleth version of the 
  [NYU PDS authentication gem](https://github.com/NYULibraries/authpds-nyu/tree/v1.1.2).

- __Use nyulibraries_deploy__ Refactored to use the [NYU Libraries Deploy gem](https://github.com/NYULibraries/nyulibraries_deploy) for capistrano recipe simplification and the ability to send diff emails.