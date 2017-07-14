### Big Brother Is Watching You

A script to retrieve time entries for users in your organization.

### Environment

Set Harvest account subdomain, email, and password environment variables in `.env` file. See `.env.example` for exapmle.

```
$ cp .env.example .env
$ source .env
```

### Execute example script

```
$ ruby watch 2017-07-09 2017-07-16
# Usage: watch [options]
#   -1| The beginning of the week (default: Monday of current week)
#   -2| The end of the week (default: Sunday of current week)
```

### Harvest client library

Custom Ruby client library for Harvest.

```rb
# Create client
client = Harvest::Client.new(
  subdomain: ENV['SUBDOMAIN'],
  email: ENV['EMAIL'],
  password: ENV['PASSWORD']
)

# Retrieve people
people = client.people(
  'department' => 'Programmer - NY',
  'is_active'  => true
)

# Retrieve time entries given user id and date range
time_entries = client.time_entries(
  person_id: '12345',
  from: '2017-07-09',
  to: '2017-07-16'
)
```
