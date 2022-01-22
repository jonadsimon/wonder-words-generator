int: n; % board size
int: m; % number of words
float: p; % packing constant

array [1..m] of int: word_lens; % array giving the length of each word
array [1..m] of string: words; % the words themselves (used for printed)

% array [1..m,1..m] of float: overlaps; % array giving the pairwise normed overlaps of each word
array [1..m,1..m] of int: overlaps; % array giving the pairwise normed overlaps of each word

array [1..m] of var bool: use_word; % whether to include the word in the set

constraint sum(i in 1..m where use_word[i])(word_lens[i]) < p * pow(n,2);

% solve maximize sum(i in 1..m where use_word[i])(sum(j in (i+1)..m where use_word[j])(overlaps[i,j]));

% solve :: warm_start( use_word, [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false ])
%   maximize sum(i in 1..m where use_word[i])(sum(j in (i+1)..m where use_word[j])(overlaps[i,j]));

solve :: int_search(use_word, input_order, indomain_max)
%   satisfy;
% solve
  maximize sum(i in 1..m where use_word[i])(sum(j in (i+1)..m where use_word[j])(overlaps[i,j]));
  
% output [ "\nnum_words:\t" ++ format(sum(i in 1..m)(fix(use_word[i]))) ++ "\n" ];
% output [ "packing_level:\t" ++ format(sum(i in 1..m where use_word[i])(word_lens[i]) / pow(n,2)) ++ "\n" ];
% output [ "mean_word_len:\t" ++ format(sum(i in 1..m where use_word[i])(word_lens[i]) / max(sum(i in 1..m)(fix(use_word[i])),1)) ++ "\n" ];
% output [ "total_overlap:\t" ++ format(sum([overlaps[i,j] | i in 1..m, j in (i+1)..m where fix(use_word[i]) /\ fix(use_word[j])])) ++ "\n" ];
% output [ "\nwords:  " ];
% output [ show(words[i]) ++ ", " | i in 1..m where fix(use_word[i]) ];
% output [ "\n\nnon-words:  " ];
% output [ show(words[i]) ++ ", " | i in 1..m where fix(not use_word[i]) ] ++ [ "\n\n" ];

% Just return in the indices of the words that should be used in the board
% Subtract 1 to convert from Minizinc-indexing to Python-indexing
output [ format(i-1) ++ " " | i in 1..m where fix(use_word[i]) ];