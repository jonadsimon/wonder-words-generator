def parse_minizinc_output():
    board_raw = """T G M S N R A E A M S I M U L A T O R T M C T H S
E Y A A P A U U T U I U N I M A T E E R E O E A T
L R C S C A N N T Y T N B E N H T R A E C M L R E
E O H T C H C O A O M O I M R D S A C U H P E D A
S S I A E A I E M R M O M A A T T O T S A U T W L
C C N I S T N N S E O A L A T R I O I A N T Y A T
O O I R E I H N I H T U T O T U I A O B I E P R H
P P M W P Q M E I S I R N O G I R N N L C R E E Y
E E A A K I U U R N T P E D N Y C E E E A O H B G
S G U Y S E L I L E G F S Z O F L I G H T B U A A
E E T D L H Y O P A D B A E A C T R O B A O M L L
N S O A E O U B T P T M A I N M K F A A P N A L I
S T M N C C A T O I E E A T R S B I I A U A N B L
I U A D O T O D T A N D P C T I O O N T L U O O E
N R T R M O I D S L R G M U H E N R N G T T I T O
G E E O B I C L E C E D W O L I R G S I H E D M A
M O A I E L Y A E R H S R I M L N Y P M U W D E P
A O P D R E B N N F D U P O N E E E A U B E E D O
N S D T L T O D O I L U N R N G N Y C S B I V U L
N H L U I A R E R R N A M K I E E T E C L G I S L
E A O I L C G R I I B E M M A N S D X L E H C A O
D J A N N E S U O M L I A E Y A G R A E G T E A B
H I L L D G S O N A R L T C R A F T W H E E L A I
D E L F T A S I M O L A S E R A D A R L I D A R A
R O B O T M A R S V T O L N A S A A A A A A A A A"""

    word_lens_raw = """4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 8 9 9 9 9 9 9 9 9 9 9 9 9 9"""
    pos_ys_raw = """25 25 22 25 1 24 7 23 25 23 22 24 24 24 24 22 24 23 23 19 19 20 19 11 3 19 18 18 16 17 17 17 17 17 17 17 16 16 16 16 16 16 12 16 16 15 15 14 14 13 10 12 12 11 11 2 11 10 9 10 10 1 8 10 10 10 9 9 9 8 9 9 8 8 7 6 4 3 2 3 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1"""
    pos_xs_raw = """14 10 21 6 20 25 20 1 1 7 10 20 15 11 6 2 1 19 14 8 9 2 9 21 20 2 11 10 7 23 22 20 12 2 1 1 12 25 8 24 21 19 18 13 7 13 9 13 6 5 16 4 12 12 3 12 4 14 14 13 12 12 2 5 2 1 25 24 23 22 5 3 21 5 5 5 4 4 20 4 25 19 24 23 22 21 13 11 11 10 9 8 7 6 3 5 4 3 2 1"""
    delta_ys_raw = """0 0 0 0 0 -1 -1 0 0 0 0 0 0 0 0 -1 0 0 0 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1"""
    delta_xs_raw = """1 1 -1 1 -1 0 -1 1 1 1 -1 1 1 1 1 1 1 1 1 1 0 1 1 -1 -1 1 1 1 0 0 0 0 1 1 1 0 1 0 0 0 0 0 1 1 1 1 1 1 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 1 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 0 0 0"""

    # Parse the inputs.
    board = [row.split() for row in board_raw.split("\n")]
    word_lens = [int(x) for x in word_lens_raw.split()]
    pos_ys = [int(x) for x in pos_ys_raw.split()]
    pos_xs = [int(x) for x in pos_xs_raw.split()]
    delta_ys = [int(x) for x in delta_ys_raw.split()]
    delta_xs = [int(x) for x in delta_xs_raw.split()]

    # Generate a new zero'ed out board.
    board_fresh = [["_" for _ in range(len(board))] for _ in range(len(board))]
    for i,l in enumerate(word_lens):
        for k in range(l):
            y = pos_ys[i] - 1 + delta_ys[i]*k
            x = pos_xs[i] - 1 + delta_xs[i]*k
            board_fresh[y][x] = board[y][x]

    for row in board_fresh:
        print(" ".join(row))

    print("\nLeftover squares:", sum([sum([1 for _ in row if _ == "_"]) for row in board_fresh]))

if __name__ == "__main__":
    parse_minizinc_output()

# "happyholidays" - 13
# "merrychristmas" - 14
# "verymerrychristmas" - 18
# "icallitajonderword" - 18
# "merrychristmasmaria" - 19
# "haveamerrychristmas" - 19
# "doyoulikeyourpresent" - 20
# "mariachristmaspresent" - 21
# "mariaschristmaspresent" - 22
# "howdoyoulikeyourpresent" - 23
# "haveaverymerrychristmas" - 23
# "ihopeyoulikeyourpresent" - 23
# "doesmarialikeherpresent" - 23
# "thistookalongtimetomake" - 23
# "doyoulikeyourjonderword" - 23
# "mariadoyoulikethepresent" - 24
# "mariadoyoulikeyourpresent" - 25
# "whatdoyouthinkofyourpresent" - 27
