from semantic_neighbors import get_related_words

import numpy as np
import random
from collections import Counter

import subprocess

def get_words_for_board(words, board_size, packing_constant=1.1):
    """Pick a cutoff which is just beyond limit of the board size."""
    # Order the words by length. It's easier to pack shorter words, so prioritize them.

    # This is SUPER hacky, should have a Word class that handles these representational differences.
    words = sorted(words, key=lambda w: len(w.replace(" ", "").replace("-", "")))
    cum_len = np.cumsum([len(word.replace(" ", "").replace("-", "")) for word in words])
    num_words = None
    for word_idx, cum_letters in enumerate(cum_len):
        # Try to pack in slightly more letters than would fit on the word without overlaps,
        # as governed by the packing constant.
        if cum_letters > packing_constant * board_size**2:
            num_words = word_idx
            break
    if not num_words:
        raise ValueError(f"Too few semantic neighbor words to pack a {board_size}x{board_size} board.")
    return words[:num_words]

def make_data_file(board_words, board_size):
    """Generated a temporary data.dzn file to pass to the minizinc script."""
    with open("tmp/data.dzn", "w") as outfile:
        outfile.write(f"n = {board_size};\n")
        outfile.write(f"m = {len(board_words)};\n\n")
        outfile.write(f"max_len = {max([len(word) for word in board_words])};\n")
        outfile.write(f"word_lens = [ {', '.join([str(len(word)) for word in board_words])} ];\n")
        # ADDING THE BUFFER LIKE THIS IS HACKY, MAKE IT CLEANER
        outfile.write(f"words = [| {' | '.join([', '.join(word + 'E'*(len(board_words[-1])-len(word))) for word in board_words])} |];\n")

def make_puzzle(topic, board_size=20):
    words, hidden_word_dict = get_related_words(topic)
    words_to_fit = get_words_for_board(words, board_size, 1.10)
    board_words = [word.replace(" ", "").replace("-", "").upper() for word in words_to_fit]

    print(words_to_fit)
    print(hidden_word_dict)

    # Generate Minizinc data file to feed into the parameterizd script.
    make_data_file(board_words, board_size)

    # Run the script
    raw_board = subprocess.Popen("/Applications/MiniZincIDE.app/Contents/Resources/minizinc --solver Chuffed MiniZinc_scripts/parameterized_board_generator.mzn tmp/data.dzn", shell=True, stdout=subprocess.PIPE).stdout.read()

    board = [line.strip().split() for line in raw_board.decode("utf-8").strip().split("\n")]
    blank_locs = [(i,j) for i,row in enumerate(board) for j,letter in enumerate(row) if letter == "_"]
    if len(blank_locs) not in hidden_word_dict:
        print(len(blank_locs), blank_locs)
        print(hidden_word_dict)
        raise ValueError("Number of remaining blanks does not fit any available word.")
    k = 0
    for i, j in blank_locs:
        board[i][j] = hidden_word_dict[len(blank_locs)][k]
        k += 1
    for row in board:
        print(" ".join(row))
    print("\n", "   ".join(sorted(words_to_fit)))

if __name__ == "__main__":
    make_puzzle("flamboyant", 15)
