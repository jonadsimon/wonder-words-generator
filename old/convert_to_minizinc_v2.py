import random
from collections import Counter

num_words = 6
board_size = 7

# CONVERT LETTERS TO ORDINALS AND USE COUNTS
# CAP LETTER OCCURRENCES AT TOTAL OCCURRENCES, AND LOWER-BOUND BY CEIL(FLOAT(OCCURRENCES)/4)
# PUT ZERO AT THE FRONT OF THE ARRAY SO IT GRABS IT FIRST
# CAP ZEROS AT HALF (?) OF TOTAL LETTER COUNT

def get_minizinc_code():
    words = ['rain', 'tree', 'vine', 'bird', 'biome', 'snake', 'earth', 'fauna', 'eagle', 'plant', 'swamp', 'flora', 'forest', 'jungle', 'oxygen', 'canopy', 'amazon', 'monkey', 'jaguar', 'brazil', 'branch', 'boreal', 'carbon', 'acacia', 'species', 'america', 'equator', 'savanna', 'monsoon', 'montane', 'tropics', 'tropical', 'medicine', 'woodland', 'mangrove', 'habitats', 'malaysia', 'wetlands', 'wildlife', 'peatland', 'temperate', 'indonesia', 'woodlands', 'shrubland', 'australia', 'vegetation', 'coniferous', 'eucalyptus', 'grasslands', 'ecosystems', 'madagascar', 'undergrowth', 'plantations', 'biodiversity', 'deforestation', 'photosynthesis']
    words = [word.upper() for word in words]

    words = words[:num_words] # grab the 11 shortest words; grab num words proportional to board size
    letter_counts_ub = Counter(''.join(words))
    letter_counts_lb = {ltr: max(cnt//2, 1) for ltr, cnt in letter_counts_ub.most_common()} # assume each letter instance is used by at most 2 words on average; round down to relax, may need to relax this later

    # Add a special dummy letter whose counts are upper/lower bounded by the other letters
    dummy_ub = max(board_size**2 - sum(letter_counts_lb.values()), 4)
    dummy_lb = max(board_size**2 - sum(letter_counts_ub.values()), 4) # need to be able to fit at least 1 special character in there
    letter_counts_ub.update({'o': dummy_ub})
    letter_counts_lb.update({'o': dummy_lb})

    letter_to_num_map = {ltr: i for i, ltr in enumerate(letter_counts_ub.keys())}
    num_to_letter_map = {v: k for k, v in letter_to_num_map.items()}

    problem_constraints = []
    for word in words:
        word_constraints = []
        for dy in (-1,0,1):
            for dx in (-1,0,1):
                for y in range(board_size):
                    for x in range(board_size):
                        # Check that the word doesn't overrun the board boundaries.
                        if (0 <= y + dy*len(word) < board_size) and (0 <= x + dx*len(word) < board_size):
                            letter_constraints = []
                            for i, letter in enumerate(word):
                                # need to remember to make everything 1-indexed
                                letter_constraints.append(f"board[{1+y+dy*i},{1+x+dx*i}] = {letter_to_num_map[letter]}")
                            random.shuffle(letter_constraints)
                            word_constraints.append("(" + " /\ ".join(letter_constraints) + ")")
        random.shuffle(word_constraints)
        problem_constraints.append(" \/ ".join(word_constraints))

    minizinc_code = f"""include "global_cardinality_low_up_closed.mzn";
include "lex_lesseq.mzn";

int: n = {board_size};
array [1..n,1..n] of var int: board;
array [1..{len(num_to_letter_map)}] of string: dict = {list(num_to_letter_map.values()).__str__().replace("'", '"')};

"""

    for constraint in problem_constraints:
        minizinc_code += f"constraint ({constraint});\n\n"

    # this assumes dict.keys() returns things in the same order every time... need to double check
    minizinc_code += f"""
constraint global_cardinality_low_up_closed(
  array1d(board),
  {list(num_to_letter_map.keys())},
  {[letter_counts_lb[num_to_letter_map[num]] for num in num_to_letter_map.keys()]},
  {[letter_counts_ub[num_to_letter_map[num]] for num in num_to_letter_map.keys()]}

);

"""
    minizinc_code += """constraint symmetry_breaking_constraint(
lex_lesseq(array1d(board), [ board[j,i] | i,j in 1..n ])
/\  lex_lesseq(array1d(board), [ board[i,j] | i in reverse(1..n), j in 1..n ])
/\  lex_lesseq(array1d(board), [ board[j,i] | i in 1..n, j in reverse(1..n) ])
/\  lex_lesseq(array1d(board), [ board[i,j] | i in 1..n, j in reverse(1..n) ])
/\  lex_lesseq(array1d(board), [ board[j,i] | i in reverse(1..n), j in 1..n ])
/\  lex_lesseq(array1d(board), [ board[i,j] | i,j in reverse(1..n) ])
/\  lex_lesseq(array1d(board), [ board[j,i] | i,j in reverse(1..n) ])
);

"""

    minizinc_code += """output [ dict[fix(board[i,j] + 1)] ++
if j == n then "\\n" else "" endif | i,j in 1..n]"""

    return minizinc_code

if __name__ == "__main__":
    minizinc_code = get_minizinc_code()
    print(minizinc_code)
