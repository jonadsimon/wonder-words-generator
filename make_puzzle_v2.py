from semantic_neighbors import get_related_words
import analytics_helper_functions as ahf

import numpy as np
import random
from collections import Counter

from copy import deepcopy
import time
import subprocess

import argparse
import warnings

# TODO: CLEAN UP THIS MESS OF A FUNCTION
def get_word_set_stats(words):
    board_words = [w.board for w in words]

    num_words = len(board_words)
    letter_excess = ahf.get_num_letters_excess(board_words)
    mean_len = ahf.get_mean_word_length(board_words)
    total_overlaps = ahf.get_num_overlaps_total(board_words)

    return num_words, letter_excess, mean_len, total_overlaps

# REPLACE WITH WORD-LENGTH NORMALIZED OVERLAP MEASURES
def enrich_word_set(chosen_word_tuples, extra_word_tuples, max_mean_word_len=5.5):

    num_words, letter_excess, mean_len, total_overlaps = get_word_set_stats(chosen_word_tuples)
    print(f"\nInitial stats: num_words={num_words}, letter_excess={letter_excess:.2f}, mean_len={mean_len:.2f}, total_overlaps={total_overlaps}")

    # Rather than hard-coding a static max_mean_word_len, make it a function of what we started with
    # max_mean_word_len = 1.1 * mean_len

    while True:
        # Find least-overlapping word in the set

        per_word_overlaps = [ahf.get_num_overlaps_per_word(wt.board, [wt.board for wt in chosen_word_tuples]) for wt in chosen_word_tuples]
        least_overlapping_word_idx = np.argmin(per_word_overlaps)
        least_overlapping_word = chosen_word_tuples[least_overlapping_word_idx]

        chosen_word_tuples = chosen_word_tuples[:least_overlapping_word_idx] + chosen_word_tuples[least_overlapping_word_idx+1:]
        extra_word_tuples = [least_overlapping_word] + extra_word_tuples

        per_word_overlaps = [ahf.get_num_overlaps_per_word(wt.board, [wt.board for wt in chosen_word_tuples]) for wt in extra_word_tuples]
        most_overlapping_word_idx = np.argmax(per_word_overlaps)
        most_overlapping_word = extra_word_tuples[most_overlapping_word_idx]

        chosen_word_tuples = chosen_word_tuples + [most_overlapping_word]
        extra_word_tuples = extra_word_tuples[:most_overlapping_word_idx] + extra_word_tuples[most_overlapping_word_idx+1:]

        num_words, letter_excess, mean_len, total_overlaps = get_word_set_stats(chosen_word_tuples)
        print(f"\nRemoved: '{least_overlapping_word.pretty}', Added: '{most_overlapping_word.pretty}'")
        print(f"Enriched stats: num_words={num_words}, letter_excess={letter_excess:.2f}, mean_len={mean_len:.2f}, total_overlaps={total_overlaps}")

        if least_overlapping_word == most_overlapping_word:
            print("\nRedundant transposition --> break")
            break

        if mean_len > max_mean_word_len:
            print("\nPassed max_mean_word_len --> break")
            break

    return chosen_word_tuples


def get_words_for_board(word_tuples, board_size, packing_constant=1.1, max_word_len=8):
    """Pick a cutoff which is just beyond limit of the board size."""
    # Order the words by length. It's easier to pack shorter words, so prioritize them.

    # This is SUPER hacky, should have a Word class that handles these representational differences.
    word_tuples = sorted(word_tuples, key=lambda wt: len(wt.board))

    # Discard words that are too long to fit on the board
    # word_tuples = [wt for wt in word_tuples if len(wt.board) <= max_word_len]

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

    # chosen_word_tuples = enrich_word_set(word_tuples[:num_words], word_tuples[num_words:])
    # return sorted(chosen_word_tuples, key=lambda wt: len(wt.board))

    num_words, packing_level, mean_word_len, total_overlap = get_word_set_stats(word_tuples[:num_words])
    print("\nWord stats:")
    print(f"    num_words: {num_words}")
    print(f"    packing_level: {packing_level:.3f}")
    print(f"    mean_word_len: {mean_word_len:.2f}")
    print(f"    total_overlap: {total_overlap}")

    return word_tuples[:num_words]

def get_words_for_board_optimize(word_tuples, board_size, packing_constant=1.1):
    """Pick a cutoff which is just beyond limit of the board size."""
    # Order the words by length. It's easier to pack shorter words, so prioritize them.

    # This is SUPER hacky, should have a Word class that handles these representational differences.
    word_tuples = sorted(word_tuples, key=lambda wt: len(wt.board))
    pairwise_overlaps = ahf.get_overlaps_pairwise([wt.board for wt in word_tuples])

    make_word_picking_data_file(pairwise_overlaps, [wt.board for wt in word_tuples], board_size, packing_constant)

    max_word_tuple_idx_naive = (np.cumsum([len(wt.board) for wt in word_tuples]) < packing_constant * board_size**2).sum()
    word_tuples_naive = word_tuples[:max_word_tuple_idx_naive]

    num_words, packing_level, mean_word_len, total_overlap = get_word_set_stats(word_tuples_naive)
    print("\nPre-optimization word stats:")
    print(f"    num_words: {num_words}")
    print(f"    packing_level: {packing_level:.3f}")
    print(f"    mean_word_len: {mean_word_len:.2f}")
    print(f"    total_overlap: {total_overlap}")

    # Run the script
    p = subprocess.Popen(["/Applications/MiniZincIDE.app/Contents/Resources/minizinc", "--solver", "Chuffed", "--all-solutions", "MiniZinc_scripts/find_dense_overlap_word_subset.mzn", "tmp/pre_data.dzn"], stdout=subprocess.PIPE)
    # Wait for 30 (60) seconds, then kill the process and return the best result found thus far
    time.sleep(30)
    p.terminate()

    # Return indices of the words placed in the set

    raw_word_indices = p.stdout.read()

    # TODO: ADD FALL-BACK LOGIC FOR CASE WHEN NO IMPROVEMENT CAN BE FOUND

    indices = [int(idx) for idx in raw_word_indices.split(b"----------")[-2].strip().split()]
    word_tuples, non_word_tuples = [wt for i,wt in enumerate(word_tuples) if i in indices], [wt for i,wt in enumerate(word_tuples) if i not in indices]

    removed_word_tuples = set(word_tuples_naive) - set(word_tuples)
    added_word_tuples = set(word_tuples) - set(word_tuples_naive)
    print(f"\nWords removed: {', '.join([wt.pretty for wt in removed_word_tuples])}")
    print(f"Words added: {', '.join([wt.pretty for wt in added_word_tuples])}")
    # TODO: SELECT HIDDEN WORDS FROM SUBSET OF non_word_tuples FOR FURTHER OPTIMIZATION
    #       NEED TO MAKE SURE IT'S DONE WRT SEMANITIC SIMILARITY
    #       STORE THIS INFORMATION WITHIN THE WORD OBJECT

    num_words, packing_level, mean_word_len, total_overlap = get_word_set_stats(word_tuples)
    print("\nPost-optimization word stats:")
    print(f"    num_words: {num_words}")
    print(f"    packing_level: {packing_level:.3f}")
    print(f"    mean_word_len: {mean_word_len:.2f}")
    print(f"    total_overlap: {total_overlap}")

    return word_tuples


def make_word_picking_data_file(pairwise_overlaps, board_words, board_size, packing_constant):
    """Generated a temporary data.dzn file to pass to the minizinc script."""
    with open("tmp/pre_data.dzn", "w") as outfile:
        outfile.write(f"n = {board_size};\n")
        outfile.write(f"m = {len(board_words)};\n")
        outfile.write(f"p = {packing_constant};\n\n")
        outfile.write(f"word_lens = [ {', '.join([str(len(word)) for word in board_words])} ];\n")
        outfile.write(f"""words = [ {', '.join(['"'+word+'"' for word in board_words])} ];\n\n""")
        # outfile.write(f"overlaps = [| {' | '.join([', '.join([str(round(x,3)) for x in row]) for row in pairwise_overlaps])} |];\n")
        outfile.write(f"overlaps = [| {' | '.join([', '.join([str(int(1000*x)) for x in row]) for row in pairwise_overlaps])} |];\n")


def make_data_file(board_words, board_size, strategy):
    """Generated a temporary data.dzn file to pass to the minizinc script."""
    with open("tmp/data.dzn", "w") as outfile:
        outfile.write(f"n = {board_size};\n")
        outfile.write(f"m = {len(board_words)};\n\n")
        outfile.write(f"max_len = {max([len(word) for word in board_words])};\n")
        outfile.write(f"word_lens = [ {', '.join([str(len(word)) for word in board_words])} ];\n")
        # ADDING THE BUFFER LIKE THIS IS HACKY, MAKE IT CLEANER
        outfile.write(f"words = [| {' | '.join([', '.join(word + 'E'*(len(board_words[-1])-len(word))) for word in board_words])} |];\n\n")
        # Add the search strategy conditional on the input strategy
        if strategy == "min":
            pos_var_strat = "smallest"
            pos_val_strat = "indomain_min"
        elif strategy == "median":
            pos_var_strat = "first_fail"
            pos_val_strat = "indomain_median"
        elif strategy == "max":
            pos_var_strat = "largest"
            pos_val_strat = "indomain_max"
        else:
            raise ValueError(f"Search strategy must be one of 'min', 'median', 'max'. Received value: 'f{strategy}'")
        outfile.write(f"pos_var_strat = {pos_var_strat};\n")
        outfile.write(f"pos_val_strat = {pos_val_strat};\n")

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

def reshuffle_words_to_fit(word_tuples_to_fit):
    """Within each length-class, reshuffle the words."""
    new_word_tuples_to_fit = deepcopy(word_tuples_to_fit)
    distinct_lens = set(len(wt.board) for wt in new_word_tuples_to_fit)
    for word_len in distinct_lens:
        word_inds_with_len = [i for i,wt in enumerate(new_word_tuples_to_fit) if len(wt.board) == word_len]
        random.shuffle(word_inds_with_len)
        # Relies on the fact that all words of a given length are consequtive in the list
        new_word_tuples_to_fit = new_word_tuples_to_fit[:min(word_inds_with_len)] + [new_word_tuples_to_fit[i] for i in word_inds_with_len] + new_word_tuples_to_fit[max(word_inds_with_len)+1:]
    return new_word_tuples_to_fit

def find_word_in_board(board, word):
    """Find word in the board manually rather than taking them as output from MiniZinc because
    MiniZinc does not notice when the same word has been added to the board twice.

    Returns a list of lists of tuples.
    Each sublist encodes one instance of the word on the board.
    Each tuple encodes the coordinates of a letter within the word.

    Typically the top-level list will have only one element, since each word is
    only supposed to appear on the board once.
    """
    # Can be >1 location if the word was added to the board in multiple places.
    word_locations = []
    for y in range(len(board)):
        for x in range(len(board)):
            for dy in (-1,0,1):
                for dx in (-1,0,1):
                    if dy == 0 and dx == 0:
                        continue
                    implied_word = ""
                    for i in range(len(word)):
                        if 0 <= y+i*dy < len(board) and 0 <= x+i*dx < len(board):
                            implied_word += board[y+i*dy][x+i*dx]
                        else:
                            break # if word runs off the edge, it's automoatically wrong
                    if implied_word == word:
                        word_locations.append([(y+i*dy, x+i*dx) for i in range(len(word))])
    return word_locations


def find_words_in_board(board, word_tuples):
    """Find word in the board manually rather than taking them as output from MiniZinc because
    MiniZinc does not notice when the same word has been added to the board twice.

    Four possibilities for each word:
    1) Word doesn't appear on board at all --> error
    2) Word appears on board once, and at least 1 letter is uncovered --> ok
    3) Word appears on board once, and is completely covered --> issue warning & remove word
    4) Word appears on board more than once --> issue warning & generate new board

    Return the words satisfying the different conditions
    """
    word_locations_on_board =  [find_word_in_board(board, wt.board) for wt in word_tuples]

    covered_up_words = []
    doubled_up_words = []
    for i, wt in enumerate(word_tuples):
        if len(word_locations_on_board[i]) == 0:
            raise ValueError(f"word '{wt.board}' does not appear in the board, something has gone HORRIBLY wrong")
        if len(word_locations_on_board[i]) > 1:
            doubled_up_words.append(wt)
            continue
        # Check if word is covered-up or not. Only bother checking words that appear once.
        w1_letter_positions_remaining = word_locations_on_board[i][:]
        for j, wt2 in enumerate(word_tuples):
            if i == j:
                continue
            for loc in word_locations_on_board[j][0]:
                if loc in w1_letter_positions_remaining:
                    w1_letter_positions_remaining = [pos for pos in w1_letter_positions_remaining if pos != loc]
            if not w1_letter_positions_remaining:
                covered_up_words.append(wt)
    return doubled_up_words, covered_up_words


def make_puzzle(topic, board_size, packing_constant, strategy, optimize_words):
    word_tuples, hidden_word_tuple_dict = get_related_words(topic)
    if optimize_words:
        word_tuples_to_fit = get_words_for_board_optimize(word_tuples, board_size, packing_constant)
    else:
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
    max_retries = 10
    retries = 0
    timeout = 10
    while retries < max_retries and not board_found:

        # Generate Minizinc data file to feed into the parameterizd script.
        make_data_file([wt.board for wt in word_tuples_to_fit], board_size, strategy)

        # Run the script
        p = subprocess.Popen(["/Applications/MiniZincIDE.app/Contents/Resources/minizinc", "--solver", "Chuffed", "MiniZinc_scripts/parameterized_board_generator.mzn", "tmp/data.dzn"], stdout=subprocess.PIPE)
        time.sleep(timeout)
        if p.poll() is None:
            # process is still running, so kill it, increment retries, shuffle the words, and continue
            p.terminate()
            retries += 1
            # word_tuples_to_fit, hidden_word_tuple_dict = reshuffle_hidden_words(word_tuples_to_fit, hidden_word_tuple_dict)
            word_tuples_to_fit = reshuffle_words_to_fit(word_tuples_to_fit)

            print("\n", [wt.pretty for wt in word_tuples_to_fit], "\n", sep="")
            print({l: wt.pretty for l,wt in hidden_word_tuple_dict.items()}, "\n")

            continue

        raw_board = p.stdout.read()
        raw_board = raw_board.split(b"\n\n")[0] # remove the trailing non-board characters

        # Four possibilities for each word:
        # 1) Word doesn't appear on board at all --> error
        # 2) Word appears on board once, and at least 1 letter is uncovered --> ok
        # 3) Word appears on board once, and is completely covered --> issue warning & remove word
        # 4) Word appears on board more than once --> issue warning & generate new board
        # TODO FOR LATER: EDGE-CASE WHERE REMOVING ONE OVERLAPPING WORD RENDERS ANOTHER NON-OVERLAPPING
        # TODO FOR LATER: ANOTHER EDGE-CASE WHERE A WORD GETS ADDED WHEN THE HIDDEN LETTERS GET FILLED IN
        board = [line.strip().split() for line in raw_board.decode("utf-8").strip().split("\n")] # THIS IS REDUNDANT
        covered_up_words, doubled_up_words = find_words_in_board(board, word_tuples_to_fit)
        # If word appears multiple times, print a warning and try again
        if doubled_up_words:
            # warnings.warn(f"\nwords appear more than once on the board: {', '.join([wt.pretty for wt in doubled_up_words])}\nboard will be discarded and regenerated\n")
            print(f"\nwords appear more than once on the board and will be regenerated: {', '.join([wt.pretty for wt in doubled_up_words])}\n")
            continue
        # Remove any covered-up words from the word set
        if covered_up_words:
            # warnings.warn(f"\nwords are completely covered-up: {', '.join([wt.pretty for wt in covered_up_words])}\nwords will be removed from the displayed list\n")
            print(f"\nwords are completely covered-up and will be removed from the displayed list: {', '.join([wt.pretty for wt in covered_up_words])}\n")
            word_tuples_to_fit = [wt for wt in word_tuples_to_fit if wt not in covered_up_words]

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
    print(f"\nTopic:  {' / '.join(topic)}\n\n")
    for row in board:
        print(" ".join(row))
    print("\n\n", "   ".join(sorted([wt.pretty for wt in word_tuples_to_fit])), sep="")

if __name__ == "__main__":
    # Parse the arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("topic", type=str, nargs='+',
                        help="Topic for the words; can be one string or multiple strings")
    parser.add_argument("--board-size", type=int, default=15,
                        help="Size of the board to fill (default=15)")
    parser.add_argument("--packing-constant", type=float, default=1.10,
                        help="Ratio of total letters to # board squares (default=1.10)")
    parser.add_argument("--strategy", type=str, default="median",
                        help="Search strategy to use, one of 'min', 'median', 'max' (default='median')")
    parser.add_argument("--optimize-words", type=bool, default=False, action=argparse.BooleanOptionalAction,
                        help="Optimize the word distribution for letter-overlaps in advance (default=False)")
    args = parser.parse_args()

    # make_puzzle("flamboyant", 15, 1.05)
    # make_puzzle("coffee", 15, 1.10)
    # make_puzzle("dishwasher", 15, 1.10) # can't find ANYTHING
    make_puzzle(args.topic, args.board_size, args.packing_constant, args.strategy, args.optimize_words)
