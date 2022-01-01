% Variables whose values need to be passed in
int: n = 18; % board size
int: m = 70; % number of words

% array [1..n] of int: reindex = [1, 20, 2, 19, 3, 18, 4, 17, 5, 16, 6, 15, 7, 14, 8, 13, 9, 12, 10, 11];

int: max_len = 6; % length of the longest word being passed in
enum Letter = { E, R, O, A, T, L, I, S, N, M, G, C, P, D, H, W, U, K, V, F, B, Y, J, Z, Q }; % vocabulary (== all letters present in all words)
array [1..m] of int: word_lens = [ 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ]; % array giving the length of each word
array [1..m,1..max_len] of Letter: words = [| M, I, L, K, E, E
	| S, O, D, A, E, E
	| C, H, A, I, E, E
	| M, A, T, E, E, E
	| J, E, L, L, E, E
	| F, L, A, N, E, E
	| T, O, F, U, E, E
	| I, C, E, D, E, E
	| T, I, L, A, E, E
	| C, A, F, E, E, E
	| C, O, L, A, E, E
	| J, A, V, A, E, E
	| P, I, N, T, E, E
	| M, O, C, H, A, E
	| D, E, C, A, F, E
	| V, E, N, T, I, E
	| B, A, G, E, L, E
	| S, L, U, R, P, E
	| C, A, F, F, E, E
	| C, A, F, F, E, E
	| T, A, P, A, S, E
	| S, W, I, S, H, E
	| C, R, E, M, A, E
	| F, I, Z, Z, Y, E
	| Q, U, E, S, O, E
	| L, E, C, H, E, E
	| C, O, R, K, S, E
	| C, R, E, M, E, E
	| V, O, D, K, A, E
	| E, T, H, E, R, E
	| C, A, C, A, O, E
	| Q, U, A, R, T, E
	| R, U, M, B, A, E
	| T, O, R, T, A, E
	| C, R, E, A, M, E
	| P, E, P, S, I, E
	| D, A, I, R, Y, E
	| D, R, I, N, K, E
	| N, E, G, U, S, E
	| S, C, O, N, E, E
	| C, O, S, M, O, E
	| V, E, N, T, E, E
	| C, O, F, F, E, E
	| M, O, J, I, T, O
	| E, G, G, N, O, G
	| F, R, A, P, P, E
	| E, U, R, O, P, E
	| F, R, A, N, C, E
	| T, U, R, K, E, Y
	| L, A, T, T, E, S
	| M, A, T, C, H, A
	| V, I, E, N, N, A
	| T, A, C, U, B, A
	| F, O, N, D, U, E
	| G, E, L, A, T, O
	| F, R, E, S, C, A
	| P, U, L, Q, U, E
	| F, R, O, T, H, Y
	| N, I, B, B, L, E
	| V, E, N, I, C, E
	| B, R, U, L, E, E
	| N, A, C, H, O, S
	| L, O, N, D, O, N
	| M, E, Z, C, A, L
	| S, O, R, B, E, T
	| P, A, N, E, R, A
	| T, E, M, P, E, H
	| P, O, B, L, E, T
	| P, I, N, A, T, A
	| T, C, H, I, B, O |]; % array whose rows are words, with excess length padded with other letters


array [1..n,1..n] of var Letter: board;

array [1..m] of var int: word_pos_y; % values constrained by board size
array [1..m] of var int: word_pos_x; % values constrained by board size
array [1..m] of var int: word_delta_y; % values constrained by {-1,0,1}
array [1..m] of var int: word_delta_x; % values constrained by {-1,0,1}

constraint forall(i in 1..m)(word_pos_y[i] >= 1 /\ word_pos_y[i] <= n); % y positions lie within [1..n]
constraint forall(i in 1..m)(word_pos_x[i] >= 1 /\ word_pos_x[i] <= n); % x positions lie within [1..n]
constraint forall(i in 1..m)(word_delta_y[i] >= -1 /\ word_delta_y[i] <= 1); % dy values are one of {-1, 0, 1}
constraint forall(i in 1..m)(word_delta_x[i] >= -1 /\ word_delta_x[i] <= 1); % dx values are one of {-1, 0, 1}
constraint forall(i in 1..m)(word_delta_y[i] != 0 \/ word_delta_x[i] != 0); % at least one of dy,dx must be nonzero


% For each word, enforce that its last letter lies within the board.
% Since its first letter also lies within the board, this implies that the entire word lies within the board, by convexity.
constraint forall(i in 1..m)(
  word_pos_y[i]+word_delta_y[i]*word_lens[i] >= 1
  /\ word_pos_y[i]+word_delta_y[i]*word_lens[i] <= n
  /\ word_pos_x[i]+word_delta_x[i]*word_lens[i] >= 1
  /\ word_pos_x[i]+word_delta_x[i]*word_lens[i] <= n
);

% Link the words to the board by linking letters to board positions.
constraint forall(i in 1..m)(
  forall(j in 1..word_lens[i])(
    words[i,j] = board[word_pos_y[i] + word_delta_y[i]*(j-1), word_pos_x[i] + word_delta_x[i]*(j-1)]
  )
);

% If we called together all 4 constraint arrayed, could generate these re-ordings on the fly...
% solve :: int_search(reverse(word_pos_y) ++ reverse(word_pos_x), most_constrained, indomain_min) satisfy;

% Define position searches and orientation searches separately, then interleave them in reverse order.
% pos_searches = [int_search([word_pos_y[i], word_pos_x[i]], smallest, indomain_min) | i in i..m];
% delta_searches =  [int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)  | i in i..m];
solve :: seq_search([
  if x = 1 then int_search([word_pos_y[i], word_pos_x[i]], smallest, indomain_min)
  else int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)
  endif | i in reverse(1..m), x in 1..2])
      satisfy;

% Remove symmetry constraint: It's not a real requirement, and just slows down the solver.

% Add low/upper count constraints back in. Once the # of letters approaches the size of the array, these constraints become tight
% while still allowing enough flexibility to fill in the entire grid.
% However, this requires reverting back to integer-based arrays.

% Option 1: for each position, if it is not contained within one of the words, then print a '_'
% Option 2: return the positions and deltas so Python can determine what is where (also provides an answer key)
output [ format(fix(board[i,j])) ++
if j == n then "\n" else " " endif | i,j in 1..n] ++ ["\n"];

% Print deltas to make sure there's a good mix of orientations.
% output [ "\n(" ++ format(fix(word_delta_y[i])) ++ "," ++ format(fix(word_delta_x[i])) ++ ")" | i in 1..m];
%  Answer: Comparable numbers of Horizontal (9), Vertical (7), and Diagonal (10)

output [ format(fix(word_lens[i])) ++ " " | i in 1..m] ++ ["\n"];
output [ format(fix(word_pos_y[i])) ++ " " | i in 1..m] ++ ["\n"];
output [ format(fix(word_pos_x[i])) ++ " " | i in 1..m] ++ ["\n"];
output [ format(fix(word_delta_y[i])) ++ " " | i in 1..m] ++ ["\n"];
output [ format(fix(word_delta_x[i])) ++ " " | i in 1..m] ++ ["\n"];