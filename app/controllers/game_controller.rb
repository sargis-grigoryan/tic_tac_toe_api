class GameController < ApplicationController
    def display_board
        game = GameService.new(params[:game_id])

        render json: game.get_board
    end

end
