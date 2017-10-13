require 'date'
require 'yaml'

require_relative '../services/billable_hours/calculator'
require_relative '../services/billable_hours/query'
require_relative '../services/sheets'

target_billable_hours_path = File.join(File.dirname(__FILE__), '../config/target_billable_hours.yml')
targets = YAML.load_file(target_billable_hours_path)

first_date_of_year = Date.new(2017, 1, 1)
start_date = Date.new(2017, 10, 1)
end_date = Date.new(2017, 12, 31)

remaining_billable_hours = Services::BillableHours::Calculator.calculate(
  (start_date + 1.day).to_time,
  (end_date + 1.day).to_time
)

values = []

results = Services::BillableHours::Query.for('Programmer - NY', first_date_of_year, start_date)
results.each do |result|
  first_name = result['first_name']
  total_billable_hours = result['total_billable_hours']
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

Services::Sheets.update(ENV['GOOGLE_SPREADSHEET_ID'], values, start_date, end_date)

puts "Done!"
