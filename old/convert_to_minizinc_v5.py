import random
from collections import Counter

num_words = 37
board_size = 15

def get_minizinc_code():
    words = ['rain', 'tree', 'vine', 'bird', 'biome', 'snake', 'earth', 'fauna', 'eagle', 'plant', 'swamp', 'flora', 'forest', 'jungle', 'oxygen', 'canopy', 'amazon', 'monkey', 'jaguar', 'brazil', 'branch', 'boreal', 'carbon', 'acacia', 'species', 'america', 'equator', 'savanna', 'monsoon', 'montane', 'tropics', 'tropical', 'medicine', 'woodland', 'mangrove', 'habitats', 'malaysia', 'wetlands', 'wildlife', 'peatland', 'temperate', 'indonesia', 'woodlands', 'shrubland', 'australia', 'vegetation', 'coniferous', 'eucalyptus', 'grasslands', 'ecosystems', 'madagascar', 'undergrowth', 'plantations', 'biodiversity', 'deforestation', 'photosynthesis']
    words = [word.upper() for word in words]

    words = words[:num_words] # grab the num_words shortest words; sum of word lengths should be roughly equal to board size

    letter_counts_ub = Counter(''.join(words))
    letter_counts_lb = {ltr: max(cnt//2, 1) for ltr, cnt in letter_counts_ub.most_common()} # assume each letter instance is used by at most 2 words on average; round down to relax, may need to relax this later

    letter_to_num_map = {ltr: i for i, ltr in enumerate(letter_counts_ub.keys())}
    num_to_letter_map = {v: k for k, v in letter_to_num_map.items()}

    # this assumes dict.keys() returns things in the same order every time... need to double check
    ordered_nums = list(num_to_letter_map.keys())
    lower_bounds = [letter_counts_lb[num_to_letter_map[num]] for num in num_to_letter_map.keys()]
    upper_bounds = [letter_counts_ub[num_to_letter_map[num]] for num in num_to_letter_map.keys()]

    # needed for printing
    ordered_letters = [num_to_letter_map[i] for i in range(len(num_to_letter_map))]

    word_lens = [len(word) for word in words]

    print("total letters / board size = ", sum(word_lens), "/", board_size**2, "\n")

    max_word_len = max(word_lens)

    dummy = 0
    words_arr = []
    for i,word in enumerate(words):
        word_arr = []
        for j in range(max_word_len):
            if j < word_lens[i]:
                word_arr.append(letter_to_num_map[word[j]])
            else:
                word_arr.append(dummy)
        words_arr.append(word_arr)

    return max_word_len, word_lens, words_arr, ordered_letters, ordered_nums, lower_bounds, upper_bounds

if __name__ == "__main__":
    max_word_len, word_lens, words_arr, ordered_letters, ordered_nums, lower_bounds, upper_bounds = get_minizinc_code()

    print('n:', board_size, '\n')
    print('m:', num_words, '\n')
    print('max_len:', max_word_len, '\n')
    print('ordered_letters:', "[ " + ", ".join(['"'+l+'"' for l in ordered_letters]) + " ]", '\n')
    print('word_lens:\n' + "[ " + ", ".join(map(str, word_lens)) + " ]", '\n')
    print('words:\n' + "[" + "\n\t".join(["| " + ", ".join(map(str, row)) for row in words_arr]) + " |]", '\n')
    print('ordered_nums:', "[ " + ", ".join(map(str, ordered_nums)) + " ]", '\n')
    print('lower_bounds:', "[ " + ", ".join(map(str, lower_bounds)) + " ]", '\n')
    print('upper_bounds:', "[ " + ", ".join(map(str, upper_bounds)) + " ]", '\n')
