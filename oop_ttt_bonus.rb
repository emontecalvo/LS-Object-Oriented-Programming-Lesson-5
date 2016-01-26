# Assignment: OO TTT Bonus Features

# 1. Review the "bonus" features from the procedural TTT program, and incorporate all of them here, in the OO version.
# computer ai, change who goes first

# 2. Keep track of points, and first player to reach 5 points wins the game.

# 3. Allow the player to pick any marker.

# 4. Set a name for the player and computer.

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class TTTGame
  attr_reader :board, :human, :computer, :human_name, :computer_name, :first_to_move
  attr_accessor :human_total, :computer_total, :human_marker, :computer_marker

  def initialize
    @human_marker = 'X'
    @computer_marker = 'O'
    pick_x_or_o
    @board = Board.new
    @human = Player.new(@human_marker)
    @computer = Player.new(@computer_marker)
    first_to_move
    @current_marker = @first_to_move
    @human_total = 0
    @computer_total = 0
  end

  def first_to_move
    puts "Would you like to toss a coin, or pick who goes first yourself?"
    puts "Press 1 for the coin toss, 2 for picking who goes first yourself."
    coin_or_player_pick_turn = gets.chomp.to_i
    if coin_or_player_pick_turn == 1
      @first_to_move = [@computer_marker, @human_marker].sample
      puts "Coin flip!"
      puts "#{@first_to_move} will be going first this time."
      sleep 1
    elsif coin_or_player_pick_turn == 2
      puts "Press 1 to go first yourself, press 2 for the computer to go first."
      player_pick_turn = gets.chomp.to_i
      if player_pick_turn == 1
        @first_to_move = @human_marker
        puts "Okay, you've picked yourself to go first."
        sleep 1
      else
        @first_to_move = @computer_marker
        puts "You've picked the computer to go first."
        sleep 1
      end
    end
  end

  def pick_x_or_o
    puts "Would you like to be X or O?"
    puts "Type 'O' for O, any other key for X."
    x_or_o = gets.chomp
    if x_or_o.downcase == 'o'
      @human_marker = 'O'
      @computer_marker = 'X'
    end
  end

  def human_name
    puts "Please tell me your name:"
    @human_name = gets.chomp.upcase
  end

  def computer_name
    @computer_name = ['R2D2', 'C3PO', 'RED DWARF', 'HAL', 'AVA'].sample
  end

  def play
    clear
    display_welcome_message
    human_name
    computer_name
    loop do
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end

      display_result
      if @human_total == 5
        puts "You're the first one to five points, congratulations!"
        break
      elsif @computer_total == 5
        puts "Computer is the first one to five points!"
        break
      end
      break unless play_again?
      reset
      display_play_again_message
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "You're an #{@human_marker}. #{computer_name} is an #{@computer_marker}."
    puts ""
    board.draw
    puts ""
  end

  def human_moves
    puts "#{@human_name}, choose a square (#{board.unmarked_keys.join(', ')}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = @human_marker
  end

  def computer_moves
    # board[board.unmarked_keys.sample] = @computer_marker
    array_of_unmarked_squares = board.unmarked_keys
    space_where_computer_will_move = 0
    if array_of_unmarked_squares.include?(5)
      space_where_computer_will_move = 5
    else
      space_where_computer_will_move = array_of_unmarked_squares.sample
    end
    board[space_where_computer_will_move] = @computer_marker
  end

  def current_player_moves
    if @current_marker == @human_marker
      human_moves
      @current_marker = @computer_marker
    else
      computer_moves
      @current_marker = @human_marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when @human_marker
      puts "You won!"
      @human_total += 1
      puts "Your total points so far, #{@human_name}: #{@human_total}."
      puts "#{@computer_name} total points so far: #{@computer_total}."
    when @computer_marker
      puts "Computer won!"
      @computer_total += 1
      puts "Your total points so far, #{@human_name}: #{@human_total}."
      puts "#{@computer_name} total points so far: #{@computer_total}."
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def clear
    system "clear"
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
