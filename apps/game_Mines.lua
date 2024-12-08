local component = require("component")
local gpu = component.gpu
local event = require("event")
local casino = require("casino")

math.randomseed(os.time()) -- Seed for randomness

-- Constants
local BOARD_SIZE = 5 -- 5x5 board
local VALID_BETS = {1, 5, 10, 50, 100}
local MULTIPLIERS = {
    [1] = 1.1, [5] = 1.5, [10] = 2.0, [15] = 3.0, [20] = 5.0, [24] = 10.0
} -- Multiplier based on number of mines
local bets = VALID_BETS
local bet = 1 -- Default bet index
local mineCount = 1 -- Default mine count
local game = false
local fields = {} -- Game board

local field_types = {
    ["safe"] = 0x98df94, -- Green
    ["mine"] = 0xff0000, -- Red
    ["revealed"] = 0xffff00 -- Yellow
}

-- Helper Functions
local function createBoard(size)
    local board = {}
    for i = 1, size do
        board[i] = {}
        for j = 1, size do
            board[i][j] = "safe" -- Default to safe
        end
    end
    return board
end

local function drawBets()
    gpu.setForeground(0)
    for i = 0, #bets - 1 do
        gpu.setBackground(i == bet - 1 and 0x90ef7e or 0xd0d0d0)
        gpu.fill(5 + i * 7, 37, 5, 1, " ")
        gpu.set(7 + i * 7, 37, tostring(bets[i + 1]))
    end
end

local function placeMines(board, mineCount)
    local size = #board
    for _ = 1, mineCount do
        local x, y
        repeat
            x, y = math.random(size), math.random(size)
        until board[x][y] ~= "mine"
        board[x][y] = "mine"
    end
end


local function endGame()
    os.sleep(0.7)
    animations.reveal()
    gpu.setForeground(0xFFFFFF)
    gpu.setBackground(0x990000)
    gpu.fill(58, 35, 17, 3, " ")
    gpu.set(64, 36, "Exit")
    gpu.setBackground(0x90ef7e)
    gpu.setForeground(0)
    gpu.fill(58, 29, 17, 5, " ")
    gpu.set(61, 31, "Start game")
    game = false
    casino.gameIsOver()
end

local function drawBoard(board, reveal)
    gpu.setBackground(0xe0e0e0)
    gpu.fill(5, 3, BOARD_SIZE * 12, BOARD_SIZE * 6, " ") -- Clear grid area

    for row = 1, BOARD_SIZE do
        for col = 1, BOARD_SIZE do
            local x = 5 + (col - 1) * 12
            local y = 3 + (row - 1) * 6
            local fieldType = board[row][col]
            if reveal or fieldType == "revealed" then
                fieldType = fieldType == "mine" and "mine" or "revealed"
            else
                fieldType = "safe"
            end
            gpu.setBackground(field_types[fieldType])
            gpu.fill(x, y, 10, 5, " ")
        end
    end
end

local function handleFieldClick(row, col)
    if fields[row][col] == "safe" then
        fields[row][col] = "revealed"
        drawBoard(fields, false)
    elseif fields[row][col] == "mine" then
        fields[row][col] = "mine"
        drawBoard(fields, true)
        gpu.setForeground(0xFF0000)
        gpu.set(5, 35, "Boom! You hit a mine. Game over.")
        game = false
    end
end


-- Main Game Loop
gpu.setResolution(80, 40)
gpu.setBackground(0xe0e0e0)
term.clear()
gpu.setBackground(0xffffff)
gpu.fill(3, 2, 74, 37, " ")
gpu.setForeground(0x00a000)
gpu.set(4, 29, "Game rules and rewards:")
gpu.set(4, 35, "Bid:")
gpu.setForeground(0x000000)
gpu.set(4, 30, "Start the game and look for fields without mines. Keep")
gpu.set(4, 31, "going until you want to cash out.")
gpu.set(4, 32, "There are 25 fields in the game, of which 1 is a")
gpu.set(4, 33, "mine. Each safe field increases your winnings.")
gpu.setBackground(0xe0e0e0)
gpu.fill(1, 27, 76, 1, " ")
gpu.fill(54, 27, 2, 12, " ")
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x990000)
gpu.fill(58, 35, 17, 3, " ")
gpu.set(64, 36, "Exit")
gpu.setBackground(0x90ef7e)
gpu.setForeground(0)
gpu.fill(58, 29, 17, 5, " ")
gpu.set(61, 31, "Start game")
drawBets()
animations.load()

while true do
    local _, _, x, y = event.pull("touch")

    
    -- Start game button
    if not game and x >= 58 and x <= 75 and y >= 29 and y <= 33 then
        local payed, reason = casino.takeMoney(bets[bet])
        if payed then
            game = true
            gpu.setBackground(0xffa500)
            gpu.fill(58, 29, 17, 5, " ")
            gpu.set(62, 31, "The game is on")
            gpu.setForeground(0xFFFFFF)
            gpu.setBackground(0x613C3C)
            gpu.fill(58, 35, 17, 3, " ")
            gpu.set(64, 36, "Cash Out")
        else
            gpu.setForeground(0xFF0000)
            gpu.set(5, 34, "Not enough money to start the game!")
        end
    end

    if game and left >= 5 and left <= 74 and top >= 2 and top <= 25 then
        local winnings = bets[bet]

        -- Generate game board
        fields = createBoard(BOARD_SIZE)
        placeMines(fields, mineCount)
        drawBoard(fields, false)

        if x >= 58 and x <= 75 and y >= 29 and y <= 33 then
            gpu.setForeground(0x00FF00)
            gpu.set(5, 36, string.format("You cashed out with %.2f!", winnings))
            endGame()
            break
        end

        local col = math.floor((x - 5) / 12) + 1
        local row = math.floor((y - 3) / 6) + 1
        if row >= 1 and row <= BOARD_SIZE and col >= 1 and col <= BOARD_SIZE then
            if fields[row][col] == "mine" then
                handleFieldClick(row, col)
            elseif fields[row][col] == "safe" then
                fields[row][col] = "revealed"
                drawBoard(fields, false)
                winnings = winnings * MULTIPLIERS[mineCount] or 1.1
                gpu.setForeground(0x0000FF)
                gpu.set(5, 36, string.format("Safe! Current winnings: %.2f", winnings))
            end
        end
    end


    -- Exit button
    if not game and left >= 58 and left <= 75 and top >= 35 and top <= 37 then
        error("Exit by request")
    end

    -- Bet buttons
    if not game and top == 37 and left >= 5 and left <= 51 then
        if (left - 5) % 7 < 5 then
            bet = math.floor((left - 5) / 7) + 1
            drawBets()
        end
    end

end
