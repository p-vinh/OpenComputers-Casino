local component = require("component")
local unicode = require("unicode")
local term = require("term")
local gpu = component.gpu

local COLORS = {
    ["0"] = 0x000000, ["1"] = 0x0000AA, ["2"] = 0x00AA00, ["3"] = 0x00AAAA,
    ["4"] = 0xAA0000, ["5"] = 0xAA00AA, ["6"] = 0xAAAA00, ["7"] = 0xAAAAAA,
    ["8"] = 0x505050, ["9"] = 0x5050FF, ["a"] = 0x50FF50, ["b"] = 0x50FFFF,
    ["c"] = 0xFF5050, ["d"] = 0xFF50FF, ["e"] = 0xFFFF50, ["f"] = 0xFFFFFF
}

local function formattedText(x, y, text)
    local textLen = unicode.len(text)
    local line = 0
    local left = 0
    local color = "f"
    local i = 0
    gpu.setForeground(COLORS[color])
    while i < textLen do
        i = i + 1
        local char = unicode.sub(text, i, i)
        local colorCode = char == "&" and unicode.sub(text, i + 1, i + 1)
        if COLORS[colorCode] then
            color = colorCode
            i = i + 1
            gpu.setForeground(COLORS[color])
        elseif char == "\n" then
            line = line + 1
            left = 0
        else
            gpu.set(x + left, y + line, char)
            left = left + 1
        end
    end
end

local howToPlay = [[
&aHow to play?
 &f1. Go to the booth and select a game.
 2. Place the required amount of currency in the chest and play.
 &cBe careful and don’t let outside players into your booth!

&aHow to choose a currency?
 &fThe current currency is indicated at the bottom of the main menu. Clicking on it will open a drop-down list,
in which you can choose a different currency..

&aWho should I contact with questions?
 &f1. krovyaka &3Discord: &bkrovyaka#2862 &3VK: &bvk.com/krovyaka
 &f2. Durex77  &3Discord: &bDurex77#2033

&aHow to make sure the casino is honest?
 &fThis warp has been approved by the senior moderators.
  If any suspicions arise, we are ready to provide any necessary information.

&aWhat are the plans?
 &f1. isplays the current currency in every game, not just in the main menu. &8(choice possible)
 &f2. Adding a large number of slot machines.
 &f3. Trial games without currency.
]]

gpu.setResolution(100, 25)
gpu.setBackground(0)
term.clear()
formattedText(6, 3, howToPlay)
os.sleep(math.huge)
