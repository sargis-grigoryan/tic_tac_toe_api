class CreateSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :steps do |t|
      t.string :game_id
      t.string :player_type
      t.integer :coord_x
      t.integer :coord_y
      t.timestamps
    end
  end
end
