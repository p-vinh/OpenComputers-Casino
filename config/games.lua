local games = {}



table.insert(games, {
    title = 'Shop',
    file = "app_Shop.lua",
    available = false,
    image = "app_Shop.pic",
    author = "krovyaka",
    description = "There will be a store here soon :)"
})

table.insert(games, {
    title = "Roulette",
    file = "game_Roulette.lua",
    available = true,
    image = "game_Roulette.pic",
    author = "krovyaka",
    description = "Roulette is a game of chance (the word (roulette)\n" ..
            "comes from the French word «ru» translated from с\n" ..
            "French means «wheel, roller, runner»). Roulette\n" ..
            "first appeared in France. It was called \"hoka\" and in\n" ..
            "there were 40 numbered nests and three were marked\n" ..
            "«Zero». During the time of King Louis XIV, Cardinal Mazarin,\n" ..
            "to replenish the treasury, it was allowed everywhere in France\n" ..
            "open a casino. After Mazarin's death in 1661, he published\n" ..
            "decree stating that anyone who dared to open a casino\n" ..
            "for playing hoka, will be executed.\n \n" ..
            "Before playing, make sure you have enough\n" ..
            "places to receive winnings, as well as the amount of winnings\n" ..
            "will not exceed the amount of currency in the casino account."
})

table.insert(games, {
    title = "Blackjack",
    file = "game_Blackjack.lua",
    available = true,
    image = "game_Blackjack.pic",
    author = "Durex77",
    description = "Blackjack (English: Blackjack “black jack”) is one of the most\n" ..
            "popular card games in casinos around the world. Big\n" ..
            "The popularity of the game is due to its simple rules,\n" ..
            "speed of the game and the simplest strategy for counting\n" ..
            "cards. However, the game did not immediately gain popularity.\n" ..
            "Gambling houses in the United States had to\n" ..
            "stimulate interest in the game with various types of bonuses and\n" ..
            "development of several types of rules for\n" ..
            "blackjack. It is believed that the predecessor of this game\n" ..
            "there was a card game “vingt-et-un” (“twenty-one”),\n" ..
            "which appeared in French gambling establishments\n" ..
            "approximately in the 19th century. In Russia, for example, blackjack\n" ..
            "to this day it is often called twenty-one or a point (but\n" ..
            "The rules of the traditional point game are slightly different).\n \n" ..
            "Before playing, make sure you have enough\n" ..
            "places to receive winnings, as well as the amount of winnings\n" ..
            "will not exceed the amount of currency in the casino account."
})

table.insert(games, {
    title = "Video poker",
    file = "game_Video_poker.lua",
    available = true,
    image = "game_Video_poker.pic",
    author = "Durex77",
    description = "Video poker is a rules-based casino game\n" ..
            "five card poker with draw. The game is played on\n" ..
            "computerized console with screen or via the Internet\n \n" ..
            "Before playing, make sure you have enough\n" ..
            "places to receive winnings, as well as the amount of winnings\n" ..
            "will not exceed the amount of currency in the casino account."
})

table.insert(games, {
    title = "More or Less",
    file = "game_More_less.lua",
    available = true,
    image = "game_More_less.pic",
    author = "Durex77",
    description = "Casino card game, the essence of which is to guess\n" ..
            "the next card drawn is greater or less than the current one.\n" ..
            "If the new card is equal to the current one, then this situation\n" ..
            "is considered winning. The total winnings amount is\n" ..
            "the one that the game will take, stopping in time. How\n" ..
            "the further the game progresses, the more\n" ..
            "winning rate.\n \n" ..
            "Before playing, make sure you have enough\n" ..
            "places to receive winnings, as well as the amount of winnings\n" ..
            "will not exceed the amount of currency in the casino account."
})

table.insert(games, {
    title = "Minesweeper",
    file = "game_Minesweeper.lua",
    available = true,
    image = "game_Minesweeper.pic",
    author = "krovyaka",
    description = "Start the game and look for fields without mines. If 3 times in a row\n" ..
            "If you don't come across a field with a mine, then you win. Total in\n" ..
            "The game has 24 fields, 5 of which are mined.\n" ..
            "Winning the game doubles the bet.\n \n" ..
            "Before playing, make sure you have enough\n" ..
            "places to receive winnings, as well as the amount of winnings\n" ..
            "will not exceed the amount of currency in the casino account."
})

table.insert(games, {
    title = "One-armed Creeper",
    file = "game_One_armed_creeper.lua",
    available = true,
    image = "game_One_armed_creeper.pic",
    author = "krovyaka",
    description = "Classic slot machine with one line. Odds \n" ..
            "awards are calculated in such a way that, on average, 96%\n"..
            "funds were returned to the players. For comparison, in a casino\n"..
            "at spawn this coefficient is about 76%.\n \n" ..
            "After some time, similar slot machines will appear,\n" ..
            "which will have many lines and progress (like\n" ..
            "in real modern casinos)\n \n" ..
            "Before playing, make sure you have enough\n" ..
            "places to receive winnings, as well as the amount of winnings\n" ..
            "will not exceed the amount of currency in the casino account."
})

table.insert(games, {
    title = "Chests",
    file = "game_Chests.lua",
    available = true,
    image = "game_Chests.pic",
    author = "krovyaka",
    description = "Start the game and select a chest with loot.\n" ..
            "Each chest contains a random amount of currency:\n" ..
            "From 0 to double the bet size.\n" ..
            "One of the chests has a small chance to contain\n"..
            "ten times the bet, but most often it will be empty\n \n" ..
            "Before playing, make sure you have enough\n" ..
            "places to receive winnings, as well as the amount of winnings\n" ..
            "will not exceed the amount of currency in the casino account."
})

table.insert(games, {
    title = "Labyrinth",
    file = "game_Labirynth.lua",
    available = true,
    image = "game_Labirynth.pic",
    author = "krovyaka",
    description = "Labyrinth - the goal of the game is to \n" ..
            "without lifting the left mouse button from the monitor, without touching \n" ..
            "walls of the maze, walk from the left point of the screen to the right.\n" ..
            "At the same time creating a continuous line.\n" ..
            "Just like they drew in childhood;)"
})

table.insert(games, {
    title = "OpenChest",
    file = "game_OpenChest.lua",
    available = false,
    image = "game_Chests.pic",
    author = "Durex77",
    description = ""
})


return games