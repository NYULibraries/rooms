require 'elasticsearch/model'
require 'elasticsearch/transport'

unless Rails.env.test? || Rails.env.development?
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['ROOMS_BONSAI_URL'])
else
  if ENV['ROOMS_DEV_ELASTICSEARCH_URL']
    Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['ROOMS_DEV_ELASTICSEARCH_URL'])
  end
end
