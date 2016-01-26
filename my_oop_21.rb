# my oop 21 game

WIN = 21
DEALER_MIN = 17

class Human
  attr_accessor :player_hand, :player_total
  def initialize
    @player_hand = []
    @player_total = 0
  end

  def deal_cards(the_deck)
    @player_hand << the_deck.deal_card
  end

  def calc_player_total(the_deck)
    @player_total = the_deck.calc_total(@player_hand)
    @player_total
  end
end

class Dealer
  attr_accessor :dealer_hand, :dealer_total
  def initialize
    @dealer_hand = []
    @dealer_total = 0
  end

  def deal_cards(the_deck)
    @dealer_hand << the_deck.deal_card
  end

  def calc_player_total(the_deck)
    @dealer_total = the_deck.calc_total(@dealer_hand)
    @dealer_total
  end
end

class Deck
  attr_accessor :cards
  def initialize
    @suit = ['H', 'D', 'S', 'C']
    @face = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
    @cards = @suit.product(@face)
    shuffle_deck
  end

  def shuffle_deck
    @cards.shuffle!
    puts "shuffled deck is now:"
  end

  def deal_card
    @cards.pop
  end

  def calc_total(player_hand)
    value = 0
    player_hand.flatten.each do |x|
      if x == 'J'
        value += 10
      elsif x == 'Q'
        value += 10
      elsif x == 'K'
        value += 10
      elsif x == 'A'
        value += 11
      else
        value += x.to_i
      end
    end

    if value > WIN
      player_hand.flatten.each do |x|
        if x == 'A'
          value -= 10
        end
      end
    end
    value
  end
end

class Game
  attr_accessor :the_deck, :human, :dealer, :dealer_hand, :player_hand, :human_total_wins, :dealer_total_wins

  def initialize
    @human_total_wins = 0
    @dealer_total_wins = 0
  end

  def the_initialize
    system 'clear'
    @the_deck = Deck.new
    @human = Human.new
    @dealer = Dealer.new
  end

  def welcome_message
    puts "Welcome to 21!"
  end

  def goodbye_message
    puts " "
    puts "Goodbye, thank you for playing #{@player_name}."
  end

  def get_name
    puts "What's your name?"
    @player_name = gets.chomp
    puts "Let me deal out the cards, #{@player_name}"
  end

  def play_again
    puts "Would you like to play again?  y/n"
    play_more = gets.chomp
    if play_more.downcase == 'y'
      return true
    else
      return false
    end
  end

  def check_winner
    if @human.calc_player_total(@the_deck) > WIN && @dealer.calc_player_total(@the_deck) <= WIN
      puts "................."
      puts " You've gone bust!  Dealer wins."
      puts ". . . . . . . . ."
      sleep 1
      @dealer_total_wins += 1
    elsif @dealer.calc_player_total(@the_deck) > WIN && @human.calc_player_total(@the_deck) <= WIN
      puts "* * * * * * * * * * * "
      puts "Dealer went bust, you win!"
      puts "* * * * * * * * * * * "
      sleep 1
      @human_total_wins += 1
    elsif @human.calc_player_total(@the_deck) == @dealer.calc_player_total(@the_deck)
      puts "................."
      puts "It's a tie!"
      puts "................."
      sleep 1
    elsif @human.calc_player_total(@the_deck) > @dealer.calc_player_total(@the_deck)
      puts "* * * * * * * * * * * "
      puts "You win!"
      puts "* * * * * * * * * * * "
      sleep 1
      @human_total_wins += 1
    elsif @dealer.calc_player_total(@the_deck) > @human.calc_player_total(@the_deck)
      puts "................."
      puts "Dealer wins."
      puts "................."
      sleep 1
      @dealer_total_wins += 1
    else
      puts "We haven't accounted for this situation yet in checking the winner."
    end
  end

  def start
    welcome_message
    get_name
    puts @player_name

    loop do # main game loop
      the_initialize
      @human.deal_cards(@the_deck)
      @dealer.deal_cards(@the_deck)
      @human.deal_cards(@the_deck)
      @dealer.deal_cards(@the_deck)
      puts "- - - - - - -"
      puts "#{@player_name} hand:  #{@human.player_hand}"
      puts "dealer upcard: #{@dealer.dealer_hand[1]}"
      sleep 1
      @human.calc_player_total(@the_deck)
      puts "#{@player_name} total:  #{@human.calc_player_total(@the_deck)}"
      @dealer.calc_player_total(@the_deck)
      # puts "=> Dealer total:  #{@dealer.calc_player_total(@the_deck)}"
      sleep 1
      while @human.player_total < WIN
        puts " "
        puts " => #{@player_name}, would you like to hit or stay?  h/s"
        player_hit_or_stay = gets.chomp
        if player_hit_or_stay.downcase == 'h'
          puts "Okay, another card for you:"
          sleep 1
          @human.deal_cards(@the_deck)
          puts "=> #{@player_name} hand:  #{@human.player_hand}"
          puts " "
          @human.calc_player_total(@the_deck)
          puts "Your total now....  #{@human.calc_player_total(@the_deck)}"
          sleep 2
        else
          break
        end
      end
      if @human.calc_player_total(@the_deck) <= WIN
        while @dealer.calc_player_total(@the_deck) < DEALER_MIN
          puts "Dealer is drawing another card..."
          @dealer.deal_cards(@the_deck)
          puts "=> dealer hand: #{@dealer.dealer_hand[1..8]}"
          @dealer.calc_player_total(@the_deck)
          sleep 1
        end
      end
      check_winner
      puts "Your final hand: #{@human.player_hand} "
      puts "Dealer final hand: #{@dealer.dealer_hand}"
      puts " - - - - "
      puts "Your final total:  #{@human.calc_player_total(@the_deck)}"
      puts "Dealer final total:  #{@dealer.calc_player_total(@the_deck)}"
      puts " - - - - - "
      puts "#{@player_name} total wins:  #{@human_total_wins}"
      puts "Dealer total wins:  #{@dealer_total_wins}"
      puts " "
      sleep 1
      break unless play_again == true
    end
    goodbye_message
  end
end

Game.new.start
