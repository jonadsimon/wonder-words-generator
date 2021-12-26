% 10 words, 7x7 board (46/49):
%  - Chuffed,  no symmetry: 106msec
%  - Chuffed,  w/ symmetry: 177msec
% 11 words, 7x7 board (51/49):
%  - Chuffed,  no symmetry: 121msec
%  - Chuffed,  w/ symmetry: 635msec
% 12 words, 7x7 board (56/49):
%  - Chuffed,  no symmetry: 1m 0s
%  - Chuffed,  w/ symmetry: XX

% 20 words, 10x10 board (104/100):
%  - Chuffed, no symmetry: 2m 0s

% 26 words, 12x12 board (142/144):
%  - Chuffed, no symmetry: 351msec (ran again with same failed 27-word params, and killed it after 2min... high sensitivity to initialization)

% 27 words, 12x12 board (149/144):
%  - Chuffed, no symmetry: [killed after 13min]

% 36 words, 15x15 board (217/225):
%  - Chuffed, no symmetry: [killed after 8min] 

% 37 words, 15x15 board (225/225):
%  - Chuffed, no symmetry, w/ cardinality constraint: [killed after 3min]

% Conclusion: need to flip back [n/2,n] cardinality distribution


% Variables whose values need to be passed in
% int: n; % board size
% int: m; % number of words
% int: max_len; % length of the longest word being passed in
% enum Letter; % vocabulary (== all letters present in all words)
% array [1..m] of int: word_lens; % array giving the length of each word
% array [1..m,1..max_len] of Letter: words; % array whose rows are words, with excess length padded with other letters

include "global_cardinality_low_up_closed.mzn";

int: n = 15; % board size
int: m = 37; % number of words
int: max_len = 8; % length of the longest word being passed in
array [1..26] of string: n2l = [ "R", "A", "I", "N", "T", "E", "V", "B", "D", "O", "M", "S", "K", "H", "F", "U", "G", "L", "P", "W", "J", "X", "Y", "C", "Z", "Q" ]; % convertion from ints to letters
array [1..m] of int: word_lens = [ 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8 ]; % array giving the length of each word
array [1..m,1..max_len] of int: words = [| 0, 1, 2, 3, 0, 0, 0, 0
	| 4, 0, 5, 5, 0, 0, 0, 0
	| 6, 2, 3, 5, 0, 0, 0, 0
	| 7, 2, 0, 8, 0, 0, 0, 0
	| 7, 2, 9, 10, 5, 0, 0, 0
	| 11, 3, 1, 12, 5, 0, 0, 0
	| 5, 1, 0, 4, 13, 0, 0, 0
	| 14, 1, 15, 3, 1, 0, 0, 0
	| 5, 1, 16, 17, 5, 0, 0, 0
	| 18, 17, 1, 3, 4, 0, 0, 0
	| 11, 19, 1, 10, 18, 0, 0, 0
	| 14, 17, 9, 0, 1, 0, 0, 0
	| 14, 9, 0, 5, 11, 4, 0, 0
	| 20, 15, 3, 16, 17, 5, 0, 0
	| 9, 21, 22, 16, 5, 3, 0, 0
	| 23, 1, 3, 9, 18, 22, 0, 0
	| 1, 10, 1, 24, 9, 3, 0, 0
	| 10, 9, 3, 12, 5, 22, 0, 0
	| 20, 1, 16, 15, 1, 0, 0, 0
	| 7, 0, 1, 24, 2, 17, 0, 0
	| 7, 0, 1, 3, 23, 13, 0, 0
	| 7, 9, 0, 5, 1, 17, 0, 0
	| 23, 1, 0, 7, 9, 3, 0, 0
	| 1, 23, 1, 23, 2, 1, 0, 0
	| 11, 18, 5, 23, 2, 5, 11, 0
	| 1, 10, 5, 0, 2, 23, 1, 0
	| 5, 25, 15, 1, 4, 9, 0, 0
	| 11, 1, 6, 1, 3, 3, 1, 0
	| 10, 9, 3, 11, 9, 9, 3, 0
	| 10, 9, 3, 4, 1, 3, 5, 0
	| 4, 0, 9, 18, 2, 23, 11, 0
	| 4, 0, 9, 18, 2, 23, 1, 17
	| 10, 5, 8, 2, 23, 2, 3, 5
	| 19, 9, 9, 8, 17, 1, 3, 8
	| 10, 1, 3, 16, 0, 9, 6, 5
	| 13, 1, 7, 2, 4, 1, 4, 11
	| 10, 1, 17, 1, 22, 11, 2, 1 |]; % array whose rows are words, with excess length padded with other letters


array [1..n,1..n] of var int: board;

array [1..m] of var int: word_pos_y; % values constrained by board size
array [1..m] of var int: word_pos_x; % values constrained by board size
array [1..m] of var int: word_delta_y; % values constrained by (-1,0,1)
array [1..m] of var int: word_delta_x; % values constrained by (-1,0,1)

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

% Remove symmetry constraint: It's not a real requirement, and just slows down the solver.

% Add low/upper count constraints back in. Once the # of letters approaches the size of the array, these constraints become tight
% while still allowing enough flexibility to fill in the entire grid.
% However, this requires reverting back to integer-based arrays.

constraint global_cardinality_low_up_closed(
  array1d(board),
  [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25 ],
  [ 2, 9, 4, 5, 3, 5, 1, 2, 1, 5, 3, 3, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 3, 1, 1 ],
%   [ 5, 11, 4, 7, 3, 7, 1, 2, 1, 6, 3, 3, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 3, 1, 1 ],
%   [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  [ 16, 36, 14, 21, 10, 21, 3, 7, 4, 19, 10, 10, 2, 3, 3, 4, 5, 9, 6, 2, 2, 1, 4, 10, 2, 1 ]
);

% Option 1: for each position, if it is not contained within one of the words, then print a '_'
% Option 2: return the positions and deltas so Python can determine what is where (also provides an answer key)
output [ n2l[fix(board[i,j] + 1)] ++
if j == n then "\n" else "" endif | i,j in 1..n];

% Print deltas to make sure there's a good mix of orientations.
% output [ "\n(" ++ format(fix(word_delta_y[i])) ++ "," ++ format(fix(word_delta_x[i])) ++ ")" | i in 1..m];
%  Answer: Comparable numbers of Horizontal (9), Vertical (7), and Diagonal (10)