local component = require("component")
local gpu = component.gpu
local event = require("event")
local term = require("term")
local unicode = require("unicode")
local casino = require("casino")


math.randomseed(os.time()) -- Seed for randomness

-- Constants
local BOARD_SIZE = 5 -- 5x5 board
local VALID_BETS = {1, 5, 10, 50, 100}
local MULTIPLIERS = { -- Multipliers based on number of mines
    [1] = 1.1, [5] = 1.5, [10] = 2.0, [15] = 3.0, [20] = 5.0, [24] = 10.0
} -- 24 mines is impossible to win

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

local function isValidBet(bet)
    for _, validBet in ipairs(VALID_BETS) do
        if bet == validBet then
            return true
        end
    end
    return false
end

local function displayBoard(board, reveal)
    for i = 1, #board do
        for j = 1, #board[i] do
            if reveal or board[i][j] == "revealed" then
                io.write(board[i][j] == "mine" and " M " or " S ")
            else
                io.write(" * ")
            end
        end
        io.write("\n")
    end
end

local function getBombPos(x)
    return 5 + ((x - 1) % 6) * 12, 3 + math.floor((x - 1) / 6) * 6
end

-- Main Game Logic
local function drawField(x, f_type)
    gpu.setBackground(field_types[f_type])
    local pos_x, pos_y = getBombPos(x)
    gpu.fill(pos_x, pos_y, 10, 5, " ")
    if f_type == "mine" then
        gpu.setForeground(0)
        gpu.set(pos_x, pos_y + 0, " *      * ")
        gpu.set(pos_x, pos_y + 1, "  \\    /  ")
        gpu.set(pos_x, pos_y + 2, "    *    ")
        gpu.set(pos_x, pos_y + 3, "  /    \\  ")
        gpu.set(pos_x, pos_y + 4, " *      * ")
    end
end

local animations = {
    ["load"] = function()
        for i = 1, 24 do
            drawField(i, "safe")
            os.sleep(0.1)
            drawField(i, "close")
        end
    end,

    ["reveal"] = function()
        for i = 0, 3 do
            for j = 1, 6 do
                drawField(j + i * 6, "safe")
            end
            os.sleep(0.1)
            for j = 1, 6 do
                if fields[j + i * 6] == "close_bomb" then
                    drawField(j + i * 6, "mine")
                else
                    drawField(j + i * 6, "close")
                end
            end
        end
        os.sleep(1)
        for i = 0, 3 do
            for j = 1, 6 do
                drawField(j + i * 6, "safe")
            end
            os.sleep(0.1)
            for j = 1, 6 do
                drawField(j + i * 6, "close")
            end
        end
    end,

    ["reveal_all"] = function()
        for i = 1, 24 do
            if fields[i] == "close_bomb" then
                drawField(i, "mine")
            else
                drawField(i, "safe")
            end
        end
    end,
    ["error"] = function()
        for i = 1, 2 do
            gpu.setBackground(0xff0000)
            gpu.setForeground(0xffffff)
            gpu.fill(58, 29, 17, 5, " ")
            gpu.set(61, 31, "Start game")
            os.sleep(0.1)
            gpu.setBackground(0x90ef7e)
            gpu.setForeground(0)
            gpu.fill(58, 29, 17, 5, " ")
            gpu.set(61, 31, "Start game")
            os.sleep(0.1)
        end
    end
}

local function playGame()
    print("Welcome to Mines!")

    -- Setup board
    local board = createBoard(BOARD_SIZE)
    placeMines(board, mineCount)

    print("Game started! Select cells (row, column) to uncover.")
    local isGameOver = false
    local winnings = bet

    while not isGameOver do
        displayBoard(board, false)
        io.write("Choose a cell (row column): ")
        local input = io.read()
        local row, col = input:match("^(%d+)%s+(%d+)$")
        row, col = tonumber(row), tonumber(col)

        if row and col and row >= 1 and row <= BOARD_SIZE and col >= 1 and col <= BOARD_SIZE then
            if board[row][col] == "mine" then
                print("Boom! You hit a mine. Game over.")
                isGameOver = true
            elseif board[row][col] == "safe" then
                board[row][col] = "revealed"
                winnings = winnings * MULTIPLIERS[mineCount] or 1.1
                print(string.format("Safe! Your current winnings: %.2f", winnings))
                io.write("Do you want to cash out? (yes/no): ")
                local choice = io.read()
                if choice:lower() == "yes" then
                    print(string.format("You cashed out with %.2f!", winnings))
                    isGameOver = true
                end
            else
                print("Cell already revealed. Try a different cell.")
            end
        else
            print("Invalid input. Please choose a valid cell.")
        end
    end

    print("Game board:")
    displayBoard(board, true)
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

local function drawBets()
    gpu.setForeground(0)
    for i = 0, #bets - 1 do
        gpu.setBackground(i == bet - 1 and 0x90ef7e or 0xd0d0d0)
        gpu.fill(5 + i * 7, 37, 5, 1, " ")
        gpu.set(7 + i * 7, 37, tostring(bets[i + 1]))
    end
end

local function handleFieldClick(top, left)
    local id = getBombId(left, top)
    if (id > 0) then
        if (fields[id] == "safe") then
            drawField(id, "revealed")
            fields[id] = "revealed"
        end
        if (fields[id] == "mine") then
            drawField(id, "mine")
            endGame()
            return
        end
    end
    -- ADD CASH OUT BUTTON
    if (attempts == 0) then
        casino.reward(bets[bet] * 2)
        endGame()
        return
    end
end

local function getBombId(left, top)
    if (((left - 3) % 12) == 0) or (((left - 4) % 12) == 0) or (((top - 2) % 6) == 0) then
        return 0
    end
    return (math.floor((top - 3) / 6) * 6) + math.floor((left + 7) / 12)
end

-- Main Game Loop

gpu.setResolution(78, 39)
gpu.setBackground(0xe0e0e0)
term.clear()
gpu.setBackground(0xffffff)
gpu.fill(3, 2, 74, 37, " ")
gpu.setForeground(0x00a000)
gpu.set(4, 29, "Game rules and rewards:")
gpu.set(4, 35, "Bid:")
gpu.setForeground(0x000000)
gpu.set(4, 30, "Start the game and look for fields without mines.")
gpu.set(4, 31, "You can cash out whenever you want, but if you")
gpu.set(4, 32, "hit a mine, you lose the bet.")
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
    local _, _, left, top = event.pull("touch")

    -- start game button
    if not game and left >= 58 and left <= 75 and top >= 29 and top <= 33 then
        local payed, reason = casino.takeMoney(bets[bet])
        if payed then
            local mineCount = 1 -- Default to 1 mine
            local board = createBoard(BOARD_SIZE)
            placeMines(board, mineCount)     
               
            gpu.setBackground(0xffa500)
            gpu.fill(58, 29, 17, 5, " ")
            gpu.set(62, 31, "The game is on")
            gpu.setForeground(0xFFFFFF)
            gpu.setBackground(0x613C3C)
            gpu.fill(58, 35, 17, 3, " ")
            gpu.set(64, 36, "Exit")
            game = true
        else
            animations.error()
        end
    end

    -- exit button
    if not game and left >= 58 and left <= 75 and top >= 35 and top <= 37 then
        error("Exit by request")
    end

    -- game fields
    if game and left >= 5 and left <= 74 and top >= 2 and top <= 25 then
        handleFieldClick(top, left)
    end

    -- bet buttons
    if not game and top == 37 and left >= 5 and left <= 51 then
        if (left - 5) % 7 < 5 then
            bet = math.floor((left - 5) / 7) + 1
            drawBets()
        end
    end
    
    -- ADD MINE MULTIPLIER BUTTON. DEFAULT MINE COUNT IS 1

end