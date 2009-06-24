class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string    :login,               :null => false                
      t.string    :email,               :null => false
      t.string    :crypted_password,    :null => false                
      t.string    :password_salt,       :null => false                
      t.string    :persistence_token,   :null => false                
      t.string    :single_access_token, :null => false                # see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                # see Authlogic::Session::Perishability
      t.integer   :login_count,         :null => false, :default => 0 # see Authlogic::Session::MagicColumns
      t.integer   :failed_login_count,  :null => false, :default => 0 # see Authlogic::Session::MagicColumns
      t.datetime  :last_request_at                                    # see Authlogic::Session::MagicColumns
      t.datetime  :current_login_at                                   # see Authlogic::Session::MagicColumns
      t.datetime  :last_login_at                                      # see Authlogic::Session::MagicColumns
      t.string    :current_login_ip                                   # see Authlogic::Session::MagicColumns
      t.string    :last_login_ip                                      # see Authlogic::Session::MagicColumns
      t.integer   :account_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
