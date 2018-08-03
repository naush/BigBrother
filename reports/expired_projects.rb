require 'date'
require_relative '../harvest/client'

def colorize(color_code, string)
  "\e[#{color_code}m#{string}\e[0m"
end

client = Harvest::Client.new(
  subdomain: ENV['HARVEST_SUBDOMAIN'],
  email: ENV['HARVEST_EMAIL'],
  password: ENV['HARVEST_PASSWORD']
)

NUMBER_OF_DAYS = 60

to = Date.today
from = to - NUMBER_OF_DAYS

projects = client.projects('active' => true)

projects.each do |project|
  project_id = project['id']

  entries = client.project_time_entries(
    project_id: project_id,
    from: from,
    to: to
  )

  if entries.size == 0
    puts "#{colorize(35, project['name'])} has not logged any entries in the past #{NUMBER_OF_DAYS} days"
  end
end
