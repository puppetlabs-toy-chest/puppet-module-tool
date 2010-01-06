class ResetUsersForDevise < ActiveRecord::Migration
  def self.up
    drop_table :users
    create_table :users do |t|
      t.string :username
      t.authenticatable
      t.confirmable
      t.recoverable
      t.rememberable
      t.trackable
      t.timestamps
    end
    add_index :users, :email
    add_index :users, :confirmation_token    # for confirmable
    add_index :users, :reset_password_token  # for recoverable
  end

  def self.down
    drop_table :users
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password
      t.timestamps
    end
  end
end
