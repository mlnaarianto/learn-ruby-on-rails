class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email,           null: false
      t.string :password_digest              # ← nullable, user OAuth = NULL
      t.integer :age
      t.string :provider
      t.string :uid
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, [ :provider, :uid ], unique: true,
              where: "provider IS NOT NULL"
  end
end
