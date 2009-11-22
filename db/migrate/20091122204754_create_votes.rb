class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.integer :politician_id
      t.boolean :vote
      t.integer :bill_id

      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
