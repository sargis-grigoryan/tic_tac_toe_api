class GameController < ApplicationController
    def display_board
        @steps = Step
            .where(game_id: params[:game_id])
            .all

        @board = Array.new(15){Array.new(15)}

        @steps.each { |step|
            @board[step.coord_y][step.coord_x] = step.player_type
        }

        @next_turn = (@steps.last && @steps.last.player_type == "x") ? "o" : "x"

        render json: {
            board: @board,
            turn: @next_turn
        }
    end

end
