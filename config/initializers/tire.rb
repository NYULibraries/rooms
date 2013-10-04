Tire.configure do
  url Settings.elasticsearch.bonsai.url
  #you can uncomment the next line if you want to see the elasticsearch queries in their own seperate log
  #logger "#{Rails.root}/log/es.log" 
end