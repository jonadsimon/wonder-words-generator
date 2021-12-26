import numpy as np
import random
from collections import Counter

# num_words = 36
board_size = 25

def get_minizinc_code():
    raw_words = """robot
mechanical
humanoid
prosthetic
cybernetic
robotlike
sonar
artificial intelligence
android
simulator
nasa
cyborg
machine
autonomous robot
industrial robot
inflatable
device
oxford english dictionary
isaac asimov
submersible
unmanned
analog science fiction and fact
submarine
mouse
wheeled
lidar
simulation
animatronic
miniature
radar
laser
robonaut
gravitation
acceleration
asimo
automatic
carnegie mellon university
machinelike
automatonlike
czechoslovakia
etymology
cybernetics
manufacturing
battery
weight
muscle
r.u.r.
spring
automaton
runaround
joule
robots
tactile
unimate
machinery
keyboard
automation
optics
machinist
spacecraft
automate
underwater
piezoelectricity
decoder
delft
nanometre
zamboni
spaceship
propulsion
mechanical engineering
orbiter
machinima
catapult
electrical engineering
wheel
computer science
gyroscope
bio-inspired robotics
craft
classical times
piloting
submersibles
hovercraft
domestic robot
astronauts
equipped
module
outfitted
military robot
telescope
bot
docking
parachutes
satellites
simulate
tethered
sensors
simulators
vtol
karel čapek
uav
endeavour
microscope
manned
gear
scanning
fairing
reusable
prototype
pathfinder
mechanistic
drill
orion
prosthesis
telescopes
stairway
pressurized
stealthy
microscopes
orbiting
pad
honda
drones
apollo
simulated
josef capek
iss
simulating
lander
planetary
inertia
experiments
medusa
exoskeleton
hubble
spacex
orbit
payload
abort
fitted
periscopes
forelimbs
shuttle
earth
gesture
binoculars
sling
mars
dummy
winged
canine
sensing
galileo
jet
payloads
tunneling
modules
science fiction
reaction
prehensility
moment
schunk
pulley
toilet
50-foot
hardware
three laws of robotics
contraption
remote-controlled
norbert wiener
comber
mainframe
teletype
somersault
computer
trot
cpu
mechanic
flame
aibo
processor
ballbot
momentum
minicomputer
motherboard
microprocessor
electromechanical
potential energy
microcomputer
numerical control
hand-held
bios
mindtool
hill
pda
pneumatic actuator
peripheral
hydraulic drive system
flight
autopilot"""

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
            num_words = k + 6 # NORMALLY JUST k
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



    return num_words, max_word_len, letters, word_lens, words_arr

if __name__ == "__main__":
    num_words, max_word_len, letters, word_lens, words_arr = get_minizinc_code()

    print('n:', board_size, '\n')
    print('m:', num_words, '\n')
    print('max_len:', max_word_len, '\n')
    print('Letter:\n' + "{ " + ", ".join(letters) + " }", '\n')
    print('word_lens:\n' + "[ " + ", ".join(map(str, word_lens)) + " ]", '\n')
    print('words:\n' + "[" + "\n\t".join(["| " + ", ".join(row) for row in words_arr]) + " |]", '\n')
