require 'date'
require 'yaml'

require_relative '../harvest/client'
require_relative '../services/billable_hour_calculator'
require_relative '../services/sheets'

target_billable_hours_path = File.join(File.dirname(__FILE__), '../config/target_billable_hours.yml')
targets = YAML.load_file(target_billable_hours_path)

first_date_of_year = Date.new(2017, 1, 1)
start_date = Date.new(2017, 10, 1)
end_date = Date.new(2017, 12, 31)

remaining_billable_hours = BillableHourCalculator.calculate(
  (start_date + 1.day).to_time,
  (end_date + 1.day).to_time
)

client = Harvest::Client.new(
  subdomain: ENV['HARVEST_SUBDOMAIN'],
  email: ENV['HARVEST_EMAIL'],
  password: ENV['HARVEST_PASSWORD']
)

GOOGLE_SPREADSHEET_ID = ENV['GOOGLE_SPREADSHEET_ID']

people = client.people(
  'department' => 'Programmer - NY',
  'is_active'  => true
)

values = []

people.each do |person|
  total_billable_hours = client.total_billable_hours(
    person_id: person['id'],
    from: first_date_of_year.strftime('%Y-%m-%d'),
    to: start_date.strftime('%Y-%m-%d')
  )

  first_name = person['first_name']
  target = targets[first_name]

  if target
    values << [
      first_name,
      total_billable_hours,
      target,
      target - total_billable_hours,
      remaining_billable_hours,
      total_billable_hours + remaining_billable_hours - target
    ]
  end
end

values = values.sort_by { |value| -value.last }

headers = [
  'Employee',
  start_date.strftime('%-m/%-d'),
  'Target',
  "Target - #{start_date.strftime('%-m/%-d')}",
  end_date.strftime('%-m/%-d'),
  'Buffer'
]

values.unshift(headers)

Services::Sheets.update(GOOGLE_SPREADSHEET_ID, values, start_date, end_date)

puts "Done!"
