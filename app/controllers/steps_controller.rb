class StepsController < ApplicationController
    def index
        steps = Step.all

        render json: {
            steps: steps
        }
    end

    def show
        step = Step.find(params[:id])
        render json: step
    end

    def create
        existing_step = Step
            .find_by(game_id: params[:game_id], coord_x: params[:coord_x], coord_y: params[:coord_y])

        if existing_step
            return render json: {message: "existing step"}, status: :unprocessable_entity
        end

        is_game_finished = GameService.new(params[:game_id]).game_finished?

        if is_game_finished
            return render json: {message: "the game is finished"}, status: :unprocessable_entity
        end

        last_step = Step
            .where(game_id: params[:game_id])
            .last

        if last_step && last_step.player_type == params[:player_type]
            return render json: {message: "it is not your turn"}, status: :unprocessable_entity
            end

        step = Step.new(
            game_id:params[:game_id],
            player_type:params[:player_type],
            coord_x:params[:coord_x],
            coord_y:params[:coord_y]
        )

        if step.save
            render json: step
        else
            render json: step.errors, status: :unprocessable_entity
        end
    end

end
