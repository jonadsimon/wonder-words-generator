import numpy as np
import random
from collections import Counter

# num_words = 36
board_size = 18

def get_minizinc_code():
    raw_words = """espresso
coffee
cappuccino
milk
café au lait
mocha
sip
soda
mojito
caffe latte
decaf
venti
lemonade
macchiato
frappuccino
milkshake
martini
eggnog
bagel
chai
granola
slurp
coffeemaker
biscotti
creamer
frappe
coffee shop
smoothie
europe
scandinavia
france
hot toddy
french language
caffe
mate
caffeine
caffein
turkey
lattes
quaffing
matcha
caffè
tequila
sipping
jell
vienna
tacuba
tapas
fondue
trieste
swish
english language
potpourri
hazelnut
crema
gelato
fizzy
fresca
pulque
queso
cholula
english orthography
tea
cupcake
flan
leche
italian language
percolator
bagatelle
corks
absinthe
RELATED WORDS CONTINUE AFTER ADVERTISEMENT
liqueur
desportivo
creme
vodka
chocolates
ether
diethyl
yoghurt
demande
uncorked
cacao
quart
frothy
nibble
champagne
rumba
tofu
iced
cappuccinos
tila
groucho
dessert
torta
tiramisu
ghirardelli
margaritas
caf
venice
coffeehouse
brulee
wiener melange
cafe
nachos
chocolate
caffeinated
cachaca
london
mezcal
custard
plumpjack
masala chai
sorbet
nutella
pomodoro
daiquiri
mochas
panera
tempeh
martinis
sangria
chalice
cream
poblet
lucimar
soufflé
granita
pinata
tchibo
lavazza
milonga
12-pack
cubano
milkshakes
baller
yeshua
beverage
smoothies
refried
lotion
carafe
spanish language
pepsi
mug
cup
dairy
soy milk
cornerstone
teacup
pannikin
cola
posset
imbibe
drink
nonfat
almond milk
drinkable
potable
teapot
bottle
negus
croissant
expresso
java
european cuisine
grande
doppio
joe
muffin
scone
pint
margarita
cosmo
vente"""

    words = [raw_word.upper() for raw_word in raw_words.split('\n') if " " not in raw_word and len(raw_word) > 3 and raw_word.isalpha()]

    # Remove words that are supersets of another existing word
    super_words = []
    for word_sub in words:
        for word_super in words:
            if word_sub in word_super and word_sub != word_super:
                super_words.append(word_super)
    words = [word for word in words if word not in super_words]

    words.sort(key=len)

    # Pick a cutoff which is just below the limit of the board size
    cum_len = np.cumsum([len(word) for word in words])
    num_words = None
    for k,l in enumerate(cum_len):
        if l >= board_size**2:
            num_words = k + 7 # NORMALLY JUST k
            break
    if not num_words:
        num_words = len(words)

    words = words[:num_words]
    print("  ".join(sorted([word.lower() for word in words])), "\n")

    # words = ['rain', 'tree', 'vine', 'bird', 'biome', 'snake', 'earth', 'fauna', 'eagle', 'plant', 'swamp', 'flora', 'forest', 'jungle', 'oxygen', 'canopy', 'amazon', 'monkey', 'jaguar', 'brazil', 'branch', 'boreal', 'carbon', 'acacia', 'species', 'america', 'equator', 'savanna', 'monsoon', 'montane', 'tropics', 'tropical', 'medicine', 'woodland', 'mangrove', 'habitats', 'malaysia', 'wetlands', 'wildlife', 'peatland', 'temperate', 'indonesia', 'woodlands', 'shrubland', 'australia', 'vegetation', 'coniferous', 'eucalyptus', 'grasslands', 'ecosystems', 'madagascar', 'undergrowth', 'plantations', 'biodiversity', 'deforestation', 'photosynthesis']
    # words = [word.upper() for word in words]
    #
    # words = words[:num_words] # grab the num_words shortest words; sum of word lengths should be roughly equal to board size

    # Only need to return input params, particularly the Letters set, words array, and word length array

    # is much more efficient if we return letters in frequency order, so the optimizer will start with the most-common letters
    letters = list(zip(*Counter(''.join(words)).most_common()))[0]
    # letters = set(''.join(words))

    word_lens = [len(word) for word in words]

    print("total letters / board size = ", sum(word_lens), "/", board_size**2, "\n")

    max_word_len = max(word_lens)

    dummy = letters[0]
    # dummy = next(iter(letters))
    words_arr = []
    for i,word in enumerate(words):
        word_arr = []
        for j in range(max_word_len):
            if j < word_lens[i]:
                word_arr.append(word[j])
            else:
                word_arr.append(dummy)
        words_arr.append(word_arr)



    return num_words, max_word_len, letters, word_lens, words_arr

if __name__ == "__main__":
    num_words, max_word_len, letters, word_lens, words_arr = get_minizinc_code()

    print('n:', board_size, '\n')
    print('m:', num_words, '\n')
    print('max_len:', max_word_len, '\n')
    print('Letter:\n' + "{ " + ", ".join(letters) + " }", '\n')
    print('word_lens:\n' + "[ " + ", ".join(map(str, word_lens)) + " ]", '\n')
    print('words:\n' + "[" + "\n\t".join(["| " + ", ".join(row) for row in words_arr]) + " |]", '\n')
