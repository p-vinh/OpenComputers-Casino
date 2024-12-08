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
    ["revealed"] = 0xd0d0d0 -- Grey
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

local function drawBoard(board, reveal)
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

local function drawBetButtons()
    gpu.setForeground(0)
    for i = 1, #bets do
        local bg = (i == bet) and 0x90ef7e or 0xd0d0d0
        local x = 5 + (i - 1) * 7
        gpu.setBackground(bg)
        gpu.fill(x, 37, 5, 1, " ")
        gpu.set(x + 1, 37, tostring(bets[i]))
    end
end

local function drawStartButton()
    gpu.setBackground(0x90ef7e)
    gpu.fill(58, 29, 17, 5, " ")
    gpu.setForeground(0)
    gpu.set(61, 31, "Start game")
end

local function drawExitButton()
    gpu.setBackground(0x990000)
    gpu.fill(58, 35, 17, 3, " ")
    gpu.setForeground(0xFFFFFF)
    gpu.set(64, 36, "Exit")
end

local function drawUI()
    gpu.setBackground(0xe0e0e0)
    gpu.fill(1, 1, 80, 40, " ")
    drawBetButtons()
    drawStartButton()
    drawExitButton()
    gpu.setForeground(0x000000)
    gpu.set(5, 2, "Welcome to Mines!")
    gpu.set(5, 4, "Rules:")
    gpu.set(5, 5, "1. Select cells to uncover safe fields.")
    gpu.set(5, 6, "2. Cash out anytime to keep your winnings.")
    gpu.set(5, 7, "3. If you hit a mine, you lose your bet!")
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

local function playGame()
    fields = createBoard(BOARD_SIZE)
    placeMines(fields, mineCount)
    drawBoard(fields, false)
    local winnings = bets[bet]
    gpu.setForeground(0x0000FF)
    gpu.set(5, 35, "Game started! Good luck!")

    while game do
        local _, _, x, y = event.pull("touch")
        local col = math.floor((x - 5) / 12) + 1
        local row = math.floor((y - 3) / 6) + 1

        if row >= 1 and row <= BOARD_SIZE and col >= 1 and col <= BOARD_SIZE then
            if fields[row][col] == "mine" then
                handleFieldClick(row, col)
            elseif fields[row][col] == "safe" then
                fields[row][col] = "revealed"
                drawBoard(fields, false)
                winnings = winnings * MULTIPLIERS[mineCount] or 1.1
                gpu.set(5, 36, string.format("Safe! Current winnings: %.2f", winnings))
                gpu.set(5, 37, "Cash out? Click 'Exit' or keep playing.")
            end
        end
    end
end

-- Main Game Loop
gpu.setResolution(80, 40)
drawUI()

while true do
    local _, _, x, y = event.pull("touch")

    -- Start game button
    if not game and x >= 58 and x <= 75 and y >= 29 and y <= 33 then
        local payed, reason = casino.takeMoney(bets[bet])
        if payed then
            game = true
            playGame()
        else
            gpu.setForeground(0xFF0000)
            gpu.set(5, 34, "Not enough money to start the game!")
        end
    end

    -- Exit button
    if x >= 58 and x <= 75 and y >= 35 and y <= 37 then
        gpu.setForeground(0xFFFFFF)
        gpu.set(5, 38, "Exiting...")
        break
    end

    -- Bet buttons
    if not game and y == 37 and x >= 5 and x <= 51 then
        local newBet = math.floor((x - 5) / 7) + 1
        if newBet >= 1 and newBet <= #bets then
            bet = newBet
            drawBetButtons()
        end
    end
end
