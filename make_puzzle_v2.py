from semantic_neighbors import get_related_words

import numpy as np
import random
from collections import Counter

from copy import deepcopy
import time
import subprocess

import argparse

def get_words_for_board(word_tuples, board_size, packing_constant=1.1):
    """Pick a cutoff which is just beyond limit of the board size."""
    # Order the words by length. It's easier to pack shorter words, so prioritize them.

    # This is SUPER hacky, should have a Word class that handles these representational differences.
    word_tuples = sorted(word_tuples, key=lambda wt: len(wt.board))
    cum_len = np.cumsum([len(wt.board) for wt in word_tuples])
    num_words = None
    for word_idx, cum_letters in enumerate(cum_len):
        # Try to pack in slightly more letters than would fit on the word without overlaps,
        # as governed by the packing constant.
        if cum_letters > packing_constant * board_size**2:
            num_words = word_idx
            break
    if not num_words:
        raise ValueError(f"Too few semantic neighbor words to pack a {board_size}x{board_size} board.")
    return word_tuples[:num_words]

def make_data_file(board_words, board_size):
    """Generated a temporary data.dzn file to pass to the minizinc script."""
    with open("tmp/data.dzn", "w") as outfile:
        outfile.write(f"n = {board_size};\n")
        outfile.write(f"m = {len(board_words)};\n\n")
        outfile.write(f"max_len = {max([len(word) for word in board_words])};\n")
        outfile.write(f"word_lens = [ {', '.join([str(len(word)) for word in board_words])} ];\n")
        # ADDING THE BUFFER LIKE THIS IS HACKY, MAKE IT CLEANER
        outfile.write(f"words = [| {' | '.join([', '.join(word + 'E'*(len(board_words[-1])-len(word))) for word in board_words])} |];\n")

def reshuffle_hidden_words(word_tuples_to_fit, hidden_word_tuple_dict):
    # things have become very wordy... reduce the verbosity
    new_hidden_word_tuple_dict = {}
    new_word_tuples_to_fit = deepcopy(word_tuples_to_fit)
    for num_letters, hidden_word_tuple in hidden_word_tuple_dict.items():
        new_hidden_word_tuples = [wt for wt in word_tuples_to_fit if len(wt.board) == num_letters]
        new_hidden_word_tuple = random.sample(new_hidden_word_tuples + [hidden_word_tuple], 1)[0]
        new_hidden_word_tuple_dict.update({num_letters: new_hidden_word_tuple})
        new_word_tuples_to_fit = [wt if wt != new_hidden_word_tuple else hidden_word_tuple for wt in new_word_tuples_to_fit]
    return new_word_tuples_to_fit, new_hidden_word_tuple_dict

def make_puzzle(topic, board_size=20, packing_constant=1.10):
    word_tuples, hidden_word_tuple_dict = get_related_words(topic)
    word_tuples_to_fit = get_words_for_board(word_tuples, board_size, packing_constant)
    # words, hidden_word_dict = get_related_words(topic)
    # words_to_fit = get_words_for_board(words, board_size, 1.10)
    # board_words = [word.replace(" ", "").replace("-", "").upper() for word in words_to_fit]

    print("\n", [wt.pretty for wt in word_tuples_to_fit], "\n", sep="")
    print({l: wt.pretty for l,wt in hidden_word_tuple_dict.items()}, "\n")

    # # Generate Minizinc data file to feed into the parameterizd script.
    # make_data_file([wt.board for wt in word_tuples_to_fit], board_size)
    #
    # # Run the script
    # raw_board = subprocess.Popen("/Applications/MiniZincIDE.app/Contents/Resources/minizinc --solver Chuffed MiniZinc_scripts/parameterized_board_generator.mzn tmp/data.dzn", shell=True, stdout=subprocess.PIPE).stdout.read()

    board_found = False
    max_retries = 5
    retries = 0
    timeout = 5
    while retries < max_retries and not board_found:

        # Generate Minizinc data file to feed into the parameterizd script.
        make_data_file([wt.board for wt in word_tuples_to_fit], board_size)

        # Run the script
        p = subprocess.Popen(["/Applications/MiniZincIDE.app/Contents/Resources/minizinc", "--solver", "Chuffed", "MiniZinc_scripts/parameterized_board_generator.mzn", "tmp/data.dzn"], stdout=subprocess.PIPE)
        time.sleep(timeout)
        if p.poll() is None:
            # process is still running, so kill it, increment retries, shuffle the words, and continue
            p.terminate()
            retries += 1
            word_tuples_to_fit, hidden_word_tuple_dict = reshuffle_hidden_words(word_tuples_to_fit, hidden_word_tuple_dict)

            print("\n", [wt.pretty for wt in word_tuples_to_fit], "\n", sep="")
            print({l: wt.pretty for l,wt in hidden_word_tuple_dict.items()}, "\n")

            continue

        raw_board = p.stdout.read()
        raw_board = raw_board.split(b"\n\n")[0] # remove the trailing non-board characters

        board_found = True

    if not board_found:
        raise ValueError(f"MiniZinc couldn't find a board after {max_retries} retries")

    board = [line.strip().split() for line in raw_board.decode("utf-8").strip().split("\n")]
    blank_locs = [(i,j) for i,row in enumerate(board) for j,letter in enumerate(row) if letter == "_"]
    # If number of blanks is exactly 0, no special word is needed
    if len(blank_locs) not in hidden_word_tuple_dict and len(blank_locs) != 0:
        print(len(blank_locs), blank_locs)
        print(hidden_word_tuple_dict)
        raise ValueError("Number of remaining blanks does not fit any available word.")
    k = 0
    for i, j in blank_locs:
        board[i][j] = hidden_word_tuple_dict[len(blank_locs)].board[k]
        k += 1
    # Print the topic above the board
    print(f"Topic: {topic}\n\n")
    for row in board:
        print(" ".join(row))
    print("\n\n", "   ".join(sorted([wt.pretty for wt in word_tuples_to_fit])), sep="")

if __name__ == "__main__":
    # Parse the arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('topic', type=str,
                        help='Topic for the words')
    parser.add_argument('--board_size', type=int, default=15,
                        help='Size of the board to fill (default=15)')
    parser.add_argument('--packing_constant', type=float, default=1.10,
                        help='Ratio of total letters to # board squares (default=1.10)')
    args = parser.parse_args()

    # make_puzzle("flamboyant", 15, 1.05)
    # make_puzzle("coffee", 15, 1.10)
    make_puzzle(args.topic, args.board_size, args.packing_constant)
