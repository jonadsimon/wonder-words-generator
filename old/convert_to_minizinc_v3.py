import random
from collections import Counter

num_words = 7
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

    # for each word, perform manual OR between 4 statements: horizonal fwd, vertical fwd, horizonal bwd, vertical bwd
    # also need to add the word as an array to be iterated over
    # also need to add iterators over the array

    # initialize word arrays
    word_arrays = []
    for word in words:
        num_repr = []
        for letter in word:
            num_repr.append(letter_to_num_map[letter])
        word_arrays.append(f"array [1..{len(word)}] of int: {word} = [" + ", ".join(map(str, num_repr)) + "];")


    minizinc_code = f"""include "global_cardinality_low_up_closed.mzn";
include "lex_lesseq.mzn";

int: n = {board_size};
array [1..n,1..n] of var int: board;
array [1..{len(num_to_letter_map)}] of string: dict = {list(num_to_letter_map.values()).__str__().replace("'", '"')};

"""

    for word_array in word_arrays:
        minizinc_code += word_array+"\n"
    minizinc_code += "\n"

    word_constraints = []
    for word in words:
        horiz_fwd = f"""exists(i in 1..n)(
    exists(j in 1..(n-length({word})))(
        forall(k in 1..length({word}))(
            {word}[k] = board[i,j+k-1]
        )
    )
)
"""

        horiz_bwd = f"""exists(i in 1..n)(
    exists(j in length({word})..n)(
        forall(k in 1..length({word}))(
            {word}[k] = board[i,j-k+1]
        )
    )
)
"""

        vert_fwd = f"""exists(j in 1..n)(
    exists(i in 1..(n-length({word})))(
        forall(k in 1..length({word}))(
            {word}[k] = board[i+k-1,j]
        )
    )
)
"""

        vert_bwd = f"""exists(j in 1..n)(
    exists(i in length({word})..n)(
        forall(k in 1..length({word}))(
            {word}[k] = board[i-k+1,j]
        )
    )
)
"""
        word_constraints.append(horiz_fwd + " \/ " + vert_fwd + " \/ " + horiz_bwd + " \/ " + vert_bwd)

    # for constraint in problem_constraints:
    for constraint in word_constraints:
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
