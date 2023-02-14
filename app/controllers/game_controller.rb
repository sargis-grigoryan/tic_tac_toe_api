class GameController < ApplicationController
    def display_board
        @steps = Step
            .where(game_id: params[:game_id])
            .all

        @board = Array.new(15){Array.new(15)}

        @steps.each { |step|
            @board[step.coord_y][step.coord_x] = step.player_type
        }

        render json: {board: @board}
    end

end
