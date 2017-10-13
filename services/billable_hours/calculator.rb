require 'business_time'

config_file = File.join(File.dirname(__FILE__), '../../config/business_time.yml')
BusinessTime::Config.load(config_file)

module Services
  module BillableHours
    module Calculator
      def self.calculate(from, to)
        billable_time = from.business_time_until(to)
        billable_time / 60 / 60
      end
    end
  end
end
