class Step < ApplicationRecord
    validates :game_id, presence: true, format: { with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/, message: "only uuid" }
    validates :player_type, presence: true, acceptance: { accept: ['x', 'o'] }
    validates :coord_x, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 14 }
    validates :coord_y, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 14 }
end
