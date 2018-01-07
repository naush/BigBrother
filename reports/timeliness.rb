require 'date'
require 'set'
require_relative '../harvest/client'

client = Harvest::Client.new(
  subdomain: ENV['HARVEST_SUBDOMAIN'],
  email: ENV['HARVEST_EMAIL'],
  password: ENV['HARVEST_PASSWORD']
)

def colorize(color_code, string)
  "\e[#{color_code}m#{string}\e[0m"
end

def updated_at(time_entries)
  submitted = time_entries.select { |entry| entry['day_entry']['is_closed'] }

  unless submitted.empty?
    updated_at = submitted.map { |entry| entry['day_entry']['updated_at'] }.first

    return Date.parse(updated_at)
  end
end

def week(today)
  if today.wday == 0
    monday = today - 6
    sunday = today
  else
    monday = today - today.wday + 1
    sunday = today + (7 - today.wday)
  end

  return monday, sunday
end
people = client.people(
  'department' => 'Programmer - NY',
  'is_active'  => true
)

def weeks(year)
  first_day_of_year = Date.new(year, 1, 1)
  last_day_of_year = Date.new(year, 12, 31)

  weeks = Set.new

  (first_day_of_year...last_day_of_year).each do |day|
    monday, sunday = week(day)
    weeks.add([monday, sunday])
  end

  return weeks
end

weeks = weeks(2017)

people.each do |person|
  full_name = "#{person['first_name']} #{person['last_name']}"
  puts "Employee name: #{colorize(32, full_name)}"
  offsets = []

  weeks.each do |week|
    monday = week.first
    sunday = week.last
    next_monday = sunday + 1

    time_entries = client.time_entries(
      person_id: person['id'],
      from: monday,
      to: sunday
    )

    updated_at = updated_at(time_entries)

    if updated_at
      offset = (updated_at - next_monday).to_f

      if offset.abs < 7
        offsets << offset
      end
    end
  end

  total = offsets.inject(0) { |sum, number| sum + number }
  average = (total / offsets.size.to_f).round(2)

  puts "Total days from due date: #{colorize(32, total)}"
  puts "Average days from due date: #{colorize(32, average)}"
  puts "Sample size: #{colorize(32, offsets.size)}"
  puts ""
end
