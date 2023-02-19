class GameService
    BOARD_SIZE = 15.freeze
    WINNING_LENGTH = 5.freeze

    def initialize(game_id)
        @game_id = game_id
    end

    def get_board
        steps = Step
                    .where(game_id: @game_id)
                    .all

        last_step = steps.last

        board = create_board(steps)

        win_coords = get_win_coords(board, last_step)

        next_turn = (last_step && last_step.player_type == "x") ? "o" : "x"

        board_with_win = get_board_with_win(board, win_coords)

        {
            board: board_with_win,
            turn: next_turn,
            winner: win_coords.length > 0 && last_step.player_type,
        }
    end

    def game_finished?
        steps = Step
                    .where(game_id: @game_id)
                    .all

        last_step = steps.last

        board = create_board(steps)

        win_coords = get_win_coords(board, last_step)

        win_coords.length > 0
    end

    private

    def create_board(steps)
        board = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE) }

        steps.each do |step|
            board[step.coord_y][step.coord_x] = step.player_type
        end

        board
    end

    def get_board_with_win(board, win_coords)
        parsed_board = board.map do |row|
            row.map do |cell_value|
                [cell_value, false]
            end
        end

        win_coords&.each do |coord|
            parsed_board[coord[:coord_y]][coord[:coord_x]][1] = true
        end

        parsed_board
    end

    def get_win_coords(board, last_step)
        return [] unless last_step

        last_entered_value = last_step.player_type
        coord_x = last_step.coord_x
        coord_y = last_step.coord_y

        horizontal_win_coords = get_horizontal_win_coords(board, last_entered_value, coord_x, coord_y)
        vertical_win_coords = get_vertical_win_coords(board, last_entered_value, coord_x, coord_y)
        diagonal1_win_coords = get_diagonal1_win_coords(board, last_entered_value, coord_x, coord_y)
        diagonal2_win_coords = get_diagonal2_win_coords(board, last_entered_value, coord_x, coord_y)
        [].concat(horizontal_win_coords, vertical_win_coords, diagonal1_win_coords, diagonal2_win_coords)
    end

    def get_horizontal_win_coords(board, last_entered_value, coord_x, coord_y)
        min_coord_x = coord_x - (WINNING_LENGTH - 1) < 0 ? 0 : coord_x - (WINNING_LENGTH - 1)
        max_coord_x = coord_x + (WINNING_LENGTH - 1) > BOARD_SIZE - 1 ? BOARD_SIZE - 1 : coord_x + (WINNING_LENGTH - 1)

        slice = (min_coord_x..max_coord_x).to_a.map do |x|
            {
                value: board[coord_y][x],
                coord_x: x,
                coord_y: coord_y
            }
        end

        check_array_for_win(slice, last_entered_value)
    end

    def get_vertical_win_coords(board, last_entered_value, coord_x, coord_y)
        min_coord_y = coord_y - (WINNING_LENGTH - 1) < 0 ? 0 : coord_y - (WINNING_LENGTH - 1)
        max_coord_y = coord_y + (WINNING_LENGTH - 1) > BOARD_SIZE - 1 ? BOARD_SIZE - 1 : coord_y + (WINNING_LENGTH - 1)

        slice = (min_coord_y..max_coord_y).to_a.map do |y|
            {
                value: board[y][coord_x],
                coord_x: coord_x,
                coord_y: y
            }
        end

        check_array_for_win(slice, last_entered_value)
    end

    # from upper left to lower right
    def get_diagonal1_win_coords(board, last_entered_value, coord_x, coord_y)
        min_coord_x = coord_x - (WINNING_LENGTH - 1) < 0 ? 0 : coord_x - (WINNING_LENGTH - 1)
        max_coord_x = coord_x + (WINNING_LENGTH - 1) > BOARD_SIZE - 1 ? BOARD_SIZE - 1 : coord_x + (WINNING_LENGTH - 1)
        min_coord_y = coord_y - (WINNING_LENGTH - 1) < 0 ? 0 : coord_y - (WINNING_LENGTH - 1)
        max_coord_y = coord_y + (WINNING_LENGTH - 1) > BOARD_SIZE - 1 ? BOARD_SIZE - 1 : coord_y + (WINNING_LENGTH - 1)

        left_steps_count = [coord_x - min_coord_x, coord_y - min_coord_y].min
        right_steps_count = [max_coord_x - coord_x, max_coord_y - coord_y].min

        return [] if left_steps_count + 1 + right_steps_count < WINNING_LENGTH

        slice = (-left_steps_count..right_steps_count).to_a.map do |i|
            {
                value: board[coord_y + i][coord_x + i],
                coord_x: coord_x + i,
                coord_y: coord_y + i
            }
        end

        check_array_for_win(slice, last_entered_value)
    end

    # from lower left to upper right
    def get_diagonal2_win_coords(board, last_entered_value, coord_x, coord_y)
        min_coord_x = coord_x - (WINNING_LENGTH - 1) < 0 ? 0 : coord_x - (WINNING_LENGTH - 1)
        max_coord_x = coord_x + (WINNING_LENGTH - 1) > BOARD_SIZE - 1 ? BOARD_SIZE - 1 : coord_x + (WINNING_LENGTH - 1)
        min_coord_y = coord_y - (WINNING_LENGTH - 1) < 0 ? 0 : coord_y - (WINNING_LENGTH - 1)
        max_coord_y = coord_y + (WINNING_LENGTH - 1) > BOARD_SIZE - 1 ? BOARD_SIZE - 1 : coord_y + (WINNING_LENGTH - 1)

        left_steps_count = [coord_x - min_coord_x, max_coord_y - coord_y].min
        right_steps_count = [max_coord_x - coord_x, coord_y - min_coord_y].min

        return [] if left_steps_count + 1 + right_steps_count < WINNING_LENGTH

        slice = (-left_steps_count..right_steps_count).to_a.map do |i|
            {
                value: board[coord_y - i][coord_x + i],
                coord_x: coord_x + i,
                coord_y: coord_y - i
            }
        end

        check_array_for_win(slice, last_entered_value)
    end

    def check_array_for_win(board_slice, last_entered_value)
        _puts "check_array_for_win", "check_array_for_win"
        first_winning_index = nil
        last_winning_index = nil

        board_slice.each_with_index do |cell, index|
            if cell[:value] == last_entered_value
                if first_winning_index.nil?
                    first_winning_index = index
                end

                last_winning_index = index
            else
                if !first_winning_index.nil? && !last_winning_index.nil? && last_winning_index - first_winning_index + 1 >= WINNING_LENGTH
                    break
                else
                    first_winning_index = nil
                    last_winning_index = nil
                end
            end
        end

        if !first_winning_index.nil? && !last_winning_index.nil? && last_winning_index - first_winning_index + 1 < WINNING_LENGTH
            first_winning_index = nil
            last_winning_index = nil
        end

        return [] unless first_winning_index

        _puts first_winning_index, "first_winning_index"
        _puts last_winning_index, "last_winning_index"

        (first_winning_index..last_winning_index).to_a.map do |i|
            {
                coord_x: board_slice[i][:coord_x],
                coord_y: board_slice[i][:coord_y]
            }
        end
    end

    def _puts(value, name)
        puts "################################{name}######################################"
        puts "#{value}"
        puts "################################{name}######################################"
    end
end