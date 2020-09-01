class UpdateToolProxySharedSecret < ActiveRecord::Migration[6.0]
  def change
    change_column :rails_lti2_provider_tools, :shared_secret, :text, limit: nil
  end
end
