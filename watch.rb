require 'date'
require_relative 'harvest/client'

client = Harvest::Client.new(
  subdomain: ENV['SUBDOMAIN'],
  email: ENV['EMAIL'],
  password: ENV['PASSWORD']
)

def colorize(color_code, string)
  "\e[#{color_code}m#{string}\e[0m"
end

def personalize_messages(person, time_entries)
  messages = []
  full_name = "#{person['first_name']} #{person['last_name']}"

  if time_entries.length > 0
    messages << "#{colorize(32, full_name)} has logged time! :)"
    submitted = time_entries.reject { |entry| entry['day_entry']['is_closed'] }

    if submitted.empty?
      messages << "#{colorize(32, full_name)} has been approved! :)"
    else
      messages << "#{colorize(35, full_name)} has not been approved :("
    end
  else
    messages << "#{colorize(31, full_name)} has not logged time :("
  end

  return messages
end

from, to, *args = ARGV

if from.nil? || to.nil?
  today = Date.today
  if today.wday == 0
    monday = today - 6
    sunday = today
  else
    monday = today - today.wday + 1
    sunday = today + (7 - today.wday)
  end

  from = monday.strftime('%Y-%m-%d')
  to   = sunday.strftime('%Y-%m-%d')
end

people = client.people(
  'department' => 'Programmer - NY',
  'is_active'  => true
)

puts "For the week of #{colorize(32, from)} to #{colorize(32, to)}:"

people.each do |person|
  time_entries = client.time_entries(
    person_id: person['id'],
    from: from,
    to: to
  )

  puts personalize_messages(person, time_entries)
end
