-- Konstanta
local GIVING_TREE_ID = 3200
local AXE_ID = 3206
local saveaxe = "SAVEAXXXX"
local xxa, yya = 48, 36
local xc, yc = 42, 36
local gg = "GROWCH"

function warpto(world)
    sendPacket(3, "action|join_request\nname|"..world.."\ninvitedWorld|1\n")
    sleep(2000)
end

function use(id)
    sendPacketRaw(false,{type = 10, value = id})
end

function inv(id)
    for _, item in pairs(getInventory()) do
        if item.id == id then return item.amount end
    end
    return 0
end

function drop(id, amount)
    sendPacket(2, [[action|dialog_return
dialog_name|drop_item
itemID|]]..id..[[|
count|]]..amount..[[|
]])
    sleep(200)
end

function click(x, y)
    sendPacketRaw(false, {
        type = 3,
        value = 18,
        x = x * 32,
        y = y * 32,
        punchx = x,
        punchy = y
    })

    local px = getLocal().pos.x // 32
    local state = 2600
    if x > px then state = 2592 elseif x < px then state = 2608 end

    sendPacketRaw(false, {
        type = 0,
        state = state,
        x = getLocal().pos.x,
        y = getLocal().pos.y,
        punchx = x,
        punchy = y
    })
end

function checkItm(id)
    for _, item in pairs(getInventory()) do
        if item.id == id then return item.amount end
    end
    return 0
end

function fastFindAndClickGivingTree()
    local px = getLocal().pos.x // 32
    local py = getLocal().pos.y // 32

    local offsets = {
        {0,0},{1,0},{-1,0},{0,1},{0,-1},
        {1,1},{-1,-1},{1,-1},{-1,1},
        {2,0},{-2,0},{0,2},{0,-2},
        {2,1},{2,-1},{-2,1},{-2,-1},
        {1,2},{-1,2},{1,-2},{-1,-2},
        {3,0},{0,3},{-3,0},{0,-3}
    }

    for _, offset in ipairs(offsets) do
        local tx, ty = px + offset[1], py + offset[2]
        local tile = checkTile(tx, ty)
        if tile and tile.fg == GIVING_TREE_ID then
            click(tx, ty)
            return true
        end
    end
    return false
end

-- MAIN LOOP
while true do
    if checkItm(AXE_ID) <= 0 then
        warpto(saveaxe)
        findPath(xxa, yya)
        sleep(1000)

        click(xxa, yya)
        sleep(500)
        use(AXE_ID)
        sleep(300)

        findPath(xc, yc)
        sleep(300)

        if inv(16566) > 0 then
            drop(16566, inv(16566))
        end

        local retry = 0
        while checkItm(AXE_ID) == 0 and retry < 10 do
            sleep(400)
            retry = retry + 1
        end

        if checkItm(AXE_ID) == 0 then break end

        warpto(gg)
        sleep(2000)
    end

    -- Super fast detect & click tree
    fastFindAndClickGivingTree()
    sleep(50) -- delay pendek biar loop ga berat banget
end
