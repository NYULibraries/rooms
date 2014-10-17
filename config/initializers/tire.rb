Tire.configure do
  url ENV['ROOMS_BONSAI_URL']
  #you can uncomment the next line if you want to see the elasticsearch queries in their own seperate log
  #logger "#{Rails.root}/log/es.log"
end
