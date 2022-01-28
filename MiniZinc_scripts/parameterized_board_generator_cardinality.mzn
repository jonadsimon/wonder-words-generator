include "global_cardinality_low_up_closed.mzn";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Variables whose values need to be passed in %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: n; % board size
int: m; % number of words

int: max_len; % length of the longest word being passed in

array [1..m] of int: word_lens; % array giving the length of each word
array [1..m,1..max_len] of 1..26: words; % array whose rows are words, with excess length padded with other letters

array [1..26] of int: max_letter_counts; % array giving the total number of occurrences of each letter
array [1..26] of int: min_letter_counts; % array giving the guess-timated lower-bounds on the number of occurrences of each letter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

array [1..n,1..n] of var 1..26: board;

array [1..m] of var 1..n: word_pos_y; % values constrained by board size
array [1..m] of var 1..n: word_pos_x; % values constrained by board size
array [1..m] of var -1..1: word_delta_y; % values constrained by {-1,0,1}
array [1..m] of var -1..1: word_delta_x; % values constrained by {-1,0,1}


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

constraint global_cardinality_low_up_closed(
  array1d(board), 1..26, min_letter_counts, max_letter_counts
);

% Search the variables in order of decreasing word length (words are passed in as shortest-to-longest).
% For each word first search the positions in min-to-max order (intuition: start from the left/top of the board then work your way in).
% Then search the orientations in horizontal-to-diagonal order (intuition: diagonal words interfere with more other words)

% annotation pos_var_strat;
% annotation pos_val_strat;

% % Define position searches and orientation searches separately, then interleave them in reverse order.
% solve :: seq_search([
%   if x = 1 then int_search([word_pos_y[i], word_pos_x[i]], pos_var_strat, pos_val_strat)
%   else int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)
%   endif | i in reverse(1..m), x in 1..2])
%       satisfy;
% Define position searches and orientation searches separately, then interleave them in reverse order.
solve :: int_search(array1d(board), first_fail, indomain_max) satisfy;

% seq_search([
%   if x = 1 then int_search([word_pos_y[i], word_pos_x[i]], pos_var_strat, pos_val_strat)
%   else int_search([word_delta_y[i], word_delta_x[i]], first_fail, indomain_median)
%   endif | i in reverse(1..m), x in 1..2])
%       satisfy;


% Function which outputs, for a given board position, whether there is a word which overlaps that position
function bool: square_is_covered(int: i, int: j) = 
  exists(k in 1..m)(
    exists(l in 1..word_lens[k])(
      (i == fix(word_pos_y[k]) + fix(word_delta_y[k])*(l-1)) /\ (j == fix(word_pos_x[k]) + fix(word_delta_x[k])*(l-1))
  )
);

output [ if square_is_covered(i,j) then format(fix(board[i,j])) else "_" endif ++
if j == n then "\n" else " " endif | i,j in 1..n ] ++ ["\n"];