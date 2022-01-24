"""Ping relatedwords.org to get list of semantic neighbors. Works much better than simple FastText similarity."""

import time
import requests
from bs4 import BeautifulSoup
import json
import re
import math
from Levenshtein import distance as levenshtein_distance
import unidecode
from nltk.stem.porter import PorterStemmer
from collections import namedtuple, OrderedDict

WordTuple = namedtuple('WordTuple', ['pretty', 'board'])

# Consider adding an additional Word wrapper to handle downstream transformations
# Might be easier to hold on on this until *after* filtering has been performed
# Then words will be immutable and can be treated as named_tuples

# Rephrase 3 univariate filters and 4 bivariate filters to fit with these new functions
# return and print the filtered words for each

def univariate_filtering(words, filter_func):
    """Identify words in the list meeting the filtering condition, and remove them"""
    pass

def bivariate_filtering(words, similarity_func):
    """Identify pairs of words in the list meeting the similarity condition, and remove the longer of the two"""
    pass

def filter_word_strings(words):
    # Remove words shorter than 4 letters.
    words = [word for word in words if len(word) > 3]

    # Strip accents from letters
    words = [unidecode.unidecode(word) for word in words]

    # Remove words which contain characters other than: a-z/A-Z, spaces, hyphens.
    words = [word for word in words if not re.search(r"[^a-zA-Z\-\s]", word)]

    # Remove words that are identical to one another.
    # Hacky solution from https://stackoverflow.com/a/17016257/2562771
    words = list(OrderedDict.fromkeys(words))

    # Remove words that are superstrings of another existing word.
    super_words = []
    for word_sub in words:
        for word_super in words:
            if word_sub in word_super and word_sub != word_super:
                super_words.append(word_super)
    words = [word for word in words if word not in super_words]
    print(f"\nRemoved too-similar words (superstring): {', '.join(list(super_words))}")

    # Remove words of length ≥6 for which the first 70% of letters are the same
    # (Cutoffs chosen manually to increase word diversity, should make more flexible.)
    # ≥5/6 letters, ≥5/7 letters, ≥6/8 letters, etc
    # By default pick the latter word as the one to discard
    too_similar_words = set()
    for i in range(len(words)):
        for j in range(i+1, len(words)):
            if min(len(words[i]), len(words[j])) >= 6:
                prefix_len = math.ceil((0.7*min(len(words[i]), len(words[j]))))
                if words[i][:prefix_len+1] == words[j][:prefix_len+1]:
                    too_similar_words.add(words[j])
    words = [word for word in words if word not in too_similar_words]
    if too_similar_words:
        print(f"\nRemoved too-similar words (long-prefix): {', '.join(list(too_similar_words))}")

    # If a given word is dist ≤ 1 from another, need to remove one of the two
    # Should err on the side of remove the word which occurred later in the list
    # Therefore build up iteration so word2_idx > word1_idx
    too_similar_words = set()
    for i in range(len(words)):
        for j in range(i+1, len(words)):
            # If the two words differ only by a single letter
            # Deals with alternate spellings, e.g. "calender" vs "calendar"
            # Add a min-length constraint to avoid misfiring on e.g. tide/time, suda/susa
            if levenshtein_distance(words[i], words[j]) <= 1 and min(len(words[i]), len(words[j])) >= 5:
                too_similar_words.add(words[j])
    words = [word for word in words if word not in too_similar_words]
    if too_similar_words:
        print(f"\nRemoved too-similar words (Levenshtein): {', '.join(list(too_similar_words))}")

    # Substrings + Levenshtein don't catch cases where both strings are short, e.g. time/timing, marked/marking
    # Solution is to apply a stemmer and delete matching words
    too_similar_words = set()
    porter_stemmer = PorterStemmer()
    for i in range(len(words)):
        for j in range(i+1, len(words)):
            if porter_stemmer.stem(words[i]) == porter_stemmer.stem(words[j]):
                too_similar_words.add(words[j])
    words = [word for word in words if word not in too_similar_words]
    if too_similar_words:
        print(f"\nRemoved too-similar words (stemming): {', '.join(list(too_similar_words))}")

    return words



def get_related_words(word_list, score_cutoff=0.45, neighbors_cutoff=100):
    """Fetch related words from relatedwords.org, and clean them up.

    Lowered originally-chosen cufodd of 0.45 --> 0.3 because too many issues with generating puzzles."""

    # Get the related words and convert it to a clean json blob.
    # Form of the resulting json is:
    #   { 'query': <seed_word>,
    #     'terms': [
    #         {'word': <neighbor_word>, 'score': <similarity_score>, 'from': <db_source>},
    #         ...
    #         {'word': <neighbor_word>, 'score': <similarity_score>, 'from': <db_source>}
    #      ]
    #   }
    words = []
    for word in word_list:
        r = requests.get(f"https://relatedwords.org/relatedto/{word}")
        soup = BeautifulSoup(r.content, 'html.parser')
        blob = soup.find(id="preloadedDataEl")
        words_json = json.loads(blob.contents[0])

        # Trim down the words set as a function of score_cutoff and neighbors_cutoff.
        words.append((words_json["query"],1000))
        for i, term in enumerate(words_json["terms"]):
             if term["score"] > score_cutoff and i < neighbors_cutoff:
                 words.append((term["word"],term["score"]))
             else:
                 break
        # Pause for a second so the website doesn't get suspicious
        time.sleep(1.5)

    # Order words by score, then toss the score info
    words = list(zip(*sorted(words, key=lambda x: x[1], reverse=True)))[0]
    words = filter_word_strings(words)

    # Convert words to word-tuples, and operate on these going forward
    word_tuples = [WordTuple(pretty=word, board=word.replace(" ", "").replace("-", "").upper()) for word in words]

    # Identify words of varying length to hide in the puzzle, and remove them from the set of words being placed.
    hidden_word_tuple_dict = {}
    for word_tuple in word_tuples:
        if len(word_tuple.board) not in hidden_word_tuple_dict:
            hidden_word_tuple_dict.update({len(word_tuple.board): word_tuple})
    word_tuples = [word_tuple for word_tuple in word_tuples if word_tuple not in hidden_word_tuple_dict.values()]

    return word_tuples, hidden_word_tuple_dict

    # ok, still ugly, but at least all the data is there
