% 3 words (7 letters):
%  - Geocode,  no symmetry: 126msec (old)
%  - Geocode,  w/ symmetry: 7sec (old)
%  - OR Tools, no symmetry: 419msec (old)
%  - OR Tools, w/ symmetry: 360msec (318msec now)
% 4 words (9 letters):
%  - Geocode,  no symmetry: 365msec (old)
%  - Geocode,  w/ symmetry: 709msec (old)
%  - OR Tools, no symmetry: 712msec (old)
%  - OR Tools, w/ symmetry: 845msec (885msec now)
% 5 words (11 letters):
%  - Geocode,  no symmetry: 3m 39s (1m 36s now)
%  - Geocode,  w/ symmetry: 2m 23s (833msec now ???)
%  - OR Tools, no symmetry: 51sec (23ssec now)
%  - OR Tools, w/ symmetry: 55sec (25sec now)
% 6 words (13 letters):
%  - Geocode,  no symmetry: [killed]
%  - Geocode,  w/ symmetry: [killed] (27sec now)
%  - OR Tools, no symmetry: [killed]
%  - OR Tools, w/ symmetry: [killed] (killed after 5min)
% 7 words (14 letters):
%  - Geocode,  no symmetry: [killed]
%  - Geocode,  w/ symmetry: [killed] (killed after 13min)
%  - OR Tools, no symmetry: [killed]
%  - OR Tools, w/ symmetry: [killed]

include "global_cardinality_low_up_closed.mzn";
include "lex_lesseq.mzn";

int: n = 7;
array [1..n,1..n] of var int: board;
array [1..15] of string: dict = ["R", "A", "I", "N", "T", "E", "V", "B", "D", "O", "M", "S", "K", "H", "o"];

array [1..4] of int: RAIN = [0, 1, 2, 3];
array [1..4] of int: TREE = [4, 0, 5, 5];
array [1..4] of int: VINE = [6, 2, 3, 5];
array [1..4] of int: BIRD = [7, 2, 0, 8];
array [1..5] of int: BIOME = [7, 2, 9, 10, 5];
array [1..5] of int: SNAKE = [11, 3, 1, 12, 5];
array [1..5] of int: EARTH = [5, 1, 0, 4, 13];

constraint (exists(i in 1..n)(
    exists(j in 1..(n-length(RAIN)))(
        forall(k in 1..length(RAIN))(
            RAIN[k] = board[i,j+k-1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in 1..(n-length(RAIN)))(
        forall(k in 1..length(RAIN))(
            RAIN[k] = board[i+k-1,j]
        )
    )
)
 \/ exists(i in 1..n)(
    exists(j in length(RAIN)..n)(
        forall(k in 1..length(RAIN))(
            RAIN[k] = board[i,j-k+1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in length(RAIN)..n)(
        forall(k in 1..length(RAIN))(
            RAIN[k] = board[i-k+1,j]
        )
    )
)
);

constraint (exists(i in 1..n)(
    exists(j in 1..(n-length(TREE)))(
        forall(k in 1..length(TREE))(
            TREE[k] = board[i,j+k-1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in 1..(n-length(TREE)))(
        forall(k in 1..length(TREE))(
            TREE[k] = board[i+k-1,j]
        )
    )
)
 \/ exists(i in 1..n)(
    exists(j in length(TREE)..n)(
        forall(k in 1..length(TREE))(
            TREE[k] = board[i,j-k+1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in length(TREE)..n)(
        forall(k in 1..length(TREE))(
            TREE[k] = board[i-k+1,j]
        )
    )
)
);

constraint (exists(i in 1..n)(
    exists(j in 1..(n-length(VINE)))(
        forall(k in 1..length(VINE))(
            VINE[k] = board[i,j+k-1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in 1..(n-length(VINE)))(
        forall(k in 1..length(VINE))(
            VINE[k] = board[i+k-1,j]
        )
    )
)
 \/ exists(i in 1..n)(
    exists(j in length(VINE)..n)(
        forall(k in 1..length(VINE))(
            VINE[k] = board[i,j-k+1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in length(VINE)..n)(
        forall(k in 1..length(VINE))(
            VINE[k] = board[i-k+1,j]
        )
    )
)
);

constraint (exists(i in 1..n)(
    exists(j in 1..(n-length(BIRD)))(
        forall(k in 1..length(BIRD))(
            BIRD[k] = board[i,j+k-1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in 1..(n-length(BIRD)))(
        forall(k in 1..length(BIRD))(
            BIRD[k] = board[i+k-1,j]
        )
    )
)
 \/ exists(i in 1..n)(
    exists(j in length(BIRD)..n)(
        forall(k in 1..length(BIRD))(
            BIRD[k] = board[i,j-k+1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in length(BIRD)..n)(
        forall(k in 1..length(BIRD))(
            BIRD[k] = board[i-k+1,j]
        )
    )
)
);

constraint (exists(i in 1..n)(
    exists(j in 1..(n-length(BIOME)))(
        forall(k in 1..length(BIOME))(
            BIOME[k] = board[i,j+k-1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in 1..(n-length(BIOME)))(
        forall(k in 1..length(BIOME))(
            BIOME[k] = board[i+k-1,j]
        )
    )
)
 \/ exists(i in 1..n)(
    exists(j in length(BIOME)..n)(
        forall(k in 1..length(BIOME))(
            BIOME[k] = board[i,j-k+1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in length(BIOME)..n)(
        forall(k in 1..length(BIOME))(
            BIOME[k] = board[i-k+1,j]
        )
    )
)
);

constraint (exists(i in 1..n)(
    exists(j in 1..(n-length(SNAKE)))(
        forall(k in 1..length(SNAKE))(
            SNAKE[k] = board[i,j+k-1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in 1..(n-length(SNAKE)))(
        forall(k in 1..length(SNAKE))(
            SNAKE[k] = board[i+k-1,j]
        )
    )
)
 \/ exists(i in 1..n)(
    exists(j in length(SNAKE)..n)(
        forall(k in 1..length(SNAKE))(
            SNAKE[k] = board[i,j-k+1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in length(SNAKE)..n)(
        forall(k in 1..length(SNAKE))(
            SNAKE[k] = board[i-k+1,j]
        )
    )
)
);

constraint (exists(i in 1..n)(
    exists(j in 1..(n-length(EARTH)))(
        forall(k in 1..length(EARTH))(
            EARTH[k] = board[i,j+k-1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in 1..(n-length(EARTH)))(
        forall(k in 1..length(EARTH))(
            EARTH[k] = board[i+k-1,j]
        )
    )
)
 \/ exists(i in 1..n)(
    exists(j in length(EARTH)..n)(
        forall(k in 1..length(EARTH))(
            EARTH[k] = board[i,j-k+1]
        )
    )
)
 \/ exists(j in 1..n)(
    exists(i in length(EARTH)..n)(
        forall(k in 1..length(EARTH))(
            EARTH[k] = board[i-k+1,j]
        )
    )
)
);


constraint global_cardinality_low_up_closed(
  array1d(board),
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
  [2, 1, 2, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 18],
  [4, 3, 4, 3, 2, 6, 1, 2, 1, 1, 1, 1, 1, 1, 31]

);

constraint symmetry_breaking_constraint(
lex_lesseq(array1d(board), [ board[j,i] | i,j in 1..n ])
/\  lex_lesseq(array1d(board), [ board[i,j] | i in reverse(1..n), j in 1..n ])
/\  lex_lesseq(array1d(board), [ board[j,i] | i in 1..n, j in reverse(1..n) ])
/\  lex_lesseq(array1d(board), [ board[i,j] | i in 1..n, j in reverse(1..n) ])
/\  lex_lesseq(array1d(board), [ board[j,i] | i in reverse(1..n), j in 1..n ])
/\  lex_lesseq(array1d(board), [ board[i,j] | i,j in reverse(1..n) ])
/\  lex_lesseq(array1d(board), [ board[j,i] | i,j in reverse(1..n) ])
);

output [ dict[fix(board[i,j] + 1)] ++
if j == n then "\n" else "" endif | i,j in 1..n]