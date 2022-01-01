% enum Letter = { E, A, R, I, O, T, N, S, L, C, U, D, P, M, H, G, B, F, Y, W, K, V, X, Z, J, Q }; % english letters in reverse frequency order
enum Letter = { E, R, O, A, T, L, I, S, N, M, G, C, P, D, H, W, U, K, V, F, B, Y, X, J, Z, Q };

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


% Search the variables in order of decreasing word length (words are passed in as shortest-to-longest).
% For each word first search the positions in min-to-max order (intuition: start from the left/top of the board then work your way in).
% Then search the orientations in horizontal-to-diagonalmax order (intuition: diagonal words interfere with more other words)

% Define position searches and orientation searches separately, then interleave them in reverse order.
% pos_searches = [int_search([word_pos_y[i], word_pos_x[i]], smallest, indomain_min) | i in i..m];
% delta_searches =  [int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)  | i in i..m];
solve :: seq_search([
  if x = 1 then int_search([word_pos_y[i], word_pos_x[i]], smallest, indomain_min)
  else int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)
  endif | i in reverse(1..m), x in 1..2])
      satisfy;


% Function which outputs, for a given board position, whether there is a word which overlaps that position
function bool: square_is_covered(int: i, int: j) = 
  exists(k in 1..m)(
    exists(l in 1..word_lens[k])(
      (i == fix(word_pos_y[k]) + fix(word_delta_y[k])*(l-1)) /\ (j == fix(word_pos_x[k]) + fix(word_delta_x[k])*(l-1))
  )
);

output [ if square_is_covered(i,j) then format(fix(board[i,j])) else "_" endif ++
if j == n then "\n" else " " endif | i,j in 1..n] ++ ["\n"];