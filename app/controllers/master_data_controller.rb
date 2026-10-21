class MasterDataController < ApplicationController
  def show
    master_data = {
      token_rates: token_rates,
      countries: countries
    }

    render json: { master_data: master_data }, status: :ok
  end

  private
  def token_rates
    TokenRate.all.map do |token_rate|
      token_rate.attributes.except("created_at", "updated_at", "issuer_address")
    end
  end

  def countries
    Country.all.map do |country|
      country.attributes.except("created_at", "updated_at")
    end
  end
end
