def parse_minizinc_output():
    board_raw = """P I N A T A P A N E R A S M L B V N
O Y A V E E U R O P E O E O R E I F
B Z C E M S L U R P R Z N U N B E R
L Z H N P E Q E J B C D L I B C N A
E I O T E P U A E A O E C L O O N N
T F S E H C E T L N E E E F T S A C
F R E S C A R P L O Q C F O C M V E
R A H S C O N E S U C E R A E O C C
O P C E T E G E A I E T C E D E O R
T P E A U A T R I M A A A K M V R E
H E L D B A T H C E O M A P E E K M
Y E N U H S Q U E S O H E N A E S A
G O C C E Y G O D R S F T V I S T F
F A T T E O T S K I F I A A O M O L
T A T K N I U N W A E J H D E I F A
M A R G J G I S C D E C A F E L U N
L U G O E R U M B A O T I L A K E E
T E M N D A I R Y M P I N T E E E E"""

    word_lens_raw = """4 4 4 4 4 4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6 6"""
    pos_ys_raw = """14 13 16 11 4 13 13 10 17 16 8 15 18 18 16 10 11 3 16 16 9 16 8 6 12 11 8 7 7 9 7 7 17 6 6 5 18 18 18 8 4 2 4 18 18 6 2 2 18 17 16 1 15 14 13 7 1 7 1 1 1 1 1 1 1 1 1 1 1"""
    pos_xs_raw = """16 16 12 12 9 18 17 9 12 12 11 12 11 10 10 16 5 6 9 9 12 8 18 2 7 3 17 12 17 6 15 11 6 15 6 6 5 5 4 4 16 4 16 3 2 2 6 18 1 1 1 17 1 1 1 1 7 1 18 17 16 3 15 14 13 7 5 1 1"""
    delta_ys_raw = """1 1 -1 -1 1 1 1 1 0 0 -1 -1 0 -1 0 1 -1 0 -1 -1 1 -1 1 -1 0 -1 1 1 1 1 1 1 0 1 1 1 0 -1 -1 0 1 1 1 -1 -1 1 0 1 -1 -1 -1 1 -1 -1 -1 0 1 1 1 1 1 1 1 1 1 0 1 1 0"""
    delta_xs_raw = """0 -1 1 0 0 0 0 0 1 1 -1 1 1 1 1 -1 1 1 1 1 1 1 0 0 1 0 0 1 -1 1 -1 -1 1 -1 1 1 1 1 1 1 0 0 -1 1 1 0 1 0 1 1 1 0 1 1 1 1 0 0 -1 -1 -1 0 -1 -1 -1 1 0 0 1"""

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
