import random
from collections import Counter

num_words = 36
board_size = 15

def get_minizinc_code():
    words = ['rain', 'tree', 'vine', 'bird', 'biome', 'snake', 'earth', 'fauna', 'eagle', 'plant', 'swamp', 'flora', 'forest', 'jungle', 'oxygen', 'canopy', 'amazon', 'monkey', 'jaguar', 'brazil', 'branch', 'boreal', 'carbon', 'acacia', 'species', 'america', 'equator', 'savanna', 'monsoon', 'montane', 'tropics', 'tropical', 'medicine', 'woodland', 'mangrove', 'habitats', 'malaysia', 'wetlands', 'wildlife', 'peatland', 'temperate', 'indonesia', 'woodlands', 'shrubland', 'australia', 'vegetation', 'coniferous', 'eucalyptus', 'grasslands', 'ecosystems', 'madagascar', 'undergrowth', 'plantations', 'biodiversity', 'deforestation', 'photosynthesis']
    words = [word.upper() for word in words]

    words = words[:num_words] # grab the num_words shortest words; sum of word lengths should be roughly equal to board size

    # Only need to return input params, particularly the Letters set, words array, and word length array
    letters = set(''.join(words))

    word_lens = [len(word) for word in words]

    print("total letters / board size = ", sum(word_lens), "/", board_size**2, "\n")

    max_word_len = max(word_lens)

    dummy = next(iter(letters))
    words_arr = []
    for i,word in enumerate(words):
        word_arr = []
        for j in range(max_word_len):
            if j < word_lens[i]:
                word_arr.append(word[j])
            else:
                word_arr.append(dummy)
        words_arr.append(word_arr)



    return max_word_len, letters, word_lens, words_arr

if __name__ == "__main__":
    max_word_len, letters, word_lens, words_arr = get_minizinc_code()

    print('n:', board_size, '\n')
    print('m:', num_words, '\n')
    print('max_len:', max_word_len, '\n')
    print('Letter:\n' + "{ " + ", ".join(letters) + " }", '\n')
    print('word_lens:\n' + "[ " + ", ".join(map(str, word_lens)) + " ]", '\n')
    print('words:\n' + "[" + "\n\t".join(["| " + ", ".join(row) for row in words_arr]) + " |]", '\n')
