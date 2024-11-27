math.randomseed(os.time()) -- Seed for randomness

-- Constants
local BOARD_SIZE = 5
local VALID_BETS = {1, 5, 10, 50, 100}
local MULTIPLIERS = { -- Multipliers based on number of mines
    [1] = 1.1, [5] = 1.5, [10] = 2.0, [15] = 3.0, [20] = 5.0, [24] = 10.0
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

-- Main Game Logic
local function playGame()
    print("Welcome to Mines!")

    -- Ask for number of mines
    local mineCount
    repeat
        io.write("Enter number of mines (1-" .. (BOARD_SIZE^2 - 1) .. "): ")
        mineCount = tonumber(io.read())
    until mineCount and mineCount > 0 and mineCount < BOARD_SIZE^2

    -- Ask for bet
    local bet
    repeat
        io.write("Enter your bet (" .. table.concat(VALID_BETS, ", ") .. "): ")
        bet = tonumber(io.read())
    until isValidBet(bet)

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

playGame()
