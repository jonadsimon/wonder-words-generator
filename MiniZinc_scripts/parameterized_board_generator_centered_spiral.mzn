enum Letter = { A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z }; % english letters in alphebetical order

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Variables whose values need to be passed in %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: n; % board size
int: m; % number of words

int: max_len; % length of the longest word being passed in

array [1..n^2] of int: y_pos_map; % map from spiral index to y-coordinate
array [1..n^2] of int: x_pos_map; % map from spiral index to x-coordinate

% ordering: ↑, ↖, ←, ↙, ↓, ↘, →, ↗
array [1..8] of int: y_delta_map = [-1, -1, 0, 1, 1, 1, 0, -1];
array [1..8] of int: x_delta_map = [0, -1, -1, -1, 0, 1, 1, 1];

array [1..m] of int: word_lens; % array giving the length of each word
array [1..m] of int: max_freq_idx; % array giving the index the max-frequency-letter of each word (may be unused)
array [1..m,1..max_len] of Letter: words; % array whose rows are words, with excess length padded with other letters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

array [1..n,1..n] of var Letter: board;

array [1..m] of var 1..n^2: word_pos; % values constrained by board size
array [1..m] of var 1..8: word_delta; % values constrained by {-1,0,1}


% Make dividing by 2 simpler
function int: half_word_len_floor(int: i) = word_lens[i] div 2;
function int: half_word_len_ceil(int: i) = word_lens[i] - (word_lens[i] div 2);
% function int: half_word_len_floor(int: i) = max_freq_idx[i];
% function int: half_word_len_ceil(int: i) = word_lens[i] - max_freq_idx[i];
% function int: half_word_len_floor(int: i) = 0;
% function int: half_word_len_ceil(int: i) = word_lens[i];

% For each word, enforce that its last letter lies within the board.
% Since its first letter also lies within the board, this implies that the entire word lies within the board, by convexity.
constraint forall(i in 1..m)(
  % End-of-word constraints
  y_pos_map[word_pos[i]]+y_delta_map[word_delta[i]]*(half_word_len_ceil(i)-1) >= 1
  /\ y_pos_map[word_pos[i]]+y_delta_map[word_delta[i]]*(half_word_len_ceil(i)-1) <= n
  /\ x_pos_map[word_pos[i]]+x_delta_map[word_delta[i]]*(half_word_len_ceil(i)-1) >= 1
  /\ x_pos_map[word_pos[i]]+x_delta_map[word_delta[i]]*(half_word_len_ceil(i)-1) <= n
  % Start-of-word constraints
  /\ y_pos_map[word_pos[i]]-y_delta_map[word_delta[i]]*half_word_len_floor(i) >= 1
  /\ y_pos_map[word_pos[i]]-y_delta_map[word_delta[i]]*half_word_len_floor(i) <= n
  /\ x_pos_map[word_pos[i]]-x_delta_map[word_delta[i]]*half_word_len_floor(i) >= 1
  /\ x_pos_map[word_pos[i]]-x_delta_map[word_delta[i]]*half_word_len_floor(i) <= n
);

% Link the words to the board by linking letters to board positions.
constraint forall(i in 1..m)(
  forall(j in (-1*half_word_len_floor(i)+1)..half_word_len_ceil(i))(
    words[i,half_word_len_floor(i)+j] = board[y_pos_map[word_pos[i]] + y_delta_map[word_delta[i]]*(j-1), x_pos_map[word_pos[i]] + x_delta_map[word_delta[i]]*(j-1)]
  )
);

% Search the variables in order of decreasing word length (words are passed in as shortest-to-longest).
% For each word first search the positions in min-to-max order (intuition: start from the left/top of the board then work your way in).
% Then search the orientations in horizontal-to-diagonalmax order (intuition: diagonal words interfere with more other words)

annotation pos_var_strat;
annotation pos_val_strat;

% Define position searches and orientation searches separately, then interleave them in reverse order.
solve :: seq_search([int_search([word_pos[i], word_delta[i]], input_order, indomain_min) | i in reverse(1..m)])
  satisfy;


% Function which outputs, for a given board position, whether there is a word which overlaps that position
function bool: square_is_covered(int: i, int: j) = 
  exists(k in 1..m)(
    exists(l in (-1*half_word_len_floor(k)+1)..half_word_len_ceil(k))(
      (i == fix(y_pos_map[word_pos[k]]) + fix(y_delta_map[word_delta[k]])*(l-1)) /\ (j == fix(x_pos_map[word_pos[k]]) + fix(x_delta_map[word_delta[k]])*(l-1))
  )
);

output [ if square_is_covered(i,j) then format(fix(board[i,j])) else "_" endif ++
if j == n then "\n" else " " endif | i,j in 1..n ] ++ ["\n"];