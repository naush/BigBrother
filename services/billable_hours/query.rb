require_relative '../../harvest/client'

module Services
  module BillableHours
    module Query
      def self.for(department, from, to)
        client = Harvest::Client.new(
          subdomain: ENV['HARVEST_SUBDOMAIN'],
          email: ENV['HARVEST_EMAIL'],
          password: ENV['HARVEST_PASSWORD']
        )

        people = client.people(department: department, is_active: true)
        from_date_string = from.strftime('%Y-%m-%d')
        to_date_string = to.strftime('%Y-%m-%d')

        people.collect do |person|
          {
            first_name: person['first_name'],
            total_billable_hours: client.total_billable_hours(
              person_id: person['id'],
              from: from_date_string,
              to: to_date_string
            )
          }
        end
      end
    end
  end
end
