class RenameRefreshTokenToRefreshTokenDigest < ActiveRecord::Migration[7.1]
  def change
    rename_column :users, :refresh_token, :refresh_token_digest
  end
end
