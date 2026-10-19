namespace :seed_db do
  desc "Seed initial countries master data with max lending interest rate"
  task seed_countries: :environment do
    countries_data = [
      { code: "VN", name: "Vietnam", max_lending_interest_rate: 20 },
      { code: "US", name: "United States", max_lending_interest_rate: 15 },
      { code: "JP", name: "Japan", max_lending_interest_rate: 10 },
      { code: "SG", name: "Singapore", max_lending_interest_rate: 12 },
      { code: "TH", name: "Thailand", max_lending_interest_rate: 18 },
      { code: "KR", name: "South Korea", max_lending_interest_rate: 20 },
      { code: "GB", name: "United Kingdom", max_lending_interest_rate: 15 },
      { code: "AR", name: "Argentina", max_lending_interest_rate: 0 },
      { code: "BR", name: "Brazil", max_lending_interest_rate: 0 },
      { code: "FR", name: "France", max_lending_interest_rate: 0 },
      { code: "DE", name: "Germany", max_lending_interest_rate: 0 },
      { code: "IN", name: "India", max_lending_interest_rate: 0 },
      { code: "IT", name: "Italy", max_lending_interest_rate: 0 },
      { code: "KE", name: "Kenya", max_lending_interest_rate: 0 },
      { code: "MX", name: "Mexico", max_lending_interest_rate: 0 },
      { code: "NL", name: "Netherlands", max_lending_interest_rate: 0 },
      { code: "NG", name: "Nigeria", max_lending_interest_rate: 0 },
      { code: "PH", name: "Philippines", max_lending_interest_rate: 0 },
      { code: "PL", name: "Poland", max_lending_interest_rate: 0 },
      { code: "ES", name: "Spain", max_lending_interest_rate: 0 },
      { code: "AE", name: "United Arab Emirates", max_lending_interest_rate: 0 },
      { code: "OTHER", name: "Other country", max_lending_interest_rate: 0 }
    ]

    puts "Starting to seed countries..."

    countries_data.each do |data|
      country = Country.find_or_initialize_by(code: data[:code])
      country.update!(
        name: data[:name],
        max_lending_interest_rate: data[:max_lending_interest_rate]
      )
      puts "  - Processed #{country.name} (#{country.code}): Max Rate #{country.max_lending_interest_rate}%"
    end

    puts "Countries seed completed successfully!"
  end
end
