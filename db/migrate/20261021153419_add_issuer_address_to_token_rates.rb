class AddIssuerAddressToTokenRates < ActiveRecord::Migration[8.1]
  def change
    add_column :token_rates, :issuer_address, :string
  end
end
