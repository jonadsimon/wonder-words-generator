from recordclass import recordclass
from collections import namedtuple
import random

# Square must be a recordclass since it needs to be mutable
# See: https://stackoverflow.com/questions/29290359/existence-of-mutable-named-tuple-in-python
Square = recordclass('Square', ['letter', 'count'], defaults=[0, 0])
Position = namedtuple('Position', ['y', 'x', 'dy', 'dx'])


class Board:
    def __init__(self, size):
        self.size = size
        self.board = [[Square() for _ in range(size)] for _ in range(size)]
        self.empty_squares = size**2
        self.word_position_cache = {} # maps word length to list of possible positions; is populated at word lengths are encountered (otherwise they need to be repeatedly recomputed)


    def get_possible_word_positions(self, word):
        """Get positions for a given word that are permissible given the board boundaries."""
        # If the possibilities have already been computed for this word length, permute and return it.
        if len(word) in self.word_position_cache:
            return random.sample(self.word_position_cache[len(word)], len(self.word_position_cache[len(word)]))

        # Each delta combination corresponds to a direction:
        #   1. horizontal, forward: dy=0, dx=+1
        #   2. horizontal, backward: dy=0, dx=-1
        #   3. vertical, forward: dy=+1, dx=0
        #   4. vertical, backward: dy=-1, dx=0
        #   5. diagonal bottom-left to top-right, forward: dy=-1, dx=+1
        #   6. diagonal bottom-left to top-right, backward: dy=+1, dx=-1
        #   7. diagonal top-left to bottom-right, forward: dy=+1, dx=+1
        #   8. diagonal top-left to bottom-right, backward: dy=-1, dx=-1
        positions = []
        for y in range(self.size):
            for x in range(self.size):
                for dy in (-1,0,1):
                    for dx in (-1,0,1):
                        # Check that the word doesn't overrun the board boundaries.
                        if (0 <= y + dy*len(word) < self.size) and (0 <= x + dx*len(word) < self.size):
                            positions.append(Position(y, x, dy, dx))

        # Add the newly-computed valid positions to the cache, and return a permuted version of it.
        self.word_position_cache[len(word)] = positions
        return random.sample(positions, len(word))


    def add_to_board(self, word, pos):
        """Attempt to add the word to the board, and return the success status of the operation."""

        for idx in range(len(word)):
            square = self.board[pos.y+pos.dy*idx][pos.x+pos.dx*idx]

            # Square is currently empty, so add the letter and decrement empty_squares.
            if not square.letter:
                square.letter = word[idx]
                square.count = 1
                self.empty_squares -= 1
            # Square contains the matching letter, so increment the count.
            elif square.letter == word[idx]:
                square.count += 1
            # Square contains a conflicting letter, so roll-back the changes.
            else:
                self.remove_from_board(word[:idx], pos)
                return False

        # All letters were added, so return success status true.
        return True


    def remove_from_board(self, word, pos):
        """Remove previously-added word from the board"""
        for idx in range(len(word)):
            square = self.board[pos.y+pos.dy*idx][pos.x+pos.dx*idx]

            square.count -= 1

            # If square is now empty, wipe the record and increment empty_squares.
            if square.count == 0:
                square.letter = 0
                square.count = 0
                self.empty_squares += 1


    def place_special_word(self, word):
        word_idx = 0
        for row in self.board:
            for square in row:
                if not square.letter:
                    square.letter = word[word_idx]
                    square.count = 1 # for consistency
                    word_idx += 1
                if word_idx == len(word):
                    return # all letters have been filled, so terminate the function


    def __str__(self):
        s = ''
        for row in self.board:
            for square in row:
                s += ' ' + str(square.letter)
            s += '\n'
        return s
