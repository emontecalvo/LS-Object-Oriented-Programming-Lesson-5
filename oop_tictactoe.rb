# Object Oriented Tic-Tac-Toe

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]] # diagonals

  def initialize
    @squares = {} # {1 => Square.new('R'), 2 => Square.new(' ')}
    # instead of typing the hash out manually, first initialize squares to an empty hash:
    # ******   syntax:  @squares[key] = value
    # range, iterate thru range, then set integer as the key and the new Square object as the value
    # (1..9).each {|key| @squares[key] = Square.new} - moved to rest deg
    # @squares[key] expression above will mutate the @squares hash, thereby initailizing the board and ' '
    reset
  end

  def get_square_at(key)
    @squares[key] # or use fetch method
  end

  def set_square_at(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? } # this method could also be:  @squares.select{|_, sq| sq.unmarked?}.keys
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!detect_winner # relying on the truthines of returning an object
  end

  # returns winning marker or nil
  # if nil, then nobody has won

  def count_human_marker(squares)
    squares.collect(&:marker).count(TTTGame::HUMAN_MARKER) # this is give us an array of markers, which is an array of strings
    # we're tryfom array of square object, calling marker on each one of them, returning a
    # new array of marker (new array of strings), then checking to see at .count
    # how many times it is returning
  end

  def count_computer_marker(squares)
    squares.collect(&:marker).count(TTTGame::COMPUTER_MARKER)
  end

  def detect_winner
    WINNING_LINES.each do |line|
      # if count_human_marker(@squares.select{|k, _| line.include?(k)}.values) == 3
      # refactor:
      if count_human_marker(@squares.values_at(*line)) == 3
        return TTTGame::HUMAN_MARKER
      elsif count_computer_marker(@squares.values_at(*line)) == 3
        return TTTGame::COMPUTER_MARKER
      end
    end
    # WINNING_LINES.each do |line|
    #   if @squares[line[0]].marker == TTTGame::HUMAN_MARKER && @squares[line[1]].marker == TTTGame::HUMAN_MARKER &&
    #     @squares[line[2]].marker == TTTGame::HUMAN_MARKER
    #     return TTTGame::HUMAN_MARKER
    #   elsif @squares[line[0]].marker == TTTGame::COMPUTER_MARKER && @squares[line[1]].marker == TTTGame::COMPUTER_MARKER &&
    #     @squares[line[2]].marker == TTTGame::COMPUTER_MARKER
    #     return TTTGame::COMPUTER_MARKER
    #   end
    # end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
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
end

class Player
  attr_reader :marker

  def initialize(marker)
    # the player class is encapsulating the state for
    # this particular player, and this state represents the marker for this player
    @marker = marker
  end

  # def mark - we no longer need this, because we decided the board has the responsibility
  # end
  # see def human_moves / board.set_square_at(square, human.marker)
end

class TTTGame
  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts " "
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe...goodbye!"
  end

  def display_board(clear = true)
    system 'clear' if clear
    puts "You are a #{human.marker}. Computer is a #{computer.marker}."
    puts " "
    puts "     |     |"
    puts "  #{board.get_square_at(1)}  |  #{board.get_square_at(2)}  |  #{board.get_square_at(3)}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{board.get_square_at(4)}  |  #{board.get_square_at(5)}  |  #{board.get_square_at(6)}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{board.get_square_at(7)}  |  #{board.get_square_at(8)}  |  #{board.get_square_at(9)}"
    puts "     |     |"
    puts " "
  end

  def human_moves
    puts "Choose a square between (#{board.unmarked_keys.join(', ')}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    # this    board.set_square_at(square, @human) refactors to:
    board.set_square_at(square, human.marker) # because we have a reader for the marker
    # alternately, we could set it up so that it's the player's responsibility like this : @human.mark(square)
    # we tell the board what marker, the @human attritube comes in here
    # so the state of the human's marker @human should be inside the human object
    # above at def initialize @human = Player.new,
    # so we add the 'X' for @human in def initialize
  end

  def computer_moves
    board.set_square_at(board.unmarked_keys.sample, computer.marker)
  end

  def display_result
    display_board
    case board.detect_winner
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
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
      puts "Sorry, please enter 'y' or 'n'."
    end
    # return false if answer == 'n'
    # return true if answer == 'y'
    # refactor with:
    # you don't have to specificlly say return true false if
    # because at this point in time, answer is guaranteed to be y or n
    # and i want to return true if it's y, so answer == 'y' is good enough
    answer == 'y'
  end

  def play
    display_welcome_message
    system 'clear'
    loop do # main game-play loop
      display_board(false)

      loop do
        human_moves
        break if board.someone_won? || board.full?

        computer_moves
        break if board.someone_won? || board.full?
        display_board
      end
      display_result
      break unless play_again?
      board.reset
      system 'clear'
      puts "Let's play again!"
      puts " "
    end
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
