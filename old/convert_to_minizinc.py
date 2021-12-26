from collections import Counter

num_words = 2
board_size = 7

# CONVERT LETTERS TO ORDINALS AND USE COUNTS
# CAP LETTER OCCURRENCES AT TOTAL OCCURRENCES, AND LOWER-BOUND BY CEIL(FLOAT(OCCURRENCES)/4)
# PUT ZERO AT THE FRONT OF THE ARRAY SO IT GRABS IT FIRST
# CAP ZEROS AT HALF (?) OF TOTAL LETTER COUNT

def get_minizinc_code():
    words = ['rain', 'tree', 'vine', 'bird', 'biome', 'snake', 'earth', 'fauna', 'eagle', 'plant', 'swamp', 'flora', 'forest', 'jungle', 'oxygen', 'canopy', 'amazon', 'monkey', 'jaguar', 'brazil', 'branch', 'boreal', 'carbon', 'acacia', 'species', 'america', 'equator', 'savanna', 'monsoon', 'montane', 'tropics', 'tropical', 'medicine', 'woodland', 'mangrove', 'habitats', 'malaysia', 'wetlands', 'wildlife', 'peatland', 'temperate', 'indonesia', 'woodlands', 'shrubland', 'australia', 'vegetation', 'coniferous', 'eucalyptus', 'grasslands', 'ecosystems', 'madagascar', 'undergrowth', 'plantations', 'biodiversity', 'deforestation', 'photosynthesis']
    words = [word.upper() for word in words]

    words = words[:num_words] # grab the 11 shortest words; grab num words proportional to board size
    letters_counts = Counter(''.join(words))

    # ord('A') = 65

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
                                letter_constraints.append(f"board[{1+y+dy*i},{1+x+dx*i}] = {letter}")
                            word_constraints.append("(" + " /\ ".join(letter_constraints) + ")")
        problem_constraints.append(" \/ ".join(word_constraints))

    minizinc_code = """include "lex_lesseq.mzn";

int: n;
enum Letters = { o, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z };
array [1..n,1..n] of var Letters: board;

"""

    for constraint in problem_constraints:
        minizinc_code += f"constraint ({constraint});\n\n"

#     minizinc_code += """constraint symmetry_breaking_constraint(
# lex_lesseq(array1d(board), [ board[j,i] | i,j in 1..n ])
# /\  lex_lesseq(array1d(board), [ board[i,j] | i in reverse(1..n), j in 1..n ])
# /\  lex_lesseq(array1d(board), [ board[j,i] | i in 1..n, j in reverse(1..n) ])
# /\  lex_lesseq(array1d(board), [ board[i,j] | i in 1..n, j in reverse(1..n) ])
# /\  lex_lesseq(array1d(board), [ board[j,i] | i in reverse(1..n), j in 1..n ])
# /\  lex_lesseq(array1d(board), [ board[i,j] | i,j in reverse(1..n) ])
# /\  lex_lesseq(array1d(board), [ board[j,i] | i,j in reverse(1..n) ])
# );"""

    minizinc_code += """output [ format(fix(board[i,j])) ++
if j == n then "\n" else "" endif | i,j in 1..n]"""

    return minizinc_code

if __name__ == "__main__":
    minizinc_code = get_minizinc_code()
    print(minizinc_code)
