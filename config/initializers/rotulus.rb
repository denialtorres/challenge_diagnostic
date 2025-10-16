Rotulus.configure do |config|
  config.page_default_limit = 10
  config.page_max_limit = 10
  config.secret = ENV.fetch("ROTULUS_SECRET", "secret")
end
