enum Letter = { E, R, O, A, T, L, I, S, N, M, G, C, P, D, H, W, U, K, V, F, B, Y, X, J, Z, Q }; % english letters in reverse frequency order

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Variables whose values need to be passed in %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: n; % board size
int: m; % number of words

int: max_len; % length of the longest word being passed in

array [1..m] of int: word_lens; % array giving the length of each word
array [1..m,1..max_len] of Letter: words; % array whose rows are words, with excess length padded with other letters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

array [1..n,1..n] of var Letter: board;
% array [1..n,1..n] of var int: board_cnt;
% array [1..n] of var int: per_row_overlaps;
% array [1..n] of var int: per_col_overlaps;

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

% Function which outputs, for a given board position, whether there is a word which overlaps that position
% Need to check 3 cases for each word: (1) dy==0, (2) dx==0, (3) neither
% Switch 'div' to '*' since it's just a sign flip, and otherwise throws a Chuffed error
function var int: num_coverings(var int: i, var int: j) = 
  sum(k in 1..m)(

% 18.91s Chuffed
%     let {var int: x_dist = (j - word_pos_x[k]) * word_delta_x[k]; var int: y_dist = (i - word_pos_y[k]) * word_delta_y[k];} in
%     if word_delta_y[k] == 0 then i == word_pos_y[k] /\ x_dist >= 0 /\ x_dist < word_lens[k]
%     elseif word_delta_x[k] == 0 then j == word_pos_x[k] /\ y_dist >= 0 /\ y_dist < word_lens[k]
%     else x_dist == y_dist /\ x_dist >= 0 /\ x_dist < word_lens[k] endif

% 13.58s Chuffed; this DOESN'T WORK, there's a degenerate case where (j - word_pos_x[k]) == 0 and word_delta_y[k] == 0
%     let {var int: x_dist = (j - word_pos_x[k]) * word_delta_x[k]; var int: y_dist = (i - word_pos_y[k]) * word_delta_y[k];} in
%     (word_delta_y[k] == 0 /\ i == word_pos_y[k] /\ x_dist >= 0 /\ x_dist < word_lens[k])
%     \/ (word_delta_x[k] == 0 /\ j == word_pos_x[k] /\ y_dist >= 0 /\ y_dist < word_lens[k])
%     \/ (x_dist == y_dist /\ x_dist >= 0 /\ x_dist < word_lens[k])


% 13.65s Chuffed
    let {var int: x_dist = (j - word_pos_x[k]) * word_delta_x[k]; var int: y_dist = (i - word_pos_y[k]) * word_delta_y[k];} in
    (word_delta_y[k] == 0 /\ i == word_pos_y[k] /\ x_dist >= 0 /\ x_dist < word_lens[k])
    \/ (word_delta_x[k] == 0 /\ j == word_pos_x[k] /\ y_dist >= 0 /\ y_dist < word_lens[k])
    \/ (word_delta_y[k] != 0 /\ word_delta_x[k] != 0 /\ x_dist == y_dist /\ x_dist >= 0 /\ x_dist < word_lens[k])
  
% 14.25s Chuffed
%     (word_delta_y[k] == 0 /\ i == word_pos_y[k] /\ (j - word_pos_x[k]) * word_delta_x[k] >= 0 /\ (j - word_pos_x[k]) * word_delta_x[k] < word_lens[k])
%     \/ (word_delta_x[k] == 0 /\ j == word_pos_x[k] /\ (i - word_pos_y[k]) * word_delta_y[k] >= 0 /\ (i - word_pos_y[k]) * word_delta_y[k] < word_lens[k])
%     \/ ((j - word_pos_x[k]) * word_delta_x[k] == (i - word_pos_y[k]) * word_delta_y[k] /\ (j - word_pos_x[k]) * word_delta_x[k] >= 0 /\ (j - word_pos_x[k]) * word_delta_x[k] < word_lens[k])

% 28.4s Chuffed
%     sum(l in 1..word_lens[k])(
%       (i == word_pos_y[k] + word_delta_y[k]*(l-1)) /\ (j == word_pos_x[k] + word_delta_x[k]*(l-1))
%   )
);

% Inefficient because requires iterating over all letters in all words for each board position
% However not sure if there's a way to "reuse" per-word information... ask online
% constraint forall(i in 1..n)(
%   forall(j in 1..n)(
%     board_cnt[i,j] = num_coverings(i,j)
%   )
% );

% For now just use the function, don't declare extra variables

% Enforce per row/column overlap requirements
% constraint forall(i in 1..n)(
%   exists(j in 1..n)(num_coverings(i,j) > 1)
% );
% constraint forall(j in 1..n)(
%   exists(i in 1..n)(num_coverings(i,j) > 1)
% );
% constraint forall(i in 1..n)(
%   exists(j in 1..n)(board_cnt[i,j] > 1)
% );
% constraint forall(j in 1..n)(
%   exists(i in 1..n)(board_cnt[i,j] > 1)
% );


% Enforce that each word must have at least 1 letter that is not covered by any other letters
% took 349.99s with "board_cnt[]"
% took ???s with "num_coverings()"
constraint forall(i in 1..m)(
  exists(j in 1..word_lens[i])(
%     board_cnt[word_pos_y[i] + word_delta_y[i]*(j-1), word_pos_x[i] + word_delta_x[i]*(j-1)] == 1
    num_coverings(word_pos_y[i] + word_delta_y[i]*(j-1), word_pos_x[i] + word_delta_x[i]*(j-1)) == 1
  )
);


% Search the variables in order of decreasing word length (words are passed in as shortest-to-longest).
% For each word first search the positions in min-to-max order (intuition: start from the left/top of the board then work your way in).
% Then search the orientations in horizontal-to-diagonalmax order (intuition: diagonal words interfere with more other words)

% Define position searches and orientation searches separately, then interleave them in reverse order.
% pos_searches = [int_search([word_pos_y[i], word_pos_x[i]], smallest, indomain_min) | i in i..m];
% delta_searches =  [int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)  | i in i..m];
solve :: seq_search([
  if x = 1 then int_search([word_pos_y[i], word_pos_x[i]], smallest, indomain_min)
%   if x = 1 then int_search([word_pos_y[i], word_pos_x[i]], largest, indomain_max)
%   if x = 1 then int_search([word_pos_y[i], word_pos_x[i]], first_fail, indomain_median)
  else int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)
  endif | i in reverse(1..m), x in 1..2])
  % ADD AN ALTERNATE ITERATION SCHEME THAT GOES m, 1, m-1, 2, ...
      satisfy;


% Function which outputs, for a given board position, whether there is a word which overlaps that position
function bool: square_is_covered(int: i, int: j) = 
  exists(k in 1..m)(
    exists(l in 1..word_lens[k])(
      (i == fix(word_pos_y[k]) + fix(word_delta_y[k])*(l-1)) /\ (j == fix(word_pos_x[k]) + fix(word_delta_x[k])*(l-1))
  )
);

% output [ format(fix(board_cnt[i,j])) ++
% if j == n then "\n" else " " endif | i,j in 1..n ] ++ ["\n"];

output [ if square_is_covered(i,j) then format(fix(board[i,j])) else "_" endif ++
if j == n then "\n" else " " endif | i,j in 1..n ] ++ ["\n"];