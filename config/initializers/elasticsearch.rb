require 'elasticsearch/model'
require 'elasticsearch/transport'

unless Rails.env.test? || Rails.env.development?
  Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['ROOMS_BONSAI_URL']
end
