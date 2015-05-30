class Board
  def initialize
    @board = Array.new(3) { Array.new(3, " ") }
  end

  def sample_input
    puts "1 | 2 | 3",
    "---------",
    "4 | 5 | 6",
    "---------",
    "7 | 8 | 9"
    print "\n"
  end

  def print_board
    (0..2).each do |row|
      (0..2).each do |col|
        print @board[row][col]
        print " | " unless col == 2
      end
      print "\n"
      print "---------\n" unless row == 2
    end
    print "\n"
  end

  def drop_piece(piece, row, col)
    @board[row][col] = piece if ((0..2) === row and (0..2) === col) &&  @board[row][col] === " "
  end

  def is_tie
    @board.join.split('').include?(" ")
  end

  def find_winner
    #checking row wise and column wise if any match
    (0..2).each do |i|
      if @board[i][0] == @board[i][1] && @board[i][1] == @board[i][2]
        return @board[i][0] unless @board[i][0] == " "
      elsif @board[0][i] == @board[1][i] && @board[1][i] == @board[2][i]
        return @board[0][i] unless @board[0][i] == " "
      end
    end

    #checking diagonally if any match
    if ( @board[0][0] == @board[1][1] && @board[1][1] == @board[2][2] ) ||
      ( @board[0][2] == @board[1][1] && @board[1][1] == @board[2][0] )
      return @board[1][1] unless @board[1][1] == " "
    end

    return "The game is tie" unless is_tie

    return false
  end
end


class Game
  class << self
    def move(active_player)
      puts " #{active_player}'s turn. Choose a box!"
      move = gets.chomp.to_i - 1
      row = move / 3
      col = move % 3
      return row,col
    end

    def play()
      board = Board.new
      active_player = "X"
      board.sample_input
      while not board.find_winner
        row,col = self.move(active_player)

        if board.drop_piece(active_player, row, col)
          active_player == "X" ? active_player = "O" : active_player = "X"
        else
          puts "Invalid move, please select again\n\n"
        end

        board.print_board
      end

      winner = board.find_winner
      puts "The winner of the game is #{winner}"
    end
  end
end

while true
  puts "Do you want to play again? (y/n)"
  if ["no","n"].include? (gets.chomp.downcase)
    puts "Thanks for playing"
    break
  end
  Game.play()
end
