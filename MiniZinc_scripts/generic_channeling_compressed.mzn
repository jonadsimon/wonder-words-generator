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
%  - Chuffed,  no symmetry: 2m 0s

% 26 words, 12x12 board (142/144):
%  - Chuffed,  no symmetry: 351msec (ran again with same failed 27-word params, and killed it after 2min... high sensitivity to initialization)

% 27 words, 12x12 board (149/144):
%  - Chuffed,  no symmetry: [killed after 13min]

% 36 words, 15x15 board (217/225):
%  - Chuffed,  no symmetry: [killed after 8min]

% Conclusion: need to flip back [n/2,n] cardinality distribution

% 21 words, 12x12 board (137/144):
%  - Chuffed,  no symmetry: 782msec
% 24 words, 13x13 board (163/169):
%  - Chuffed,  no symmetry: 4m 55s
% 27 words, 14x14 board (192/194):
%  - Chuffed,  no symmetry: [killed after 25m 4s]


% Variables whose values need to be passed in
int: n = 25; % board size
int: m = 100; % number of words
int: max_len = 9; % length of the longest word being passed in
enum Letter = { R, I, D, J, X, O, G, Q, T, S, M, C, U, Y, B, W, H, Z, F, L, E, P, K, A, V, N }; % vocabulary (== all letters present in all words)
array [1..m] of int: word_lens = [ 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9 ]; % array giving the length of each word
array [1..m,1..max_len] of Letter: words = [| N, A, S, A, A, A, A, A, A
	| V, T, O, L, A, A, A, A, A
	| G, E, A, R, A, A, A, A, A
	| M, A, R, S, A, A, A, A, A
	| T, R, O, T, A, A, A, A, A
	| A, I, B, O, A, A, A, A, A
	| B, I, O, S, A, A, A, A, A
	| H, I, L, L, A, A, A, A, A
	| R, O, B, O, T, A, A, A, A
	| S, O, N, A, R, A, A, A, A
	| M, O, U, S, E, A, A, A, A
	| L, I, D, A, R, A, A, A, A
	| R, A, D, A, R, A, A, A, A
	| L, A, S, E, R, A, A, A, A
	| A, S, I, M, O, A, A, A, A
	| J, O, U, L, E, A, A, A, A
	| D, E, L, F, T, A, A, A, A
	| W, H, E, E, L, A, A, A, A
	| C, R, A, F, T, A, A, A, A
	| D, R, I, L, L, A, A, A, A
	| O, R, I, O, N, A, A, A, A
	| H, O, N, D, A, A, A, A, A
	| O, R, B, I, T, A, A, A, A
	| A, B, O, R, T, A, A, A, A
	| E, A, R, T, H, A, A, A, A
	| S, L, I, N, G, A, A, A, A
	| D, U, M, M, Y, A, A, A, A
	| F, L, A, M, E, A, A, A, A
	| C, Y, B, O, R, G, A, A, A
	| D, E, V, I, C, E, A, A, A
	| W, E, I, G, H, T, A, A, A
	| M, U, S, C, L, E, A, A, A
	| S, P, R, I, N, G, A, A, A
	| O, P, T, I, C, S, A, A, A
	| M, O, D, U, L, E, A, A, A
	| M, A, N, N, E, D, A, A, A
	| D, R, O, N, E, S, A, A, A
	| A, P, O, L, L, O, A, A, A
	| L, A, N, D, E, R, A, A, A
	| M, E, D, U, S, A, A, A, A
	| H, U, B, B, L, E, A, A, A
	| S, P, A, C, E, X, A, A, A
	| F, I, T, T, E, D, A, A, A
	| W, I, N, G, E, D, A, A, A
	| C, A, N, I, N, E, A, A, A
	| M, O, M, E, N, T, A, A, A
	| S, C, H, U, N, K, A, A, A
	| P, U, L, L, E, Y, A, A, A
	| T, O, I, L, E, T, A, A, A
	| C, O, M, B, E, R, A, A, A
	| F, L, I, G, H, T, A, A, A
	| A, N, D, R, O, I, D, A, A
	| M, A, C, H, I, N, E, A, A
	| B, A, T, T, E, R, Y, A, A
	| T, A, C, T, I, L, E, A, A
	| U, N, I, M, A, T, E, A, A
	| D, E, C, O, D, E, R, A, A
	| Z, A, M, B, O, N, I, A, A
	| D, O, C, K, I, N, G, A, A
	| S, E, N, S, O, R, S, A, A
	| F, A, I, R, I, N, G, A, A
	| I, N, E, R, T, I, A, A, A
	| P, A, Y, L, O, A, D, A, A
	| S, H, U, T, T, L, E, A, A
	| G, E, S, T, U, R, E, A, A
	| S, E, N, S, I, N, G, A, A
	| G, A, L, I, L, E, O, A, A
	| B, A, L, L, B, O, T, A, A
	| H, U, M, A, N, O, I, D, A
	| R, O, B, O, N, A, U, T, A
	| K, E, Y, B, O, A, R, D, A
	| A, U, T, O, M, A, T, E, A
	| C, A, T, A, P, U, L, T, A
	| P, I, L, O, T, I, N, G, A
	| E, Q, U, I, P, P, E, D, A
	| S, I, M, U, L, A, T, E, A
	| T, E, T, H, E, R, E, D, A
	| S, C, A, N, N, I, N, G, A
	| R, E, U, S, A, B, L, E, A
	| S, T, A, I, R, W, A, Y, A
	| S, T, E, A, L, T, H, Y, A
	| R, E, A, C, T, I, O, N, A
	| H, A, R, D, W, A, R, E, A
	| T, E, L, E, T, Y, P, E, A
	| C, O, M, P, U, T, E, R, A
	| M, E, C, H, A, N, I, C, A
	| M, I, N, D, T, O, O, L, A
	| S, I, M, U, L, A, T, O, R
	| S, U, B, M, A, R, I, N, E
	| M, I, N, I, A, T, U, R, E
	| A, U, T, O, M, A, T, I, C
	| E, T, Y, M, O, L, O, G, Y
	| A, U, T, O, M, A, T, O, N
	| R, U, N, A, R, O, U, N, D
	| M, A, C, H, I, N, I, S, T
	| N, A, N, O, M, E, T, R, E
	| S, P, A, C, E, S, H, I, P
	| M, A, C, H, I, N, I, M, A
	| G, Y, R, O, S, C, O, P, E
	| T, E, L, E, S, C, O, P, E |]; % array whose rows are words, with excess length padded with other letters


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

% solve :: int_search( [word_pos_y[100], word_pos_x[100], word_pos_y[99], word_pos_x[99], word_pos_y[98], word_pos_x[98], word_pos_y[97], word_pos_x[97], word_pos_y[96], word_pos_x[96], word_pos_y[95], word_pos_x[95], word_pos_y[94], word_pos_x[94], word_pos_y[93], word_pos_x[93], word_pos_y[92], word_pos_x[92], word_pos_y[91], word_pos_x[91], word_pos_y[90], word_pos_x[90], word_pos_y[89], word_pos_x[89], word_pos_y[88], word_pos_x[88], word_pos_y[87], word_pos_x[87], word_pos_y[86], word_pos_x[86], word_pos_y[85], word_pos_x[85], word_pos_y[84], word_pos_x[84], word_pos_y[83], word_pos_x[83], word_pos_y[82], word_pos_x[82], word_pos_y[81], word_pos_x[81], word_pos_y[80], word_pos_x[80], word_pos_y[79], word_pos_x[79], word_pos_y[78], word_pos_x[78], word_pos_y[77], word_pos_x[77], word_pos_y[76], word_pos_x[76], word_pos_y[75], word_pos_x[75], word_pos_y[74], word_pos_x[74], word_pos_y[73], word_pos_x[73], word_pos_y[72], word_pos_x[72], word_pos_y[71], word_pos_x[71], word_pos_y[70], word_pos_x[70], word_pos_y[69], word_pos_x[69], word_pos_y[68], word_pos_x[68], word_pos_y[67], word_pos_x[67], word_pos_y[66], word_pos_x[66], word_pos_y[65], word_pos_x[65], word_pos_y[64], word_pos_x[64], word_pos_y[63], word_pos_x[63], word_pos_y[62], word_pos_x[62], word_pos_y[61], word_pos_x[61], word_pos_y[60], word_pos_x[60], word_pos_y[59], word_pos_x[59], word_pos_y[58], word_pos_x[58], word_pos_y[57], word_pos_x[57], word_pos_y[56], word_pos_x[56], word_pos_y[55], word_pos_x[55], word_pos_y[54], word_pos_x[54], word_pos_y[53], word_pos_x[53], word_pos_y[52], word_pos_x[52], word_pos_y[51], word_pos_x[51], word_pos_y[50], word_pos_x[50], word_pos_y[49], word_pos_x[49], word_pos_y[48], word_pos_x[48], word_pos_y[47], word_pos_x[47], word_pos_y[46], word_pos_x[46], word_pos_y[45], word_pos_x[45], word_pos_y[44], word_pos_x[44], word_pos_y[43], word_pos_x[43], word_pos_y[42], word_pos_x[42], word_pos_y[41], word_pos_x[41], word_pos_y[40], word_pos_x[40], word_pos_y[39], word_pos_x[39], word_pos_y[38], word_pos_x[38], word_pos_y[37], word_pos_x[37], word_pos_y[36], word_pos_x[36], word_pos_y[35], word_pos_x[35], word_pos_y[34], word_pos_x[34], word_pos_y[33], word_pos_x[33], word_pos_y[32], word_pos_x[32], word_pos_y[31], word_pos_x[31], word_pos_y[30], word_pos_x[30], word_pos_y[29], word_pos_x[29], word_pos_y[28], word_pos_x[28], word_pos_y[27], word_pos_x[27], word_pos_y[26], word_pos_x[26], word_pos_y[25], word_pos_x[25], word_pos_y[24], word_pos_x[24], word_pos_y[23], word_pos_x[23], word_pos_y[22], word_pos_x[22], word_pos_y[21], word_pos_x[21], word_pos_y[20], word_pos_x[20], word_pos_y[19], word_pos_x[19], word_pos_y[18], word_pos_x[18], word_pos_y[17], word_pos_x[17], word_pos_y[16], word_pos_x[16], word_pos_y[15], word_pos_x[15], word_pos_y[14], word_pos_x[14], word_pos_y[13], word_pos_x[13], word_pos_y[12], word_pos_x[12], word_pos_y[11], word_pos_x[11], word_pos_y[10], word_pos_x[10], word_pos_y[9], word_pos_x[9], word_pos_y[8], word_pos_x[8], word_pos_y[7], word_pos_x[7], word_pos_y[6], word_pos_x[6], word_pos_y[5], word_pos_x[5], word_pos_y[4], word_pos_x[4], word_pos_y[3], word_pos_x[3], word_pos_y[2], word_pos_x[2], word_pos_y[1], word_pos_x[1]], input_order, indomain_min ) satisfy;

solve :: seq_search([
	int_search([word_pos_y[100], word_pos_x[100]], smallest, indomain_min),
	int_search([word_delta_y[100], word_delta_x[100]], first_fail, indomain_median),
	int_search([word_pos_y[99], word_pos_x[99]], smallest, indomain_min),
	int_search([word_delta_y[99], word_delta_x[99]], first_fail, indomain_median),
	int_search([word_pos_y[98], word_pos_x[98]], smallest, indomain_min),
	int_search([word_delta_y[98], word_delta_x[98]], first_fail, indomain_median),
	int_search([word_pos_y[97], word_pos_x[97]], smallest, indomain_min),
	int_search([word_delta_y[97], word_delta_x[97]], first_fail, indomain_median),
	int_search([word_pos_y[96], word_pos_x[96]], smallest, indomain_min),
	int_search([word_delta_y[96], word_delta_x[96]], first_fail, indomain_median),
	int_search([word_pos_y[95], word_pos_x[95]], smallest, indomain_min),
	int_search([word_delta_y[95], word_delta_x[95]], first_fail, indomain_median),
	int_search([word_pos_y[94], word_pos_x[94]], smallest, indomain_min),
	int_search([word_delta_y[94], word_delta_x[94]], first_fail, indomain_median),
	int_search([word_pos_y[93], word_pos_x[93]], smallest, indomain_min),
	int_search([word_delta_y[93], word_delta_x[93]], first_fail, indomain_median),
	int_search([word_pos_y[92], word_pos_x[92]], smallest, indomain_min),
	int_search([word_delta_y[92], word_delta_x[92]], first_fail, indomain_median),
	int_search([word_pos_y[91], word_pos_x[91]], smallest, indomain_min),
	int_search([word_delta_y[91], word_delta_x[91]], first_fail, indomain_median),
	int_search([word_pos_y[90], word_pos_x[90]], smallest, indomain_min),
	int_search([word_delta_y[90], word_delta_x[90]], first_fail, indomain_median),
	int_search([word_pos_y[89], word_pos_x[89]], smallest, indomain_min),
	int_search([word_delta_y[89], word_delta_x[89]], first_fail, indomain_median),
	int_search([word_pos_y[88], word_pos_x[88]], smallest, indomain_min),
	int_search([word_delta_y[88], word_delta_x[88]], first_fail, indomain_median),
	int_search([word_pos_y[87], word_pos_x[87]], smallest, indomain_min),
	int_search([word_delta_y[87], word_delta_x[87]], first_fail, indomain_median),
	int_search([word_pos_y[86], word_pos_x[86]], smallest, indomain_min),
	int_search([word_delta_y[86], word_delta_x[86]], first_fail, indomain_median),
	int_search([word_pos_y[85], word_pos_x[85]], smallest, indomain_min),
	int_search([word_delta_y[85], word_delta_x[85]], first_fail, indomain_median),
	int_search([word_pos_y[84], word_pos_x[84]], smallest, indomain_min),
	int_search([word_delta_y[84], word_delta_x[84]], first_fail, indomain_median),
	int_search([word_pos_y[83], word_pos_x[83]], smallest, indomain_min),
	int_search([word_delta_y[83], word_delta_x[83]], first_fail, indomain_median),
	int_search([word_pos_y[82], word_pos_x[82]], smallest, indomain_min),
	int_search([word_delta_y[82], word_delta_x[82]], first_fail, indomain_median),
	int_search([word_pos_y[81], word_pos_x[81]], smallest, indomain_min),
	int_search([word_delta_y[81], word_delta_x[81]], first_fail, indomain_median),
	int_search([word_pos_y[80], word_pos_x[80]], smallest, indomain_min),
	int_search([word_delta_y[80], word_delta_x[80]], first_fail, indomain_median),
	int_search([word_pos_y[79], word_pos_x[79]], smallest, indomain_min),
	int_search([word_delta_y[79], word_delta_x[79]], first_fail, indomain_median),
	int_search([word_pos_y[78], word_pos_x[78]], smallest, indomain_min),
	int_search([word_delta_y[78], word_delta_x[78]], first_fail, indomain_median),
	int_search([word_pos_y[77], word_pos_x[77]], smallest, indomain_min),
	int_search([word_delta_y[77], word_delta_x[77]], first_fail, indomain_median),
	int_search([word_pos_y[76], word_pos_x[76]], smallest, indomain_min),
	int_search([word_delta_y[76], word_delta_x[76]], first_fail, indomain_median),
	int_search([word_pos_y[75], word_pos_x[75]], smallest, indomain_min),
	int_search([word_delta_y[75], word_delta_x[75]], first_fail, indomain_median),
	int_search([word_pos_y[74], word_pos_x[74]], smallest, indomain_min),
	int_search([word_delta_y[74], word_delta_x[74]], first_fail, indomain_median),
	int_search([word_pos_y[73], word_pos_x[73]], smallest, indomain_min),
	int_search([word_delta_y[73], word_delta_x[73]], first_fail, indomain_median),
	int_search([word_pos_y[72], word_pos_x[72]], smallest, indomain_min),
	int_search([word_delta_y[72], word_delta_x[72]], first_fail, indomain_median),
	int_search([word_pos_y[71], word_pos_x[71]], smallest, indomain_min),
	int_search([word_delta_y[71], word_delta_x[71]], first_fail, indomain_median),
	int_search([word_pos_y[70], word_pos_x[70]], smallest, indomain_min),
	int_search([word_delta_y[70], word_delta_x[70]], first_fail, indomain_median),
	int_search([word_pos_y[69], word_pos_x[69]], smallest, indomain_min),
	int_search([word_delta_y[69], word_delta_x[69]], first_fail, indomain_median),
	int_search([word_pos_y[68], word_pos_x[68]], smallest, indomain_min),
	int_search([word_delta_y[68], word_delta_x[68]], first_fail, indomain_median),
	int_search([word_pos_y[67], word_pos_x[67]], smallest, indomain_min),
	int_search([word_delta_y[67], word_delta_x[67]], first_fail, indomain_median),
	int_search([word_pos_y[66], word_pos_x[66]], smallest, indomain_min),
	int_search([word_delta_y[66], word_delta_x[66]], first_fail, indomain_median),
	int_search([word_pos_y[65], word_pos_x[65]], smallest, indomain_min),
	int_search([word_delta_y[65], word_delta_x[65]], first_fail, indomain_median),
	int_search([word_pos_y[64], word_pos_x[64]], smallest, indomain_min),
	int_search([word_delta_y[64], word_delta_x[64]], first_fail, indomain_median),
	int_search([word_pos_y[63], word_pos_x[63]], smallest, indomain_min),
	int_search([word_delta_y[63], word_delta_x[63]], first_fail, indomain_median),
	int_search([word_pos_y[62], word_pos_x[62]], smallest, indomain_min),
	int_search([word_delta_y[62], word_delta_x[62]], first_fail, indomain_median),
	int_search([word_pos_y[61], word_pos_x[61]], smallest, indomain_min),
	int_search([word_delta_y[61], word_delta_x[61]], first_fail, indomain_median),
	int_search([word_pos_y[60], word_pos_x[60]], smallest, indomain_min),
	int_search([word_delta_y[60], word_delta_x[60]], first_fail, indomain_median),
	int_search([word_pos_y[59], word_pos_x[59]], smallest, indomain_min),
	int_search([word_delta_y[59], word_delta_x[59]], first_fail, indomain_median),
	int_search([word_pos_y[58], word_pos_x[58]], smallest, indomain_min),
	int_search([word_delta_y[58], word_delta_x[58]], first_fail, indomain_median),
	int_search([word_pos_y[57], word_pos_x[57]], smallest, indomain_min),
	int_search([word_delta_y[57], word_delta_x[57]], first_fail, indomain_median),
	int_search([word_pos_y[56], word_pos_x[56]], smallest, indomain_min),
	int_search([word_delta_y[56], word_delta_x[56]], first_fail, indomain_median),
	int_search([word_pos_y[55], word_pos_x[55]], smallest, indomain_min),
	int_search([word_delta_y[55], word_delta_x[55]], first_fail, indomain_median),
	int_search([word_pos_y[54], word_pos_x[54]], smallest, indomain_min),
	int_search([word_delta_y[54], word_delta_x[54]], first_fail, indomain_median),
	int_search([word_pos_y[53], word_pos_x[53]], smallest, indomain_min),
	int_search([word_delta_y[53], word_delta_x[53]], first_fail, indomain_median),
	int_search([word_pos_y[52], word_pos_x[52]], smallest, indomain_min),
	int_search([word_delta_y[52], word_delta_x[52]], first_fail, indomain_median),
	int_search([word_pos_y[51], word_pos_x[51]], smallest, indomain_min),
	int_search([word_delta_y[51], word_delta_x[51]], first_fail, indomain_median),
	int_search([word_pos_y[50], word_pos_x[50]], smallest, indomain_min),
	int_search([word_delta_y[50], word_delta_x[50]], first_fail, indomain_median),
	int_search([word_pos_y[49], word_pos_x[49]], smallest, indomain_min),
	int_search([word_delta_y[49], word_delta_x[49]], first_fail, indomain_median),
	int_search([word_pos_y[48], word_pos_x[48]], smallest, indomain_min),
	int_search([word_delta_y[48], word_delta_x[48]], first_fail, indomain_median),
	int_search([word_pos_y[47], word_pos_x[47]], smallest, indomain_min),
	int_search([word_delta_y[47], word_delta_x[47]], first_fail, indomain_median),
	int_search([word_pos_y[46], word_pos_x[46]], smallest, indomain_min),
	int_search([word_delta_y[46], word_delta_x[46]], first_fail, indomain_median),
	int_search([word_pos_y[45], word_pos_x[45]], smallest, indomain_min),
	int_search([word_delta_y[45], word_delta_x[45]], first_fail, indomain_median),
	int_search([word_pos_y[44], word_pos_x[44]], smallest, indomain_min),
	int_search([word_delta_y[44], word_delta_x[44]], first_fail, indomain_median),
	int_search([word_pos_y[43], word_pos_x[43]], smallest, indomain_min),
	int_search([word_delta_y[43], word_delta_x[43]], first_fail, indomain_median),
	int_search([word_pos_y[42], word_pos_x[42]], smallest, indomain_min),
	int_search([word_delta_y[42], word_delta_x[42]], first_fail, indomain_median),
	int_search([word_pos_y[41], word_pos_x[41]], smallest, indomain_min),
	int_search([word_delta_y[41], word_delta_x[41]], first_fail, indomain_median),
	int_search([word_pos_y[40], word_pos_x[40]], smallest, indomain_min),
	int_search([word_delta_y[40], word_delta_x[40]], first_fail, indomain_median),
	int_search([word_pos_y[39], word_pos_x[39]], smallest, indomain_min),
	int_search([word_delta_y[39], word_delta_x[39]], first_fail, indomain_median),
	int_search([word_pos_y[38], word_pos_x[38]], smallest, indomain_min),
	int_search([word_delta_y[38], word_delta_x[38]], first_fail, indomain_median),
	int_search([word_pos_y[37], word_pos_x[37]], smallest, indomain_min),
	int_search([word_delta_y[37], word_delta_x[37]], first_fail, indomain_median),
	int_search([word_pos_y[36], word_pos_x[36]], smallest, indomain_min),
	int_search([word_delta_y[36], word_delta_x[36]], first_fail, indomain_median),
	int_search([word_pos_y[35], word_pos_x[35]], smallest, indomain_min),
	int_search([word_delta_y[35], word_delta_x[35]], first_fail, indomain_median),
	int_search([word_pos_y[34], word_pos_x[34]], smallest, indomain_min),
	int_search([word_delta_y[34], word_delta_x[34]], first_fail, indomain_median),
	int_search([word_pos_y[33], word_pos_x[33]], smallest, indomain_min),
	int_search([word_delta_y[33], word_delta_x[33]], first_fail, indomain_median),
	int_search([word_pos_y[32], word_pos_x[32]], smallest, indomain_min),
	int_search([word_delta_y[32], word_delta_x[32]], first_fail, indomain_median),
	int_search([word_pos_y[31], word_pos_x[31]], smallest, indomain_min),
	int_search([word_delta_y[31], word_delta_x[31]], first_fail, indomain_median),
	int_search([word_pos_y[30], word_pos_x[30]], smallest, indomain_min),
	int_search([word_delta_y[30], word_delta_x[30]], first_fail, indomain_median),
	int_search([word_pos_y[29], word_pos_x[29]], smallest, indomain_min),
	int_search([word_delta_y[29], word_delta_x[29]], first_fail, indomain_median),
	int_search([word_pos_y[28], word_pos_x[28]], smallest, indomain_min),
	int_search([word_delta_y[28], word_delta_x[28]], first_fail, indomain_median),
	int_search([word_pos_y[27], word_pos_x[27]], smallest, indomain_min),
	int_search([word_delta_y[27], word_delta_x[27]], first_fail, indomain_median),
	int_search([word_pos_y[26], word_pos_x[26]], smallest, indomain_min),
	int_search([word_delta_y[26], word_delta_x[26]], first_fail, indomain_median),
	int_search([word_pos_y[25], word_pos_x[25]], smallest, indomain_min),
	int_search([word_delta_y[25], word_delta_x[25]], first_fail, indomain_median),
	int_search([word_pos_y[24], word_pos_x[24]], smallest, indomain_min),
	int_search([word_delta_y[24], word_delta_x[24]], first_fail, indomain_median),
	int_search([word_pos_y[23], word_pos_x[23]], smallest, indomain_min),
	int_search([word_delta_y[23], word_delta_x[23]], first_fail, indomain_median),
	int_search([word_pos_y[22], word_pos_x[22]], smallest, indomain_min),
	int_search([word_delta_y[22], word_delta_x[22]], first_fail, indomain_median),
	int_search([word_pos_y[21], word_pos_x[21]], smallest, indomain_min),
	int_search([word_delta_y[21], word_delta_x[21]], first_fail, indomain_median),
	int_search([word_pos_y[20], word_pos_x[20]], smallest, indomain_min),
	int_search([word_delta_y[20], word_delta_x[20]], first_fail, indomain_median),
	int_search([word_pos_y[19], word_pos_x[19]], smallest, indomain_min),
	int_search([word_delta_y[19], word_delta_x[19]], first_fail, indomain_median),
	int_search([word_pos_y[18], word_pos_x[18]], smallest, indomain_min),
	int_search([word_delta_y[18], word_delta_x[18]], first_fail, indomain_median),
	int_search([word_pos_y[17], word_pos_x[17]], smallest, indomain_min),
	int_search([word_delta_y[17], word_delta_x[17]], first_fail, indomain_median),
	int_search([word_pos_y[16], word_pos_x[16]], smallest, indomain_min),
	int_search([word_delta_y[16], word_delta_x[16]], first_fail, indomain_median),
	int_search([word_pos_y[15], word_pos_x[15]], smallest, indomain_min),
	int_search([word_delta_y[15], word_delta_x[15]], first_fail, indomain_median),
	int_search([word_pos_y[14], word_pos_x[14]], smallest, indomain_min),
	int_search([word_delta_y[14], word_delta_x[14]], first_fail, indomain_median),
	int_search([word_pos_y[13], word_pos_x[13]], smallest, indomain_min),
	int_search([word_delta_y[13], word_delta_x[13]], first_fail, indomain_median),
	int_search([word_pos_y[12], word_pos_x[12]], smallest, indomain_min),
	int_search([word_delta_y[12], word_delta_x[12]], first_fail, indomain_median),
	int_search([word_pos_y[11], word_pos_x[11]], smallest, indomain_min),
	int_search([word_delta_y[11], word_delta_x[11]], first_fail, indomain_median),
	int_search([word_pos_y[10], word_pos_x[10]], smallest, indomain_min),
	int_search([word_delta_y[10], word_delta_x[10]], first_fail, indomain_median),
	int_search([word_pos_y[9], word_pos_x[9]], smallest, indomain_min),
	int_search([word_delta_y[9], word_delta_x[9]], first_fail, indomain_median),
	int_search([word_pos_y[8], word_pos_x[8]], smallest, indomain_min),
	int_search([word_delta_y[8], word_delta_x[8]], first_fail, indomain_median),
	int_search([word_pos_y[7], word_pos_x[7]], smallest, indomain_min),
	int_search([word_delta_y[7], word_delta_x[7]], first_fail, indomain_median),
	int_search([word_pos_y[6], word_pos_x[6]], smallest, indomain_min),
	int_search([word_delta_y[6], word_delta_x[6]], first_fail, indomain_median),
	int_search([word_pos_y[5], word_pos_x[5]], smallest, indomain_min),
	int_search([word_delta_y[5], word_delta_x[5]], first_fail, indomain_median),
	int_search([word_pos_y[4], word_pos_x[4]], smallest, indomain_min),
	int_search([word_delta_y[4], word_delta_x[4]], first_fail, indomain_median),
	int_search([word_pos_y[3], word_pos_x[3]], smallest, indomain_min),
	int_search([word_delta_y[3], word_delta_x[3]], first_fail, indomain_median),
	int_search([word_pos_y[2], word_pos_x[2]], smallest, indomain_min),
	int_search([word_delta_y[2], word_delta_x[2]], first_fail, indomain_median),
	int_search([word_pos_y[1], word_pos_x[1]], smallest, indomain_min),
	int_search([word_delta_y[1], word_delta_x[1]], first_fail, indomain_median)
	])
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