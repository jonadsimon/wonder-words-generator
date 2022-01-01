import fasttext.util

# ft.get_words() : returns a length-2M list of words in reverse-frequency order
# ft.get_words(include_freq=True) : returns tuple(list[2M], np.array[2M,]) contraining words + frequencies
#
# for tie-break, ok to just use words list
# for sane-neighbor cutoff, should use frequencies too
#
# for reference, "deep-learning" has index ~500k/2M, so ~75th percentile frequency
# lesson: long tail of crap...

class Word:
    # each word should be expressible in three ways:
    # (1) board representation ("DEEPLEARNING")
    # (2) list (i.e. below-board) representation ("deep learning"/"Deep Learning")
    # (3) native (i.e. FastText) representation ("deep-learning")

    # can put pairwise word exclusion logic in here
    pass

class SemanticNeighbors:
    """Code snippets from https://towardsdatascience.com/word-embeddings-in-2020-review-with-code-examples-11eb39a1ee6d"""
    def __init__(self):
        self.ft = fasttext.load_model('data/cc.en.300.bin');
        self.word_freq_dict = self.get_word_freq_dict()

    def get_word_freq_dict(self):
        """Compute and return a dictionary mapping words to frequencies"""
        words, freqs = self.ft.get_words(include_freq=True)
        return dict(zip(words, freqs.tolist()))

    def get_neighbors(self, word, k=100, sim=0.5):
        """Compute and return the semantic nearest neighbors for a given word"""

        ft.get_nearest_neighbors(word, k=100)

    # Cleaning steps:
    # (1) superstring exclusion
    # (2) suffix-variant exclusion (rule-based)
    # (3) levenstein distance ≤ 1 exclusion
    #
    # Exclusion criteria should fix these: https://github.com/jonadsimon/wonder-words-generator/issues/4#issuecomment-1001693835

    # Make sure to append seed word w/ dot-product = 1

    # Should always/never downcase?
    # Take whichever casing is more common/closer in meaning?
