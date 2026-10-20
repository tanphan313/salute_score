if country.present?
  json.extract! country, :id, :code, :name, :max_lending_interest_rate
else
  json.nil!
end
