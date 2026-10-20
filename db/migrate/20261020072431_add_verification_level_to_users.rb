class AddVerificationLevelToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :verification_level, :integer, default: 0
    add_column :users, :ranking_level, :integer, default: 0
  end
end
