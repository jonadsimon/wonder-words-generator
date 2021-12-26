int: n;
enum Letters = { o, A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z }; % add special dummy letter to fill in blanks with
array [1..n,1..n] of var Letters: board;

% write out the per-word contraints manually, each of them separate

constraint (board[1,1] = A) /\ (board[1,2] = B) \/ (board[2,1] = A) /\ (board[2,2] = B) \/ (board[1,1] = A) /\ (board[2,1] = B) \/ (board[1,2] = A) /\ (board[2,2] = B) \/ (board[1,1] = A) /\ (board[2,2] = B) \/ (board[2,1] = A) /\ (board[1,2] = B);

constraint (board[1,1] = B) /\ (board[1,2] = C) \/ (board[2,1] = B) /\ (board[2,2] = C) \/ (board[1,1] = B) /\ (board[2,1] = C) \/ (board[1,2] = B) /\ (board[2,2] = C) \/ (board[1,1] = B) /\ (board[2,2] = C) \/ (board[2,1] = B) /\ (board[1,2] = C);

constraint (board[1,1] = A) /\ (board[1,2] = C) \/ (board[2,1] = A) /\ (board[2,2] = C) \/ (board[1,1] = A) /\ (board[2,1] = C) \/ (board[1,2] = A) /\ (board[2,2] = C) \/ (board[1,1] = A) /\ (board[2,2] = C) \/ (board[2,1] = A) /\ (board[1,2] = C);

% output [ if fix(q[j]) == i then "Q" else "." endif ++
%          if j == n then "\n" else "" endif | i,j in 1..n]

output [ format(fix(board[i,j])) ++
         if j == n then "\n" else "" endif | i,j in 1..n]