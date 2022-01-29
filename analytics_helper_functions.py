from collections import Counter
import numpy as np

def get_num_letters_excess(words, board_size=15):
    return sum(len(word) for word in words) / board_size**2

def get_mean_word_length(words):
    return np.mean([len(word) for word in words])

def get_max_word_length(words):
    return np.max([len(word) for word in words])

def get_num_overlaps_exact(w1, w2):
    overlaps = 0
    # Assume that w1 always has the same fixed orientation
    # (1) Assume w2 has the same orientation. Simulate passing the words over each other
    #     and testing for compatible overlaps at the head & tail. Check the reverse orientation too.
    # Pass the shorter word over the longer word.
    if len(w1) < len(w2):
        tmp1, tmp2, tmp2rev = w1, w2, w2[::-1]
    else:
        tmp1, tmp2, tmp2rev = w2, w1, w1[::-1]
    # Left overlap
    for i in range(1,len(tmp1)):
        if tmp1[-i:] == tmp2[:i]:
            overlaps += 1
        if tmp1[-i:] == tmp2rev[:i]: # check reverse orientation
            overlaps += 1
    # (ignore middle overlap because that implies one is substring of the other which is forbidden)
    # Right overlap
    for i in range(1,len(tmp1)):
        if tmp1[:i] == tmp2[-i:]:
            overlaps += 1
        if tmp1[:i] == tmp2rev[-i:]: # check reverse orientation
            overlaps += 1
    # For all other, just need to check for point-wise overlaps, and multiple the result by 6
    cnt1, cnt2 = Counter(w1), Counter(w2)
    shared_letters = set(cnt1.keys()) & set(cnt2.keys())
    for letter in shared_letters:
        overlaps += cnt1[letter] * cnt2[letter] * 6
    return overlaps

def get_num_overlaps(w1, w2, normed=True):
    """A much more efficient estimate of the number of overlaps. Just count the number of shared letter pairs,
    Don't worry about the specific geometric of words connecting end-to-end, or the multiplicity of e.g. fwd/bwd pairs.
    Good for directionally-correct estimates of the "overlapability" of a set of words.
    """
    cnt1, cnt2 = Counter(w1), Counter(w2)
    shared_letters = set(cnt1.keys()) & set(cnt2.keys())
    scale = len(w1)*len(w2) if normed else 1
    return sum(cnt1[letter]*cnt2[letter]/scale for letter in shared_letters)

def get_num_overlaps_per_word(w0, words):
    """A much more efficient estimate of the number of overlaps. Just count the number of shared letter pairs,
    Don't worry about the specific geometric of words connecting end-to-end, or the multiplicity of e.g. fwd/bwd pairs.
    Good for directionally-correct estimates of the "overlapability" of a set of words.
    """
    return sum(get_num_overlaps(w0, w) for w in words)

def get_num_overlaps_total(words):
    """A much more efficient estimate of the number of overlaps. Just count the number of shared letter pairs,
    Don't worry about the specific geometric of words connecting end-to-end, or the multiplicity of e.g. fwd/bwd pairs.
    Good for directionally-correct estimates of the "overlapability" of a set of words.

    Copied from: https://www.geeksforgeeks.org/python-all-possible-pairs-in-list/
    """
    return sum(get_num_overlaps(w1, w2) for i, w1 in enumerate(words) for w2 in words[i+1:])

def get_overlaps_pairwise(words):
    return [[get_num_overlaps(w1, w2) for w2 in words] for w1 in words]

def get_collision_avoidance_probability(w1, w2, board_size):
    """
    Given two words, what is the probability that if they are bothed placed randomly, that it will result in an inconsistency?

    This can be computed as:
        p(no_overlap) + p(overlap) x p(letter_match | overlap)
        ~ (1 - w1_area x w2_area / board_area) + (w1_area x w2_area / board_area) x num_same_letter_pairs / (w1_len x w2_len)
        ~ (1 - w1_len x w2_len / n^2) + (w1_len x w2_len / n^2) x get_num_overlaps() / (w1_len x w2_len)
        = 1 + (get_num_overlaps() - w1_len x w2_len) / n^2

    This approximation ignored the geometry of the problem and focuses instead on a simplified topology,
    wherein if two words overlap then then only overlap on a single letter, and the probabiliy of an overlap
    is independent of their proximity to the edges of the board.
    """
    p_overlap = len(w1) * len(w2) / board_size ** 2
    collision_avoidance_prob = (1 - p_overlap) + p_overlap * get_num_overlaps(w1, w2, normed=False) / (len(w1) * len(w2))
    return collision_avoidance_prob

def get_collision_avoidance_probability_pairwise(words, board_size):
    return [[get_collision_avoidance_probability(w1, w2, board_size) for w2 in words] for w1 in words]
