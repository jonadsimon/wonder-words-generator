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
int: n = 20; % board size
int: m = 68; % number of words
int: max_len = 8; % length of the longest word being passed in
enum Letter = { K, X, U, L, M, Y, Z, I, W, S, J, E, V, A, O, B, D, R, T, N, H, P, F, G, C }; % vocabulary (== all letters present in all words)
array [1..m] of int: word_lens = [ 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8 ]; % array giving the length of each word
array [1..m,1..max_len] of Letter: words = [| S, A, R, S, A, A, A, A
	| A, I, D, S, A, A, A, A
	| P, E, R, U, A, A, A, A
	| F, I, J, I, A, A, A, A
	| B, I, R, D, A, A, A, A
	| C, U, L, L, A, A, A, A
	| P, I, G, S, A, A, A, A
	| E, B, O, L, A, A, A, A
	| V, I, R, U, S, A, A, A
	| P, O, L, I, O, A, A, A
	| A, V, I, A, N, A, A, A
	| S, W, I, N, E, A, A, A
	| S, P, A, I, N, A, A, A
	| V, I, R, A, L, A, A, A
	| A, L, E, R, T, A, A, A
	| I, T, A, L, Y, A, A, A
	| O, N, S, E, T, A, A, A
	| A, V, E, R, T, A, A, A
	| S, C, A, R, E, A, A, A
	| T, Y, P, H, U, S, A, A
	| C, A, N, C, E, R, A, A
	| I, N, F, E, C, T, A, A
	| A, F, R, I, C, A, A, A
	| M, E, X, I, C, O, A, A
	| D, E, N, G, U, E, A, A
	| H, A, W, A, I, I, A, A
	| P, L, A, G, U, E, A, A
	| M, U, T, A, T, E, A, A
	| S, T, R, A, I, N, A, A
	| H, U, M, A, N, S, A, A
	| R, A, B, I, E, S, A, A
	| D, E, A, D, L, Y, A, A
	| I, N, S, E, C, T, A, A
	| M, A, L, A, D, Y, A, A
	| I, M, M, U, N, E, A, A
	| F, A, M, I, N, E, A, A
	| T, H, R, E, A, T, A, A
	| S, E, R, B, I, A, A, A
	| M, E, A, S, L, E, S, A
	| G, E, N, E, R, A, L, A
	| D, I, S, E, A, S, E, A
	| M, A, L, A, R, I, A, A
	| V, A, C, C, I, N, E, A
	| C, H, O, L, E, R, A, A
	| L, E, P, R, O, S, Y, A
	| E, N, D, E, M, I, C, A
	| H, I, S, T, O, R, Y, A
	| A, I, L, M, E, N, T, A
	| S, C, O, U, R, G, E, A
	| G, R, A, N, A, D, A, A
	| T, S, U, N, A, M, I, A
	| O, B, E, S, I, T, Y, A
	| F, A, L, L, O, U, T, A
	| I, L, L, N, E, S, S, A
	| R, A, V, A, G, E, S, A
	| E, P, I, D, E, M, I, C
	| S, M, A, L, L, P, O, X
	| P, A, T, H, O, G, E, N
	| Z, O, O, N, O, S, I, S
	| O, U, T, B, R, E, A, K
	| G, U, A, N, C, H, E, S
	| I, M, M, U, N, I, T, Y
	| H, O, K, K, A, I, D, O
	| S, Y, P, H, I, L, I, S
	| P, A, R, A, S, I, T, E
	| C, R, U, S, A, D, E, S
	| R, A, V, A, G, I, N, G
	| V, I, R, U, L, E, N, T |]; % array whose rows are words, with excess length padded with other letters


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

solve :: seq_search([
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
      
% Do a round-robin along the edges:
% Min x --> Min y --> Max x --> Max y
% Min pos_x --> Median delta_x --> Min pos_y --> Median delta_y --> Max x --> Median delta_x --> Max y --> Median delta_y
% solve :: seq_search([
% 	int_search([word_pos_x[68]], first_fail, indomain_min),
% 	int_search([word_delta_x[68]], first_fail, indomain_median),
% 	int_search([word_pos_y[67]], first_fail, indomain_max),
% 	int_search([word_delta_y[67]], first_fail, indomain_median),
% 	int_search([word_pos_x[66]], first_fail, indomain_max),
% 	int_search([word_delta_x[66]], first_fail, indomain_median),
% 	int_search([word_pos_y[65]], first_fail, indomain_min),
% 	int_search([word_delta_y[65]], first_fail, indomain_median),
% 	int_search([word_pos_x[64]], first_fail, indomain_min),
% 	int_search([word_delta_x[64]], first_fail, indomain_median),
% 	int_search([word_pos_y[63]], first_fail, indomain_max),
% 	int_search([word_delta_y[63]], first_fail, indomain_median),
% 	int_search([word_pos_x[62]], first_fail, indomain_max),
% 	int_search([word_delta_x[62]], first_fail, indomain_median),
% 	int_search([word_pos_y[61]], first_fail, indomain_min),
% 	int_search([word_delta_y[61]], first_fail, indomain_median),
% 	int_search([word_pos_x[60]], first_fail, indomain_min),
% 	int_search([word_delta_x[60]], first_fail, indomain_median),
% 	int_search([word_pos_y[59]], first_fail, indomain_max),
% 	int_search([word_delta_y[59]], first_fail, indomain_median),
% 	int_search([word_pos_x[58]], first_fail, indomain_max),
% 	int_search([word_delta_x[58]], first_fail, indomain_median),
% 	int_search([word_pos_y[57]], first_fail, indomain_min),
% 	int_search([word_delta_y[57]], first_fail, indomain_median),
% 	int_search([word_pos_x[56]], first_fail, indomain_min),
% 	int_search([word_delta_x[56]], first_fail, indomain_median),
% 	int_search([word_pos_y[55]], first_fail, indomain_max),
% 	int_search([word_delta_y[55]], first_fail, indomain_median),
% 	int_search([word_pos_x[54]], first_fail, indomain_max),
% 	int_search([word_delta_x[54]], first_fail, indomain_median),
% 	int_search([word_pos_y[53]], first_fail, indomain_min),
% 	int_search([word_delta_y[53]], first_fail, indomain_median),
% 	int_search([word_pos_x[52]], first_fail, indomain_min),
% 	int_search([word_delta_x[52]], first_fail, indomain_median),
% 	int_search([word_pos_y[51]], first_fail, indomain_max),
% 	int_search([word_delta_y[51]], first_fail, indomain_median),
% 	int_search([word_pos_x[50]], first_fail, indomain_max),
% 	int_search([word_delta_x[50]], first_fail, indomain_median),
% 	int_search([word_pos_y[49]], first_fail, indomain_min),
% 	int_search([word_delta_y[49]], first_fail, indomain_median),
% 	int_search([word_pos_x[48]], first_fail, indomain_min),
% 	int_search([word_delta_x[48]], first_fail, indomain_median),
% 	int_search([word_pos_y[47]], first_fail, indomain_max),
% 	int_search([word_delta_y[47]], first_fail, indomain_median),
% 	int_search([word_pos_x[46]], first_fail, indomain_max),
% 	int_search([word_delta_x[46]], first_fail, indomain_median),
% 	int_search([word_pos_y[45]], first_fail, indomain_min),
% 	int_search([word_delta_y[45]], first_fail, indomain_median),
% 	int_search([word_pos_x[44]], first_fail, indomain_min),
% 	int_search([word_delta_x[44]], first_fail, indomain_median),
% 	int_search([word_pos_y[43]], first_fail, indomain_max),
% 	int_search([word_delta_y[43]], first_fail, indomain_median),
% 	int_search([word_pos_x[42]], first_fail, indomain_max),
% 	int_search([word_delta_x[42]], first_fail, indomain_median),
% 	int_search([word_pos_y[41]], first_fail, indomain_min),
% 	int_search([word_delta_y[41]], first_fail, indomain_median),
% 	int_search([word_pos_x[40]], first_fail, indomain_min),
% 	int_search([word_delta_x[40]], first_fail, indomain_median),
% 	int_search([word_pos_y[39]], first_fail, indomain_max),
% 	int_search([word_delta_y[39]], first_fail, indomain_median),
% 	int_search([word_pos_x[38]], first_fail, indomain_max),
% 	int_search([word_delta_x[38]], first_fail, indomain_median),
% 	int_search([word_pos_y[37]], first_fail, indomain_min),
% 	int_search([word_delta_y[37]], first_fail, indomain_median),
% 	int_search([word_pos_x[36]], first_fail, indomain_min),
% 	int_search([word_delta_x[36]], first_fail, indomain_median),
% 	int_search([word_pos_y[35]], first_fail, indomain_max),
% 	int_search([word_delta_y[35]], first_fail, indomain_median),
% 	int_search([word_pos_x[34]], first_fail, indomain_max),
% 	int_search([word_delta_x[34]], first_fail, indomain_median),
% 	int_search([word_pos_y[33]], first_fail, indomain_min),
% 	int_search([word_delta_y[33]], first_fail, indomain_median),
% 	int_search([word_pos_x[32]], first_fail, indomain_min),
% 	int_search([word_delta_x[32]], first_fail, indomain_median),
% 	int_search([word_pos_y[31]], first_fail, indomain_max),
% 	int_search([word_delta_y[31]], first_fail, indomain_median),
% 	int_search([word_pos_x[30]], first_fail, indomain_max),
% 	int_search([word_delta_x[30]], first_fail, indomain_median),
% 	int_search([word_pos_y[29]], first_fail, indomain_min),
% 	int_search([word_delta_y[29]], first_fail, indomain_median),
% 	int_search([word_pos_x[28]], first_fail, indomain_min),
% 	int_search([word_delta_x[28]], first_fail, indomain_median),
% 	int_search([word_pos_y[27]], first_fail, indomain_max),
% 	int_search([word_delta_y[27]], first_fail, indomain_median),
% 	int_search([word_pos_x[26]], first_fail, indomain_max),
% 	int_search([word_delta_x[26]], first_fail, indomain_median),
% 	int_search([word_pos_y[25]], first_fail, indomain_min),
% 	int_search([word_delta_y[25]], first_fail, indomain_median),
% 	int_search([word_pos_x[24]], first_fail, indomain_min),
% 	int_search([word_delta_x[24]], first_fail, indomain_median),
% 	int_search([word_pos_y[23]], first_fail, indomain_max),
% 	int_search([word_delta_y[23]], first_fail, indomain_median),
% 	int_search([word_pos_x[22]], first_fail, indomain_max),
% 	int_search([word_delta_x[22]], first_fail, indomain_median),
% 	int_search([word_pos_y[21]], first_fail, indomain_min),
% 	int_search([word_delta_y[21]], first_fail, indomain_median),
% 	int_search([word_pos_x[20]], first_fail, indomain_min),
% 	int_search([word_delta_x[20]], first_fail, indomain_median),
% 	int_search([word_pos_y[19]], first_fail, indomain_max),
% 	int_search([word_delta_y[19]], first_fail, indomain_median),
% 	int_search([word_pos_x[18]], first_fail, indomain_max),
% 	int_search([word_delta_x[18]], first_fail, indomain_median),
% 	int_search([word_pos_y[17]], first_fail, indomain_min),
% 	int_search([word_delta_y[17]], first_fail, indomain_median),
% 	int_search([word_pos_x[16]], first_fail, indomain_min),
% 	int_search([word_delta_x[16]], first_fail, indomain_median),
% 	int_search([word_pos_y[15]], first_fail, indomain_max),
% 	int_search([word_delta_y[15]], first_fail, indomain_median),
% 	int_search([word_pos_x[14]], first_fail, indomain_max),
% 	int_search([word_delta_x[14]], first_fail, indomain_median),
% 	int_search([word_pos_y[13]], first_fail, indomain_min),
% 	int_search([word_delta_y[13]], first_fail, indomain_median),
% 	int_search([word_pos_x[12]], first_fail, indomain_min),
% 	int_search([word_delta_x[12]], first_fail, indomain_median),
% 	int_search([word_pos_y[11]], first_fail, indomain_max),
% 	int_search([word_delta_y[11]], first_fail, indomain_median),
% 	int_search([word_pos_x[10]], first_fail, indomain_max),
% 	int_search([word_delta_x[10]], first_fail, indomain_median),
% 	int_search([word_pos_y[9]], first_fail, indomain_min),
% 	int_search([word_delta_y[9]], first_fail, indomain_median),
% 	int_search([word_pos_x[8]], first_fail, indomain_min),
% 	int_search([word_delta_x[8]], first_fail, indomain_median),
% 	int_search([word_pos_y[7]], first_fail, indomain_max),
% 	int_search([word_delta_y[7]], first_fail, indomain_median),
% 	int_search([word_pos_x[6]], first_fail, indomain_max),
% 	int_search([word_delta_x[6]], first_fail, indomain_median),
% 	int_search([word_pos_y[5]], first_fail, indomain_min),
% 	int_search([word_delta_y[5]], first_fail, indomain_median),
% 	int_search([word_pos_x[4]], first_fail, indomain_min),
% 	int_search([word_delta_x[4]], first_fail, indomain_median),
% 	int_search([word_pos_y[3]], first_fail, indomain_max),
% 	int_search([word_delta_y[3]], first_fail, indomain_median),
% 	int_search([word_pos_x[2]], first_fail, indomain_max),
% 	int_search([word_delta_x[2]], first_fail, indomain_median),
% 	int_search([word_pos_y[1]], first_fail, indomain_min),
% 	int_search([word_delta_y[1]], first_fail, indomain_median),
% 	])
%       satisfy;

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