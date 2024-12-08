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

local function clearScreen()
    gpu.setBackground(0xe0e0e0) -- Set background to default gray
    gpu.fill(1, 1, 80, 40, " ") -- Clear the entire screen
end

local function drawCashOutButton()
    gpu.setBackground(0x90ef7e)
    gpu.fill(58, 29, 17, 5, " ")
    gpu.setForeground(0)
    gpu.set(62, 31, "Cash Out")
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

local function playGame()
    clearScreen()
    fields = createBoard(BOARD_SIZE)
    placeMines(fields, mineCount)
    drawBoard(fields, false)
    drawCashOutButton()

    local winnings = bets[bet]
    while game do
        local _, _, x, y = event.pull("touch")
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
end

-- Main Game Loop
gpu.setResolution(80, 40)
clearScreen()

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
