class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :player_1_id, index: true, null: false
      t.integer :player_2_id, index: true, null: false
      t.integer :player_1_score, :default => 0
      t.integer :player_2_score, :default => 0
      t.integer :winner_id, index: true
      t.datetime :played_at, null: false, default: 'now()'

      t.timestamps null: false
    end
    # add indexes to the players and the winner
    add_foreign_key :games, :users, column: :player_1_id, primary_key: :id
    add_foreign_key :games, :users, column: :player_2_id, primary_key: :id
    add_foreign_key :games, :users, column: :winner_id, primary_key: :id
  end
end
