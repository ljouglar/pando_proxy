class CreateServers < ActiveRecord::Migration
  def self.up
    create_table :servers do |t|
      t.column :ip_addr,      :string, :limit => 20,  :null => false
      t.column :port,         :string, :limit => 10,  :null => false, :default => '80'
      t.column :result,       :string, :limit => 255, :null => false, :default => ''
      t.column :transparency, :string, :limit => 20,  :null => false, :default => ''
      t.column :state,        :integer,               :null => false, :default => 0
      t.column :retries,      :integer,               :null => false, :default => 0
      t.column :duration,     :string, :limit => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :servers
  end
end
