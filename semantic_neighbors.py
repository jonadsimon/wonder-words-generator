"""Ping relatedwords.org to get list of semantic neighbors. Works much better than simple FastText similarity."""

import requests
from bs4 import BeautifulSoup
import json
import re

def get_related_words(word, score_cutoff=0.45, neighbors_cutoff=150):
    """Fetch related words from relatedwords.org, and clean them up."""

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

    # Remove words which contain characters other than: a-z/A-Z, spaces, hyphens.
    words = [word for word in words if not re.search(r"[^a-zA-Z\-\s]", word)]

    # Remove words that are superstrings of another existing word.
    super_words = []
    for word_sub in words:
        for word_super in words:
            if word_sub in word_super and word_sub != word_super:
                super_words.append(word_super)
    words = [word for word in words if word not in super_words]

    # Identify words of varying length to hide in the puzzle, and remove them from the set of words being placed.
    hidden_words = {}
    for word in words:
        # This is hacky, should have a word class that handles these representational differences.
        letters = word.replace(" ", "").replace("-", "").upper()
        if len(letters) not in hidden_words:
            hidden_words.update({len(letters): letters})
    words = [word for word in words if word not in hidden_words.values()]

    return words, hidden_words
