# config/initializers/xaman.rb

Rails.application.reloader.to_prepare do
  Xaman.configure do |c|
    c.api_key = ENV.fetch("XAMAN_API_KEY", "")
    c.api_secret = ENV.fetch("XAMAN_API_SECRET", "")
    c.base_url = "https://xumm.app/api/v1/platform"
  end
end
