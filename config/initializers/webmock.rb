# This allows us to reindex ElasticSearch from rake
if Rails.env.test?
  WebMock.allow_net_connect!
end