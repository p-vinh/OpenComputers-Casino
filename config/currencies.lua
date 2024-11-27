local currencies = {}

local function addCurrency(name, id, dmg, model, color, max)
    table.insert(currencies, {
        name = name,
        id = id,
        dmg = dmg,
        model = model,
        color = color,
    })
end

addCurrency("Money",           "customnpcs:npcMoney",      0,   'INGOT', 0x85BB65, nil)
addCurrency("Glowstone",        "minecraft:glowstone_dust", 0,   'DUST',  0xD0D000, 5)
addCurrency("Iron ingot",  "minecraft:iron_ingot",     0,   'INGOT', 0xAAAAAA, nil)
addCurrency("Iron block",    "minecraft:iron_block",     0,   'BLOCK', 0xAAAAAA, 6)
addCurrency("Copper Block",      "Forestry:resourceStorage", 1,   'BLOCK', 0xA5642F, 6)
addCurrency("Free",        nil,                        nil, nil,     0xE5E5E5, nil)

return currencies
