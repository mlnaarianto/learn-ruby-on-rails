class CreateRbac < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :description
      t.timestamps
    end
    add_index :roles, :name, unique: true

    create_table :permissions do |t|
      t.string :name, null: false      # contoh: "posts.update"
      t.string :group                  # contoh: "posts", untuk pengelompokan di UI
      t.string :description
      t.timestamps
    end
    add_index :permissions, :name, unique: true

    create_table :role_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.timestamps
    end
    add_index :role_permissions, [ :role_id, :permission_id ], unique: true

    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.timestamps
    end
    add_index :user_roles, [ :user_id, :role_id ], unique: true
  end
end