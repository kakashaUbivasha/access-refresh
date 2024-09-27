class CreateUsers < ActiveRecord::Migration[7.1]
  def up
    create_table :users, id: false do |t|
      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.string :email, null: false
      t.string :refresh_token
      t.timestamps
    end
    execute "ALTER TABLE users ADD PRIMARY KEY (uuid);"
    add_index :users, :email, unique: true
  end
  def down
    drop_table :users
  end
end
