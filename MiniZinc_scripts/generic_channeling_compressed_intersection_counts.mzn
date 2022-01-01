% Variables whose values need to be passed in
int: n = 20; % board size
int: m = 76; % number of words

% array [1..n] of int: reindex = [1, 20, 2, 19, 3, 18, 4, 17, 5, 16, 6, 15, 7, 14, 8, 13, 9, 12, 10, 11];

int: max_len = 7; % length of the longest word being passed in
enum Letter = { E, A, R, I, T, S, P, N, O, L, C, D, G, U, H, M, F, Y, W, K, B, V, X, J }; % vocabulary (== all letters present in all words)
array [1..m] of int: word_lens = [ 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 ]; % array giving the length of each word
array [1..m,1..max_len] of Letter: words = [| P, L, A, N, E, E, E
	| S, H, O, W, E, E, E
	| W, O, R, K, E, E, E
	| L, O, O, P, E, E, E
	| H, A, C, K, E, E, E
	| N, E, W, S, E, E, E
	| I, N, F, O, E, E, E
	| B, I, L, L, E, E, E
	| I, D, E, A, E, E, E
	| C, O, D, E, E, E, E
	| A, I, M, S, E, E, E
	| F, U, L, L, E, E, E
	| C, A, R, E, E, E, E
	| P, A, R, T, E, E, E
	| P, R, O, G, E, E, E
	| D, E, B, U, G, E, E
	| R, E, R, U, N, E, E
	| P, A, T, C, H, E, E
	| L, O, G, I, N, E, E
	| F, O, C, U, S, E, E
	| N, E, E, D, S, E, E
	| S, T, U, D, Y, E, E
	| C, A, L, L, S, E, E
	| G, N, O, M, E, E, E
	| S, Y, S, T, E, M, E
	| P, A, R, S, E, R, E
	| T, A, G, G, E, R, E
	| S, C, H, E, M, E, E
	| R, E, G, I, M, E, E
	| S, E, R, I, E, S, E
	| A, G, E, N, D, A, E
	| G, R, A, N, T, S, E
	| A, D, W, A, R, E, E
	| B, U, D, G, E, T, E
	| P, A, P, E, R, S, E
	| D, O, C, K, E, T, E
	| B, I, N, A, R, Y, E
	| D, E, S, I, G, N, E
	| S, C, H, E, M, A, E
	| S, E, R, I, A, L, E
	| S, P, I, D, E, R, E
	| T, E, L, N, E, T, E
	| T, E, C, H, I, E, E
	| A, P, P, L, E, T, E
	| K, L, U, D, G, E, E
	| F, U, N, D, E, D, E
	| O, F, F, E, R, S, E
	| R, E, V, I, E, W, E
	| P, O, L, I, C, Y, E
	| K, E, Y, G, E, N, E
	| E, F, F, O, R, T, E
	| A, G, E, N, C, Y, E
	| E, X, P, A, N, D, E
	| P, U, B, L, I, C, E
	| H, E, A, L, T, H, E
	| L, A, U, N, C, H, E
	| E, N, T, I, R, E, E
	| S, I, T, C, O, M, E
	| T, I, T, L, E, R, E
	| P, R, O, J, E, C, T
	| P, A, C, K, A, G, E
	| O, U, T, L, I, N, E
	| F, U, N, D, I, N, G
	| S, E, R, V, I, C, E
	| S, U, P, P, O, R, T
	| S, P, Y, W, A, R, E
	| P, A, T, T, E, R, N
	| C, O, M, M, A, N, D
	| R, O, U, T, I, N, E
	| U, T, I, L, I, T, Y
	| T, H, O, U, G, H, T
	| E, P, I, S, O, D, E
	| M, A, L, W, A, R, E
	| A, I, R, T, I, M, E
	| P, R, O, V, I, D, E
	| S, P, E, C, I, A, L |]; % array whose rows are words, with excess length padded with other letters


array [1..n,1..n] of var Letter: board;
array [1..n,1..n] of int: overlap_count;

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

% % Count number of words occupying each square
% constraint sum(i,j in 1..m where i < j)(
%   sum(k in 1..word_lens[i])(
%     sum(l in 1..word_lens[j])(
%       int((word_pos_y[i] + word_delta_y[i]*(k-1) == word_pos_y[j] + word_delta_y[j]*(l-1)) /\ (word_pos_x[i] + word_delta_x[i]*(k-1) == word_pos_x[j] + word_delta_x[j]*(l-1)))
%     )
%   )
% ) > 0.2 * 

% Uses the triangle inqequality to check that a word overlaps a square
function float: dist(y1, x2, y2, x2) = pow( pow(y1-y2, 2) + pow(x1-x2, 2), 0.5)
function bool: word_overlaps_square(word_idx, board_y, board_x) =
         abs(x1 - x2) + abs(y1 - y2);
         
constraint forall(i,j in 1..n)(
  % check angles match & 
  overlap_count[i,j] = sum(k in 1..m)(dist((word_pos_y[k],word_pos_x[k]),(i,j)) + ((i,j),(word_pos_y[k]+word_delta_y[k]*word_lens[k],word_pos_x[k]+word_delta_x[k]*word_lens[k]))
)

constraint forall(i in 1..m)(
  forall(j in 1..word_lens[i])(
    words[i,j] = board[word_pos_y[i] + word_delta_y[i]*(j-1), word_pos_x[i] + word_delta_x[i]*(j-1)]
  )
);

% If we called together all 4 constraint arrayed, could generate these re-ordings on the fly...
% solve :: int_search(reverse(word_pos_y) ++ reverse(word_pos_x), most_constrained, indomain_min) satisfy;

% solve :: int_search([word_pos_y[76], word_pos_x[76], word_pos_y[75], word_pos_x[75], word_pos_y[74], word_pos_x[74], word_pos_y[73], word_pos_x[73], word_pos_y[72], word_pos_x[72], word_pos_y[71], word_pos_x[71], word_pos_y[70], word_pos_x[70], word_pos_y[69], word_pos_x[69], word_pos_y[68], word_pos_x[68], word_pos_y[67], word_pos_x[67], word_pos_y[66], word_pos_x[66], word_pos_y[65], word_pos_x[65], word_pos_y[64], word_pos_x[64], word_pos_y[63], word_pos_x[63], word_pos_y[62], word_pos_x[62], word_pos_y[61], word_pos_x[61], word_pos_y[60], word_pos_x[60], word_pos_y[59], word_pos_x[59], word_pos_y[58], word_pos_x[58], word_pos_y[57], word_pos_x[57], word_pos_y[56], word_pos_x[56], word_pos_y[55], word_pos_x[55], word_pos_y[54], word_pos_x[54], word_pos_y[53], word_pos_x[53], word_pos_y[52], word_pos_x[52], word_pos_y[51], word_pos_x[51], word_pos_y[50], word_pos_x[50], word_pos_y[49], word_pos_x[49], word_pos_y[48], word_pos_x[48], word_pos_y[47], word_pos_x[47], word_pos_y[46], word_pos_x[46], word_pos_y[45], word_pos_x[45], word_pos_y[44], word_pos_x[44], word_pos_y[43], word_pos_x[43], word_pos_y[42], word_pos_x[42], word_pos_y[41], word_pos_x[41], word_pos_y[40], word_pos_x[40], word_pos_y[39], word_pos_x[39], word_pos_y[38], word_pos_x[38], word_pos_y[37], word_pos_x[37], word_pos_y[36], word_pos_x[36], word_pos_y[35], word_pos_x[35], word_pos_y[34], word_pos_x[34], word_pos_y[33], word_pos_x[33], word_pos_y[32], word_pos_x[32], word_pos_y[31], word_pos_x[31], word_pos_y[30], word_pos_x[30], word_pos_y[29], word_pos_x[29], word_pos_y[28], word_pos_x[28], word_pos_y[27], word_pos_x[27], word_pos_y[26], word_pos_x[26], word_pos_y[25], word_pos_x[25], word_pos_y[24], word_pos_x[24], word_pos_y[23], word_pos_x[23], word_pos_y[22], word_pos_x[22], word_pos_y[21], word_pos_x[21], word_pos_y[20], word_pos_x[20], word_pos_y[19], word_pos_x[19], word_pos_y[18], word_pos_x[18], word_pos_y[17], word_pos_x[17], word_pos_y[16], word_pos_x[16], word_pos_y[15], word_pos_x[15], word_pos_y[14], word_pos_x[14], word_pos_y[13], word_pos_x[13], word_pos_y[12], word_pos_x[12], word_pos_y[11], word_pos_x[11], word_pos_y[10], word_pos_x[10], word_pos_y[9], word_pos_x[9], word_pos_y[8], word_pos_x[8], word_pos_y[7], word_pos_x[7], word_pos_y[6], word_pos_x[6], word_pos_y[5], word_pos_x[5], word_pos_y[4], word_pos_x[4], word_pos_y[3], word_pos_x[3], word_pos_y[2], word_pos_x[2], word_pos_y[1], word_pos_x[1]], input_order, indomain_min) satisfy;

solve :: seq_search([
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