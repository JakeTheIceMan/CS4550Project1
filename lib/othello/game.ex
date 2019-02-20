defmodule Othello.Game do
  # Return a list of the indices in the board that are not border spaces.
  def valid_indices do
    Enum.map(11..89, fn(x) -> if 1 <= rem(x, 10) and rem(x, 10) <= 8 do x end end)
    |> Enum.filter(& !is_nil(&1))
  end

  # If we have nothing left to fill, return the board.
  def fill_valid_indices(board, []) do
    board
  end

  # Fill all non-border indices with empty spaces.
  def fill_valid_indices(board, [index | tail]) do
    List.replace_at(board, index, %{empty: true, color: nil})
    |> fill_valid_indices(tail)
  end

  # Return a new board.
  def init_board do
    # Establish an empty 10x10 board filled with border spaces.
    empty_board = Enum.map(1..100, fn(_) -> %{empty: false, color: "border"} end)
    # Replace the border spaces at all the non-edge indices with empty spaces,
    fill_valid_indices(empty_board, valid_indices())
    # Set up the initial four spaces in the middle for White and Black.
    |> List.replace_at(54, %{empty: false, color: "black"})
    |> List.replace_at(45, %{empty: false, color: "black"})
    |> List.replace_at(44, %{empty: false, color: "white"})
    |> List.replace_at(55, %{empty: false, color: "white"})
  end

  # Create a new game.
  def new do
    %{
      board: init_board(),
      black_turn: true
    }
  end

  # Render an element of the board for the client state.
  def render_element(el) do
    case el.color do
      "border" -> %{color: "brown"}
      "black" -> %{color: "black"}
      "white" -> %{color: "white"}
      _ -> %{color: "green"}
    end
  end

  # Return the client state.
  def client_view(game) do
    b = game.board
    |> Enum.map(fn (el) -> render_element(el) end)
    |> Enum.chunk_every(10)

    %{
      board: b,
      black_turn: game.black_turn,
      winner: winner(game)
    }
  end

  #  Return a list of all the values that, when added to an index, will create a list of all adjacent indices in the board.
  def directions do
    # The directions are, in order:
    # up, up-right, right, down-right, down, down-left, left, up-left.
    [-10, -9, 1, 11, 10, 9, -1, -11]
  end

  # Return opponent of a given player.
  def opponent(player) do
    if player == "black" do
      "white"
    else
      "black"
    end
  end

  # Find all the indices that create a line in a direction from an index of the given player.
  def find_line(square, player, board, direction) do
    # The next space in line is the current index + the given direction.
    next_in_line = square + direction
    # If the next space in the line is not occupied by an opponent,
    if Enum.at(board, next_in_line).color != opponent(player) do
      # End the line.
      [next_in_line]
    else
      # Add the next in line index to the list of indices and look at the subsequent index in the line.
      [next_in_line | find_line(next_in_line, player, board, direction)]
    end
  end

  # Determine if a line is legal.
  def line_legal(square, player, board, direction) do
    # Find the line in the direction given.
    line = find_line(square, player, board, direction)
    # Get the value at the  end of the line.
    last = List.last(line)
    # Check to see if last is an integer, if last is different than first, and that last's color is the given player's.
    is_integer(last) and last != List.first(line) and Enum.at(board, last).color == player
  end

  # Determine if a move is legal.
  def is_legal(move, player, board) do
    # Check that the space the player is trying to use is empty, and whether or not a line in any direction is legal.
    Enum.at(board, move).empty and Enum.any?(directions(), fn(dir) -> line_legal(move, player, board, dir) end)
  end

  # If we have nothing to flip, return the board.
  def flip(board, _, []) do
    board
  end

  # Flip a list of board spaces to reflect a given player.
  def flip(board, player, [index | tail]) do
    # If the space at index is occupied by the player's opponent,
    if Enum.at(board,  index).color == opponent(player) do
      # Set the space to be occupied by the player,
      List.replace_at(board, index, %{empty: false, color: player})
      # and flip the rest of the indices.
      |> flip(player, tail)
      # Otherwise,
    else
      # Flip the rest  of the spaces.
      flip(board, player, tail)
    end
  end

  # Perform a move chosen by a player.
  def do_move(move, player, board) do
    # Get a list of the spaces that need to be flipped in all directions.
    spaces = List.foldr(directions(), [], fn(dir, acc) ->
      if line_legal(move, player, board, dir) do
        acc ++ find_line(move, player, board, dir)
      else
        acc
      end
    end)
    # Fill the space that the current player is occupying.
    List.replace_at(board, move, %{empty: false, color: player})
    # Flip the rest of the spaces.
    |> flip(player, spaces)
  end

  # Given a player, check if it's their turn.
  def is_player_turn(game, player) do
    (player == "black" and game.black_turn) or (player == "white" and !game.black_turn)
  end

  # Check to see if the game is over.
  def is_game_over(game) do
    # Check if there are no legal moves that Black can make and no legal moves that White can make.
    !Enum.any?(valid_indices(), fn(i) -> is_legal(i, "black", game.board) end) and !Enum.any?(valid_indices(), fn(i) -> is_legal(i, "white", game.board) end)
  end

  # Determine who is the winner of a game.
  def winner(game) do
    # If the game isn't over, nobody is the winner.
    if !is_game_over(game) do
      "none"
    # If the game is over,
    else
      # Tally the number of spaces for each player.
      black_spaces = Enum.count(game.board, fn tile -> tile.color == "black" end)
      white_spaces = Enum.count(game.board, fn tile -> tile.color == "white" end)
      # Determine who has the most spaces, and if there's a tie, indicate so.
      cond do
        black_spaces > white_spaces -> "black"
        white_spaces > black_spaces -> "white"
        true -> "tie"
      end
    end
  end

  # Count the number of legal moves in a game for a given player.
  def legal_moves(player, game) do
    Enum.count(valid_indices, fn i -> is_legal(i, player, game.board) end)
  end

  # A player chooses a space in the board to try and occupy.
  def choose(game, row, column, player) do
    # Translate their move into a valid board index.
    move = 10 * row + column
    # If it is the player's turn and the move is legal,
    if is_player_turn(game, player) and is_legal(move, player, game.board) do
      game
      # Perform the move.
      |> Map.put(:board, do_move(move, player, game.board))
      # Change whose turn it is.
      |> Map.put(:black_turn, !game.black_turn)
      # Otherwise,
    else
      # If the player cannot perform any legal moves,
      if legal_moves(player, game) == 0 do
        # Pass the turn to the opponent.
        Map.put(game, :black_turn, !game.black_turn)
      else
        # Otherwise, let the player pick a legal move.
        game
      end
    end
  end
end
