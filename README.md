# Big Brother Is Watching You

A script to retrieve time entries for users in your Harvest organization.

## Environment

Set Harvest account subdomain, email, and password environment variables in `.env` file.

```
$ cp .env.example .env
$ source .env
```

## Execute sample reports

```
$ ruby reports/pending_approval 2017-07-09 2017-07-16
# Usage: watch [options]
#   -1| The beginning of the week (default: Monday of current week)
#   -2| The end of the week (default: Sunday of current week)
```

```
$ ruby reports/billable_hours.rb
```

## Harvest client library

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

# Retrieve time entries given person id and date range
time_entries = client.time_entries(
  person_id: '12345',
  from: '2017-07-09',
  to: '2017-07-16'
)

# Retrieve total billable hours given person id and date range
total_billable_hours = client.total_billable_hours(
  person_id: '12345',
  from: '2017-07-09',
  to: '2017-07-16'
)
```
