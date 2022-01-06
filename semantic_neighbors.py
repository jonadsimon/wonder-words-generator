"""Ping relatedwords.org to get list of semantic neighbors. Works much better than simple FastText similarity."""

import requests
from bs4 import BeautifulSoup
import json
import re
import math
from Levenshtein import distance as levenshtein_distance
import unidecode
from nltk.stem.porter import PorterStemmer

def get_related_words(word, score_cutoff=0.3, neighbors_cutoff=150):
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
    r = requests.get(f"https://relatedwords.org/relatedto/{word}")
    soup = BeautifulSoup(r.content, 'html.parser')
    blob = soup.find(id="preloadedDataEl")
    words_json = json.loads(blob.contents[0])

    # Trim down the words set as a function of score_cutoff and neighbors_cutoff.
    words = [words_json["query"]]
    for i, term in enumerate(words_json["terms"]):
         if term["score"] > score_cutoff and i < neighbors_cutoff:
             words.append(term["word"])
         else:
             break

    # Remove words shorter than 4 letters.
    words = [word for word in words if len(word) > 3]

    # Strip accents from letters
    words = [unidecode.unidecode(word) for word in words]

    # Remove words which contain characters other than: a-z/A-Z, spaces, hyphens.
    words = [word for word in words if not re.search(r"[^a-zA-Z\-\s]", word)]

    # Remove words that are superstrings of another existing word.
    super_words = []
    for word_sub in words:
        for word_super in words:
            if word_sub in word_super and word_sub != word_super:
                super_words.append(word_super)
    words = [word for word in words if word not in super_words]
    print(f"Removed too-similar words (superstring): {', '.join(list(super_words))}")

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
        print(f"Removed too-similar words (long-prefix): {', '.join(list(too_similar_words))}")

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
        print(f"Removed too-similar words (Levenshtein): {', '.join(list(too_similar_words))}")

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
        print(f"Removed too-similar words (stemming): {', '.join(list(too_similar_words))}")


    # Identify words of varying length to hide in the puzzle, and remove them from the set of words being placed.
    hidden_words = {}
    for word in words:
        # This is hacky, should have a word class that handles these representational differences.
        letters = word.replace(" ", "").replace("-", "").upper()
        if len(letters) not in hidden_words:
            hidden_words.update({len(letters): letters})
    words = [word for word in words if word.replace(" ", "").replace("-", "").upper() not in hidden_words.values()]

    return words, hidden_words
