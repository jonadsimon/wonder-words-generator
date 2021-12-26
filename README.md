# wonder-words-generator
Generates WonderWords puzzles

Initial implementation mimics the brute-force approach used by Jamis Buck ([blog](https://weblog.jamisbuck.org/2015/9/26/generating-word-search-puzzles.html), [github](https://github.com/jamis/wordsearch)).

However although this works for small boards (~10x10), it is much too slow for the exponentially larger 15x15 boards. Especially those as densely packed as the official ones by David Quellet ([website](https://www.wonderword.com/)), who constructs 15x15 grids with 40-45 --> minimum 240/255 ratio.

To construct puzzles with this degree of intricacy, it is very likely that some sort of more motivated discrete optimization approach will be necessary.

Quellet is able to fit 45 words into 15x15 grid

# Notes on Naive Python Solution

Good rule-of-thumb: Assume each word overlaps with 1-2 others --> (avg_word_length - 1.5)
* 10 short words (avg=4.8) w/ 7x7 grid: takes a few seconds to find exact solution; ~48 total letters fit into 49 squares
* 40 longish words (avg=7.1) w/ 15x15 grid: killed after ~30min; ~284 total letters fit into 255 squares
* 40 medium words (avg=6.2) w/ 15x15 grid: killed after ~20min; ~248 total letters fit into 255 squares
* 19 short words (avg=5.2) w/ 10x10 grid: takes ~2min; 98 total letters fit into 100 squares
* 19 short words (avg=5.2) w/ 10x10 grid: killed after ~25min; 104 total letters fit into 100 squares
Next steps: (1) polish off current approach, hook up word-embedding logic; (2) watch discrete optimization videos; (3) use self-made branching approach; (4) rewrite in C++;

Current approach creates A LOT of parallel non-overlapping words... very uninteresting
Verified it works, puzzles are just shitty.

For the optimization want to explicitly maximize # of words packed in
But want to implicitly minimize # of word overlaps and multitude of word lengths & directions

Use same setup as early version of Pun Generator to load in the fasttext vectors (probably still have them? can feed in multi-word phrases?)

# Notes on Naive MiniZinc Solution

3 words (7 letters):
  * Geocode,  no symmetry: 126msec
  * Geocode,  w/ symmetry: 7sec
  * OR Tools, no symmetry: 419msec
  * OR Tools, w/ symmetry: 360msec
4 words (9 letters):
  * Geocode,  no symmetry: 365msec
  * Geocode,  w/ symmetry: 709msec
  * OR Tools, no symmetry: 712msec
  * OR Tools, w/ symmetry: 845msec
5 words (11 letters):
  * Geocode,  no symmetry: 3m 39s
  * Geocode,  w/ symmetry: 2m 23s
  * OR Tools, no symmetry: 51sec
  * OR Tools, w/ symmetry: 55sec
5 words, shuffled constraints (11 letters):
  * Geocode,  no symmetry: 1m 37s
  * Geocode,  w/ symmetry: 2m 23s
  * OR Tools, no symmetry: 47sec
  * OR Tools, w/ symmetry: 52sec
6 words, shuffled constraints (13 letters):
  * never completed, killed after 8min

Clearly the explosion in the number of constraints doesn't work, the solver needs to be able to make intelligent decisions, which requires having access to repeated problem structures. This is to some extent present here, but not in an excessible form.

Before overhauling the entire approach to turn it into a word-centric problem, should try to write the constraints in a more succinct way that makes use of loops.
Should be relatively easy to do this for horizontal + vertical directions, can handle diagonal later

Make an array for each word, do a forall over the array, then exists between them
Can write this up now?

Just do vertical and horizontal

Wrote simplified v3 version using compressed "exists" + "forall" representations
This does not seem to run any faster; speedup is ~2x, which is likely due to remove of diagonal constraints (i.e. 50% of constraints)

# Notes on Next-Gen MiniZinc Solution

variables are words... domain of each word is

(pos, dir, par)
pos \n [0, n^2)
dir \n [0, 4)
par \n [0, 1]

naively n^2 x 4 x 2 = ~ 2k for n=15

Add out-of-bounds constraints separately (just need to verify that most-extreme letter is still on the board)

Use Channels to convert from word-space to board-space
For all words, verify that their board-space representations agree
(look at complex examples)

f(word, pos, idx) --> board[i][j]
using the same (y, x) = (y+dy*i, x+dx*i) logic as in looping

so use dx,dy rather than dir/par

... somehow check that nearby words agree... ?

int: n = 7;
array [1..n,1..n] of var int: board;
array [1..12] of string: dict = ["R", "A", "I", "N", "T", "E", "V", "B", "D", "O", "M", "o"];

array [1..num_words] of var int: word_pos_y; # values constrained by board size
array [1..num_words] of var int: word_pos_x; # values constrained by board size
array [1..num_words] of var int: word_delta_y; # values constrained by (-1,0,1)
array [1..num_words] of var int: word_delta_x; # values constrained by (-1,0,1)


Enumerate all possible positions?

Conceptually makes much more sense to identify a "position" for each word
Therefore we are populating these much smaller length(words) arrays, and just need to enforce tethering between them

for k'th word:
  word[i] <--> board[word_pos_y[k] + word_delta_y\*i, word_pos_x[k] + word_delta_x\*i]

it is therefore ok to let words remain as enums... I think this is the way to do it, seriously
constraints are tight, no boatload of enums floating around; positions guaranteed to be near-valid, especially for large boards (i.e. not much edges)
