# Free Open Source Time Tracker (Web based, Ruby on Rails)

Open source time tracking software using Ruby on Rails. A project time tracking app you can self-host.

If you are looking for a linux time tracker and you are fine with a web-based time tracking software, try this.

[![Join the chat at https://gitter.im/J3RN/timesheet](https://badges.gitter.im/J3RN/timesheet.svg)](https://gitter.im/J3RN/timesheet?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Travis CI badge](https://travis-ci.org/J3RN/time-tracker.svg)](https://travis-ci.org/J3RN/time-tracker)
[![Maintainability](https://api.codeclimate.com/v1/badges/ada77e7c2f9d31eaf6aa/maintainability)](https://codeclimate.com/github/J3RN/time-tracker/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/ada77e7c2f9d31eaf6aa/test_coverage)](https://codeclimate.com/github/J3RN/time-tracker/test_coverage)

## Prerequisites to run the free time tracking tool

- Ruby >= v2.3.3. If you do not have Ruby installed, I would recommend [installing it through RVM](http://rvm.io/rvm/install).
- PostgreSQL. If you are on a Mac, I recommend [Postgres.app](http://postgresapp.com/).

## Setup

1. Clone this repository.
  ```
  git clone https://github.com/J3RN/timesheet.git
  ```

2. Enter the directory.
  ```
  cd timesheet
  ```

3. Run the setup script.
  ```
  ./bin/setup
  ```

5. Start the server.
  ```
  bundle exec rails server
  ```

  You can now see the application running on your machine by visiting [http://localhost:3000](http://localhost:3000).

## Testing

- Tests can be run using `rake test`.
- To see the test coverage, open `coverage/index.html` in your browser after running the tests.
