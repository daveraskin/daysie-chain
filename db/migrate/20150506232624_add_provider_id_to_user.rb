class AddProviderIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :provider_id, :string
  end
end
