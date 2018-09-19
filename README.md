# Oslr API Readme

This is the API for Oslr (www.oslr.co.uk). It relies heavily on the jsonapi-resources gem to provide REST-ful API end points for the underlying database. This guide should get it up and running on most systems.

## Dependencies

The following should be installed:

* RVM (https://rvm.io):
..* gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
..* \curl -sSL https://get.rvm.io | bash -s stable --ruby
* Git
..* This can be set up to use a deploy key as per this guide: https://gist.github.com/zhujunsan/a0becf82ade50ed06115

## Installation

```
git clone git@github.com:oslr/oslr-api.git
cd oslr-api
bundle install
```

This will download the source code and install required gems. Some additional setup is required to run a server:

### Database setup

* Create a file database.yml in the config directory.
* If you want to run a local testing database:
..* Make sure mysql is installed (installer here: https://dev.mysql.com/downloads/installer/)
..* Create a mysql database

Example database.yml file which uses a local database for test and development and a live online server in production:

```yaml
default: &default
  adapter: mysql2
  encoding: utf8
  reconnect: false
  username: root
  password:
  host: localhost
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: oslr_development

test:
  <<: *default
  database: oslr_tmp

production:
  <<: *default
  database: oslr_production
  host: <database-server-ip-address>
  username: *******
  password: *******
  port: 3306
```
# ember-api-backend
