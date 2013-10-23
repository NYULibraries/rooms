# Change Log

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
