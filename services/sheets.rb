require 'fileutils'

require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'
CLIENT_SECRETS_PATH = File.join(File.dirname(__FILE__),
                                '../.credentials',
                                'client_secret.json')
CREDENTIALS_PATH = File.join(File.dirname(__FILE__),
                             '../.credentials',
                             'sheets.googleapis.com.yaml')
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

module Services
  module Sheets
    def self.authorize
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(
        client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(
          base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the " +
             "resulting code after authorization"
        puts url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      end
      credentials
    end

    def self.update(spreadsheet_id, values, start_date, end_date)
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize

      batch_update_values_by_data_filter_request_object = {
        'value_input_option': 'RAW',
        'data': [
          {
            'data_filter': {
              'a1_range': "Chart!A1:F#{values.size + 1}",
            },
            'major_dimension': 'ROWS',
            'values': values
          }
        ],
      }

      response = service.batch_spreadsheet_value_update_by_data_filter(
        spreadsheet_id,
        batch_update_values_by_data_filter_request_object,
        options: {}
      )

      p batch_update_values_by_data_filter_request_object
      p response
    end
  end
end
