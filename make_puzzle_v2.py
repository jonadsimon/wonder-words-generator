from semantic_neighbors import get_related_words, WordTuple
import analytics_helper_functions as ahf

import numpy as np
import random
from collections import Counter

from copy import deepcopy
import time
import subprocess

import argparse


def get_word_set_stats(words, board_size):
    board_words = [w.board for w in words]
    collisions_avoidance_matrix = np.array(ahf.get_collision_avoidance_probability_pairwise(board_words, board_size))
    tril_inds = np.tril_indices(len(words), k=-1)

    num_words = len(board_words)
    letter_excess = ahf.get_num_letters_excess(board_words)
    mean_len = ahf.get_mean_word_length(board_words)
    max_len = ahf.get_max_word_length(board_words)

    min_collision_avoidance_prob = collisions_avoidance_matrix[tril_inds].min()
    mean_collision_avoidance_prob = collisions_avoidance_matrix[tril_inds].mean()

    return num_words, letter_excess, mean_len, max_len, min_collision_avoidance_prob, mean_collision_avoidance_prob


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

    num_words, packing_level, mean_word_len, max_word_len, min_collision_avoidance_prob, mean_collision_avoidance_prob = get_word_set_stats(word_tuples[:num_words], board_size)
    print("\nWord stats:")
    print(f"    num_words: {num_words}")
    print(f"    packing_level: {packing_level:.3f}")
    print(f"    word_len (mean/max): {mean_word_len:.2f} / {max_word_len}")
    print(f"    collision_avoidance_prob (min/mean): {min_collision_avoidance_prob:.6f} / {mean_collision_avoidance_prob:.6f}")

    return word_tuples[:num_words]


def get_words_for_board_optimize(word_tuples, board_size, packing_constant=1.1):
    """Pick a cutoff which is just beyond limit of the board size."""
    # Order the words by length. It's easier to pack shorter words, so prioritize them.

    # This is SUPER hacky, should have a Word class that handles these representational differences.
    word_tuples = sorted(word_tuples, key=lambda wt: len(wt.board))
    pairwise_overlaps = ahf.get_collision_avoidance_probability_pairwise([wt.board for wt in word_tuples], board_size)

    make_word_picking_data_file(pairwise_overlaps, [wt.board for wt in word_tuples], board_size, packing_constant)

    max_word_tuple_idx_naive = (np.cumsum([len(wt.board) for wt in word_tuples]) < packing_constant * board_size**2).sum()
    word_tuples_naive = word_tuples[:max_word_tuple_idx_naive]

    num_words, packing_level, mean_word_len, max_word_len, min_collision_avoidance_prob, mean_collision_avoidance_prob = get_word_set_stats(word_tuples_naive, board_size)
    print("\nPre-optimization word stats:")
    print(f"    num_words: {num_words}")
    print(f"    packing_level: {packing_level:.3f}")
    print(f"    word_len (mean/max): {mean_word_len:.2f} / {max_word_len}")
    print(f"    collision_avoidance_prob (min/mean): {min_collision_avoidance_prob:.6f} / {mean_collision_avoidance_prob:.6f}")

    # Run the script
    p = subprocess.Popen(["/Applications/MiniZincIDE.app/Contents/Resources/minizinc", "--solver", "Chuffed", "--all-solutions", "MiniZinc_scripts/find_dense_overlap_word_subset.mzn", "tmp/pre_data.dzn"], stdout=subprocess.PIPE)
    # Wait for 30 (60) seconds, then kill the process and return the best result found thus far
    time.sleep(30)
    p.terminate()

    # Return indices of the words placed in the set

    raw_word_indices = p.stdout.read()

    # TODO: ADD FALL-BACK LOGIC FOR CASE WHEN NO IMPROVEMENT CAN BE FOUND

    if b"----------" in raw_word_indices: # Found at least one solution
        indices = [int(idx) for idx in raw_word_indices.split(b"----------")[-2].strip().split()]
        word_tuples, non_word_tuples = [wt for i,wt in enumerate(word_tuples) if i in indices], [wt for i,wt in enumerate(word_tuples) if i not in indices]
    else: # Didn't find anything
        word_tuples, non_word_tuples = word_tuples[:max_word_tuple_idx_naive], word_tuples[max_word_tuple_idx_naive:]

    removed_word_tuples = set(word_tuples_naive) - set(word_tuples)
    added_word_tuples = set(word_tuples) - set(word_tuples_naive)
    print(f"\nWords removed: {', '.join([wt.pretty for wt in removed_word_tuples])}")
    print(f"Words added: {', '.join([wt.pretty for wt in added_word_tuples])}")
    # TODO: SELECT HIDDEN WORDS FROM SUBSET OF non_word_tuples FOR FURTHER OPTIMIZATION
    #       NEED TO MAKE SURE IT'S DONE WRT SEMANITIC SIMILARITY
    #       STORE THIS INFORMATION WITHIN THE WORD OBJECT

    num_words, packing_level, mean_word_len, max_word_len, min_collision_avoidance_prob, mean_collision_avoidance_prob = get_word_set_stats(word_tuples, board_size)
    print("\nPost-optimization word stats:")
    print(f"    num_words: {num_words}")
    print(f"    packing_level: {packing_level:.3f}")
    print(f"    word_len (mean/max): {mean_word_len:.2f} / {max_word_len}")
    print(f"    collision_avoidance_prob (min/mean): {min_collision_avoidance_prob:.6f} / {mean_collision_avoidance_prob:.6f}")

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
        outfile.write(f"overlaps = [| {' | '.join([', '.join([str(int(100*x)) for x in row]) for row in pairwise_overlaps])} |];\n")


def make_data_file(board_words, board_size, strategy, filepath="tmp/data.dzn"):
    """Generated a temporary data.dzn file to pass to the minizinc script."""
    with open(filepath, "w") as outfile:
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


# TODO: Update logic so shuffling letters doesn't break board output stats
def reshuffle_words_to_fit(word_tuples_to_fit, shuffle_letters=False):
    """Within each length-class, reshuffle the words."""
    new_word_tuples_to_fit = deepcopy(word_tuples_to_fit)
    distinct_lens = set(len(wt.board) for wt in new_word_tuples_to_fit)
    for word_len in distinct_lens:
        word_inds_with_len = [i for i,wt in enumerate(new_word_tuples_to_fit) if len(wt.board) == word_len]
        random.shuffle(word_inds_with_len)
        # Relies on the fact that all words of a given length are consequtive in the list
        new_word_tuples_to_fit = new_word_tuples_to_fit[:min(word_inds_with_len)] + [new_word_tuples_to_fit[i] for i in word_inds_with_len] + new_word_tuples_to_fit[max(word_inds_with_len)+1:]
    if shuffle_letters:
        # Shuffle the letters within the words
        new_word_tuples_to_fit = [WordTuple(pretty=wt.pretty, board=''.join(random.sample(wt.board, len(wt.board)))) for wt in new_word_tuples_to_fit]
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
    # Can ALSO happen if the word is a palindrome; this is a false positive case and should be removed.
    word_locations = []
    word_deltas = []
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
                        # Before adding it, check that it's not a palindromic duplicate.
                        new_loc = [(y+i*dy, x+i*dx) for i in range(len(word))]
                        if all(sorted(loc) != sorted(new_loc) for loc in word_locations):
                            word_locations.append(new_loc)
                            word_deltas.append((dy,dx))
    return word_locations, word_deltas


# TODO: Break apart this logic to separately identify (1) positions/delta, (2) dupicates, (3) cover-ups
#       As is, things are WAY too convolutedly interacting.
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
    word_locations_on_board, word_deltas_on_board = zip(*[find_word_in_board(board, wt.board) for wt in word_tuples])
    flattened_deltas = [d for deltas in word_deltas_on_board for d in deltas]

    covered_up_words = []
    doubled_up_words = []
    for i, wt in enumerate(word_tuples):
        if len(word_locations_on_board[i]) == 0:
            raise ValueError(f"word '{wt.board}' does not appear in the board, something has gone HORRIBLY wrong")
        if len(word_locations_on_board[i]) > 1:
            doubled_up_words.append(wt)
            continue
        # Check if word is covered-up or not. Only bother checking words that appear once.
        w1_letter_positions_remaining = word_locations_on_board[i][0][:]
        for j, wt2 in enumerate(word_tuples):
            if i == j:
                continue
            # For only bother checking first-occurrence of other words, since if they have > 1 occurrece,
            # it means there exists a duplicate and the whole board will be thrown out regardless.
            for loc in word_locations_on_board[j][0]:
                if loc in w1_letter_positions_remaining:
                    w1_letter_positions_remaining = [pos for pos in w1_letter_positions_remaining if pos != loc]
        if not w1_letter_positions_remaining:
            covered_up_words.append(wt)
    return covered_up_words, doubled_up_words, flattened_deltas


def make_puzzle(topic, board_size, packing_constant, strategy, optimize_words, relatedness_cutoff, shuffle_letters, n_proc=4):
    word_tuples, hidden_word_tuple_dict = get_related_words(topic, relatedness_cutoff)
    if optimize_words:
        word_tuples_to_fit = get_words_for_board_optimize(word_tuples, board_size, packing_constant)
    else:
        word_tuples_to_fit = get_words_for_board(word_tuples, board_size, packing_constant)

    print("\n", [wt.pretty for wt in word_tuples_to_fit], "\n", sep="")
    print({l: wt.pretty for l,wt in hidden_word_tuple_dict.items()}, "\n")

    # Spawn n processes at a time, each with a different permutation of the words.
    # For each process, let them run until 'timeout', and check each for completion.
    # If any have completed, grab it as the one-and-only solution.
    # If none have completed, permute them all and try again.
    # Question: make new data files for use, or reuse the same one repeatedly?
    # Answer: write a separate file for each to avoid needed to juggle read/write times

    board_found = False
    max_retries = 10
    retries = 0
    timeout = 10
    while retries < max_retries and not board_found:

        for i in range(n_proc):
            # Shuffle words separately for each run.
            word_tuples_to_fit = reshuffle_words_to_fit(word_tuples_to_fit, shuffle_letters=shuffle_letters)
            # Generate Minizinc data file to feed into the parameterizd script.
            make_data_file([wt.board for wt in word_tuples_to_fit], board_size, strategy, f"tmp/data{i+1}.dzn")

        # Run the script
        cmd = ["/Applications/MiniZincIDE.app/Contents/Resources/minizinc", "--solver", "Chuffed", "MiniZinc_scripts/parameterized_board_generator.mzn"]
        ps = [subprocess.Popen(cmd + [f"tmp/data{i+1}.dzn"], stdout=subprocess.PIPE) for i in range(n_proc)]

        time.sleep(timeout)

        # Indices of finished processes
        finished_proc_inds = [i for i,p in enumerate(ps) if p.poll() is not None]

        # None of the processes finished, therefore kill all of them and continue
        if not finished_proc_inds:
            for p in ps:
                p.terminate()
            retries += 1
            print(f"Attempt {retries} failed" + (", trying again\n" if retries < max_retries else ", terminating...\n"))
            continue

        # If made it here, implies that at least one of the processes finished successfully.
        # Therefore grab the result, and kill the unfinished processes.
        finished_proc = ps[finished_proc_inds[0]]
        for i,p in enumerate(ps):
            if i not in finished_proc_inds:
                p.terminate()

        raw_board = finished_proc.stdout.read()
        raw_board = raw_board.split(b"\n\n")[0] # remove the trailing non-board characters

        # Four possibilities for each word:
        # 1) Word doesn't appear on board at all --> error
        # 2) Word appears on board once, and at least 1 letter is uncovered --> ok
        # 3) Word appears on board once, and is completely covered --> issue warning & remove word
        # 4) Word appears on board more than once --> issue warning & generate new board
        # TODO FOR LATER: EDGE-CASE WHERE REMOVING ONE OVERLAPPING WORD RENDERS ANOTHER NON-OVERLAPPING
        # TODO FOR LATER: ANOTHER EDGE-CASE WHERE A WORD GETS ADDED WHEN THE HIDDEN LETTERS GET FILLED IN
        board = [line.strip().split() for line in raw_board.decode("utf-8").strip().split("\n")] # THIS IS REDUNDANT
        covered_up_words, doubled_up_words, deltas = find_words_in_board(board, word_tuples_to_fit)
        # If word appears multiple times, print a warning and try again
        if doubled_up_words:
            print(f"\nwords appear more than once so board will be regenerated: {', '.join([wt.pretty for wt in doubled_up_words])}\n")

            # THIS WHOLE BLOCK IS REDUNANT WITH CONTENTS OF "if p.poll() is None:" BLOCK ABOVE
            # UNIFY THE LOGIC, THINGS ARE GETTING TOO MESSY
            retries += 1
            # word_tuples_to_fit, hidden_word_tuple_dict = reshuffle_hidden_words(word_tuples_to_fit, hidden_word_tuple_dict)
            word_tuples_to_fit = reshuffle_words_to_fit(word_tuples_to_fit)

            print("\n", [wt.pretty for wt in word_tuples_to_fit], "\n", sep="")
            print({l: wt.pretty for l,wt in hidden_word_tuple_dict.items()}, "\n")

            continue
        # Remove any covered-up words from the word set
        if covered_up_words:
            print(f"\nwords are completely covered-up and will marked with an asterisk: {', '.join([wt.pretty for wt in covered_up_words])}\n")
            # word_tuples_to_fit = [wt for wt in word_tuples_to_fit if wt not in covered_up_words]

        board_found = True

    if not board_found:
        raise ValueError(f"MiniZinc couldn't find a board after {max_retries} retries")

    board = [line.strip().split() for line in raw_board.decode("utf-8").strip().split("\n")]
    blank_locs = [(i,j) for i,row in enumerate(board) for j,letter in enumerate(row) if letter == "_"]
    # If number of blanks is exactly 0, no special word is needed
    if len(blank_locs) not in hidden_word_tuple_dict and len(blank_locs) != 0:
        raise ValueError(f"Number of remaining blanks does not fit any available word: {len(blank_locs)}")
    k = 0
    for i, j in blank_locs:
        board[i][j] = hidden_word_tuple_dict[len(blank_locs)].board[k]
        k += 1
    delta_cntr = Counter(deltas)

    if shuffle_letters:
        print("WARNING: shuffle-letters is on, therefore fwd/bwd statistics are unreliable")

    print(f"\nhorizontal (fwd/bwd): {delta_cntr[(0,1)]}/{delta_cntr[(0,-1)]}")
    print(f"vertical (fwd/bwd): {delta_cntr[(1,0)]}/{delta_cntr[(-1,0)]}")
    print(f"diagonal du (fwd/bwd): {delta_cntr[(-1,1)]}/{delta_cntr[(1,-1)]}")
    print(f"diagonal ud (fwd/bwd): {delta_cntr[(1,1)]}/{delta_cntr[(-1,-1)]}\n")
    # Print the topic above the board
    print(f"\nTopic:  {' / '.join(topic)}\n\n")
    for row in board:
        print(" ".join(row))
    word_tuples_to_print = sorted(word_tuples_to_fit, key=lambda wt: wt.pretty)
    print("\n\n", "   ".join(["ˣ" + wt.pretty + "ˣ" if wt in covered_up_words else wt.pretty for wt in word_tuples_to_print]), sep="")


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
    parser.add_argument("--relatedness-cutoff", type=float, default=0.45,
                        help="How closely a word must be semantically related to be included in the word set (default=0.45)")
    parser.add_argument("--shuffle-letters", type=bool, default=False, action=argparse.BooleanOptionalAction,
                        help="Shuffle the letters within the words in addition to their order (default=False)")
    args = parser.parse_args()

    # Can't find solutions for words: 'flamboyant', 'coffee', 'dishwasher'

    random.seed(0)
    make_puzzle(args.topic, args.board_size, args.packing_constant, args.strategy, args.optimize_words, args.relatedness_cutoff, args.shuffle_letters)
