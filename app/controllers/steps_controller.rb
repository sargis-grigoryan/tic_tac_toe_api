class StepsController < ApplicationController
    def index
        @steps = Step.all

        Array.new(3){Array.new(3)}

        render json: {
            steps: @steps
        }
    end

    def show
        @step = Step.find(params[:id])
        render json: @step
    end

    def create
        @existing_step = Step
            .where(game_id: params[:game_id])
            .where(coord_x: params[:coord_x])
            .where(coord_y: params[:coord_y])
            .take

        if @existing_step
            return render json: {message: "existing step"}, status: :unprocessable_entity
        end

        @last_step = Step
            .where(game_id: params[:game_id])
            .last

        if @last_step && @last_step.player_type == params[:player_type]
            return render json: {message: "it is not your turn"}, status: :unprocessable_entity
            end

        @step = Step.new(
            game_id:params[:game_id],
            player_type:params[:player_type],
            coord_x:params[:coord_x],
            coord_y:params[:coord_y]
        )

        if @step.save
            render json: @step
        else
            render json: @step.errors, status: :unprocessable_entity
        end
    end

end
