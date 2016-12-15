require 'elasticsearch/model'
require 'elasticsearch/transport'

Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['ROOMS_BONSAI_URL']
