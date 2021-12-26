% 3 words:
%  - Geocode,  no symmetry: 126msec (2sec) 
%  - Geocode,  w/ symmetry: 7sec (killed after 2min)
%  - OR Tools, no symmetry: 419msec (498msec now)
%  - OR Tools, w/ symmetry: 360msec (476msec now)
% 4 words:
%  - Geocode,  no symmetry: 365msec (old)
%  - Geocode,  w/ symmetry: 709msec (old)
%  - OR Tools, no symmetry: 712msec (618msec now)
%  - OR Tools, w/ symmetry: 845msec (737msec now)
% 5 words:
%  - Geocode,  no symmetry: 3m 39s (old)
%  - Geocode,  w/ symmetry: 2m 23s (old)
%  - OR Tools, no symmetry: 51sec (1.2sec now)
%  - OR Tools, w/ symmetry: 55sec (1.4sec now)
% 6 words:
%  - Geocode,  no symmetry: [killed] (old)
%  - Geocode,  w/ symmetry: [killed] (old)
%  - OR Tools, no symmetry: [killed] (4.1sec now)
%  - OR Tools, w/ symmetry: [killed] (3.4sec now)
% 7 words:
%  - Geocode,  no symmetry: [killed] (old)
%  - Geocode,  w/ symmetry: [killed] (old)
%  - OR Tools, no symmetry: [killed] (6.6sec now)
%  - OR Tools, w/ symmetry: [killed] (6.2sec now)
% 8 words:
%  - Geocode,  no symmetry: [killed] (old)
%  - Geocode,  w/ symmetry: [killed] (old)
%  - OR Tools, no symmetry: [killed] (6.6sec now)
%  - OR Tools, w/ symmetry: [killed] (1m 52s now)

% CHUFFED TO THE FUCKING RESCUE

% 'eagle'
% probably the letter count constraint is still helpful...?

include "lex_lesseq.mzn";

int: n = 7;
int: m = 8;
array [1..n,1..n] of var Letter: board;
% enum Letter = { A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z };
% enum Letter = { R, A, I, N, T, E, V, B, D, O, M };
% enum Letter = { R, A, I, N, T, E, V };
% enum Letter = { A, E, I, N, R, T, V };
% enum Letter = { A, B, D, E, I, N, R, T, V };
% enum Letter = { A, B, D, E, I, M, N, O, R, T, V };
% enum Letter = { A, B, D, E, H, I, K, M, N, O, R, S, T, V };
enum Letter = { A, B, D, E, F, H, I, K, M, N, O, R, S, T, U, V };

array [1..4] of Letter: word1 = [R, A, I, N];
array [1..4] of Letter: word2 = [T, R, E, E];
array [1..4] of Letter: word3 = [V, I, N, E];
array [1..4] of Letter: word4 = [B, I, R, D];
array [1..5] of Letter: word5 = [B, I, O, M, E];
array [1..5] of Letter: word6 = [S, N, A, K, E];
array [1..5] of Letter: word7 = [E, A, R, T, H];
array [1..5] of Letter: word8 = [F, A, U, N, A];

array [1..m] of var int: word_pos_y; % values constrained by board size
array [1..m] of var int: word_pos_x; % values constrained by board size
array [1..m] of var int: word_delta_y; % values constrained by (-1,0,1)
array [1..m] of var int: word_delta_x; % values constrained by (-1,0,1)

constraint forall(i in 1..m)(word_pos_y[i] >= 1 /\ word_pos_y[i] <= n);
constraint forall(i in 1..m)(word_pos_x[i] >= 1 /\ word_pos_x[i] <= n);
constraint forall(i in 1..m)(word_delta_y[i] >= -1 /\ word_delta_y[i] <= 1);
constraint forall(i in 1..m)(word_delta_x[i] >= -1 /\ word_delta_x[i] <= 1);

% for each word, enforce that its extremal letter lies within the board
% consider packing the words together in an array, and keeping track of their lengths in another separate array

% words are allis within bounds
constraint word_pos_y[1]+word_delta_y[1]*length(word1) >= 1 /\ word_pos_y[1]+word_delta_y[1]*length(word1) <= n /\ word_pos_x[1]+word_delta_x[1]*length(word1) >= 1 /\ word_pos_x[1]+word_delta_x[1]*length(word1) <= n;
constraint word_pos_y[2]+word_delta_y[2]*length(word2) >= 1 /\ word_pos_y[2]+word_delta_y[2]*length(word2) <= n /\ word_pos_x[2]+word_delta_x[2]*length(word2) >= 1 /\ word_pos_x[2]+word_delta_x[2]*length(word2) <= n;
constraint word_pos_y[3]+word_delta_y[3]*length(word3) >= 1 /\ word_pos_y[3]+word_delta_y[3]*length(word3) <= n /\ word_pos_x[3]+word_delta_x[3]*length(word3) >= 1 /\ word_pos_x[3]+word_delta_x[3]*length(word3) <= n;
constraint word_pos_y[4]+word_delta_y[4]*length(word4) >= 1 /\ word_pos_y[4]+word_delta_y[4]*length(word4) <= n /\ word_pos_x[4]+word_delta_x[4]*length(word4) >= 1 /\ word_pos_x[4]+word_delta_x[4]*length(word4) <= n;
constraint word_pos_y[5]+word_delta_y[5]*length(word5) >= 1 /\ word_pos_y[5]+word_delta_y[5]*length(word5) <= n /\ word_pos_x[5]+word_delta_x[5]*length(word5) >= 1 /\ word_pos_x[5]+word_delta_x[5]*length(word5) <= n;
constraint word_pos_y[6]+word_delta_y[6]*length(word6) >= 1 /\ word_pos_y[6]+word_delta_y[6]*length(word6) <= n /\ word_pos_x[6]+word_delta_x[6]*length(word6) >= 1 /\ word_pos_x[6]+word_delta_x[6]*length(word6) <= n;
constraint word_pos_y[7]+word_delta_y[7]*length(word7) >= 1 /\ word_pos_y[7]+word_delta_y[7]*length(word7) <= n /\ word_pos_x[7]+word_delta_x[7]*length(word7) >= 1 /\ word_pos_x[7]+word_delta_x[7]*length(word7) <= n;
constraint word_pos_y[8]+word_delta_y[8]*length(word8) >= 1 /\ word_pos_y[8]+word_delta_y[8]*length(word8) <= n /\ word_pos_x[8]+word_delta_x[8]*length(word8) >= 1 /\ word_pos_x[8]+word_delta_x[8]*length(word8) <= n;

% specify word channels into the board
constraint forall(i in 1..4)(word1[i] = board[word_pos_y[1] + word_delta_y[1]*(i-1), word_pos_x[1] + word_delta_x[1]*(i-1)]);
constraint forall(i in 1..4)(word2[i] = board[word_pos_y[2] + word_delta_y[2]*(i-1), word_pos_x[2] + word_delta_x[2]*(i-1)]);
constraint forall(i in 1..4)(word3[i] = board[word_pos_y[3] + word_delta_y[3]*(i-1), word_pos_x[3] + word_delta_x[3]*(i-1)]);
constraint forall(i in 1..4)(word4[i] = board[word_pos_y[4] + word_delta_y[4]*(i-1), word_pos_x[4] + word_delta_x[4]*(i-1)]);
constraint forall(i in 1..5)(word5[i] = board[word_pos_y[5] + word_delta_y[5]*(i-1), word_pos_x[5] + word_delta_x[5]*(i-1)]);
constraint forall(i in 1..5)(word6[i] = board[word_pos_y[6] + word_delta_y[6]*(i-1), word_pos_x[6] + word_delta_x[6]*(i-1)]);
constraint forall(i in 1..5)(word7[i] = board[word_pos_y[7] + word_delta_y[7]*(i-1), word_pos_x[7] + word_delta_x[7]*(i-1)]);
constraint forall(i in 1..5)(word8[i] = board[word_pos_y[8] + word_delta_y[8]*(i-1), word_pos_x[8] + word_delta_x[8]*(i-1)]);

% constraint symmetry_breaking_constraint(
% lex_lesseq(array1d(board), [ board[j,i] | i,j in 1..n ])
% /\  lex_lesseq(array1d(board), [ board[i,j] | i in reverse(1..n), j in 1..n ])
% /\  lex_lesseq(array1d(board), [ board[j,i] | i in 1..n, j in reverse(1..n) ])
% /\  lex_lesseq(array1d(board), [ board[i,j] | i in 1..n, j in reverse(1..n) ])
% /\  lex_lesseq(array1d(board), [ board[j,i] | i in reverse(1..n), j in 1..n ])
% /\  lex_lesseq(array1d(board), [ board[i,j] | i,j in reverse(1..n) ])
% /\  lex_lesseq(array1d(board), [ board[j,i] | i,j in reverse(1..n) ])
% );

output [ format(fix(board[i,j])) ++
if j == n then "\n" else "" endif | i,j in 1..n]