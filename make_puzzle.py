import time
import random
from board import Board

# Will also need to pass in 'special word' and 'num words' along with 'board size'

def make_puzzle():
    global words
    # Words from 'rainforest' input here https://relatedwords.org/relatedto/rainforest
    words = ['rain', 'tree', 'vine', 'bird', 'biome', 'snake', 'earth', 'fauna', 'eagle', 'plant', 'swamp', 'flora', 'forest', 'jungle', 'oxygen', 'canopy', 'amazon', 'monkey', 'jaguar', 'brazil', 'branch', 'boreal', 'carbon', 'acacia', 'species', 'america', 'equator', 'savanna', 'monsoon', 'montane', 'tropics', 'tropical', 'medicine', 'woodland', 'mangrove', 'habitats', 'malaysia', 'wetlands', 'wildlife', 'peatland', 'temperate', 'indonesia', 'woodlands', 'shrubland', 'australia', 'vegetation', 'coniferous', 'eucalyptus', 'grasslands', 'ecosystems', 'madagascar', 'undergrowth', 'plantations', 'biodiversity', 'deforestation', 'photosynthesis']

    # For each word-length in words, grab 1 "special" representative, so if the final board is that length then the representative can be used
    global special_words_dict
    special_words_dict = {}
    for word in words:
        if len(word) not in special_words_dict:
            special_words_dict[len(word)] = word
    # Remove these special words from the standard words dict
    words = [word for word in words if word not in special_words_dict.values()]

    words = words[:10] # grab the 10 shortest words; grab num words proportional to board size
    random.shuffle(words) # shuffle the order

    # To improve flexibility, allow the special words to be any from a set of words of varying length from ~4-12
    global board
    board = Board(7)

    global solution_found
    solution_found = [False]

    print(time.time())
    place_word(0) # kick off the recursion

    # print(board)
    # print(words) <-- alphabetically

    for i, word in enumerate(words):
        if i % 10 == 0:
            print()
        print(word, end='   ')

    # add final special word to the board, either here or in the recursive function (probably here?)

    # if successful final board is found, pass a terminating condition all the way up the stack to kill it; maybe pass back the full result too?

# CORE RECURSIVE FUNCTION
# is_done usage is super janky, clean this up
def place_word(word_idx, is_done=False):
    # All words have been placed on the board; check whether the correct number of spaces has been left over. If so, return it; otherwise, backtrack and continue iterating
    if word_idx == len(words):
        if board.empty_squares in special_words_dict:
            print(time.time())
            print(f"Found final solution :D\n")
            # fill in the remaining letters appropriately here, or do it in the main function?
            board.place_special_word(special_words_dict[board.empty_squares])
            print(board)
            print(words)
            solution_found[0] = True
            return
        # if we’ve reached the end of the words but the number of missing letters isn’t right
        print(time.time())
        print(f"Found solution but it had {board.empty_squares} remaining slots\n")
        # print(board)
        # print(words)
        return

    word = words[word_idx]
    for position in board.get_possible_word_positions(word):
        success = board.add_to_board(word, position) # only adds to the board if success == True
        if success:
            place_word(word_idx+1)
            if solution_found[0]:
                return
            board.remove_from_board(word, position)

    # Forget about the early-termination logic for now, and just try to get something that works at all

if __name__ == "__main__":
    make_puzzle()
