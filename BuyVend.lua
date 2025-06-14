function loging(txt)
logToConsole("`w[`9Difan Script`w] `2"..txt)
end

function drop(id, amount)
    sendPacket(2, [[action|dialog_return
dialog_name|drop_item
itemID|]] .. id .. [[|
count|]] .. amount .. [[
]])
end

function inv(id)
    for _, v in pairs(getInventory()) do
        if v.id == id then
            return v.amount
        end
    end
    return 0
end

function warp(w)
    sendPacket(3, "action|join_request\nname|" .. w .. "\ninvitedWorld|0")
end

function buyVend(x, y, id, price, amount)
    sendPacket(2, [[action|dialog_return
dialog_name|vending
tilex|]] .. x .. [[|
tiley|]] .. y .. [[|
verify|1|
buycount|]] .. amount .. [[|
expectprice|-]] .. price .. [[|
expectitem|]] .. id .. [[|
]])
end

kur = set.save.x

AddHook("OnVarlist", "tetek", function(a)
if a[0] == "OnTextOverlay" and a[1]:find("emptier") then
if set.save.hadap == "kiri" then
kur = set.save.x - 1
findPath(kur,set.save.y)
elseif set.save.hadap == "kanan" then
kur = kur + 1
findPath(kur,set.save.y)
end
end
end)

-- Coroutine system
local runningThreads = {}

AddHook("OnRender", "DelayCoroutineRunner", function()
    local now = os.clock() * 1000
    for i = #runningThreads, 1, -1 do
        local t = runningThreads[i]
        if now >= t.resumeTime then
            local success, waitMS = coroutine.resume(t.thread)
            if coroutine.status(t.thread) == "dead" then
                table.remove(runningThreads, i)
            else
                t.resumeTime = now + (waitMS or 0)
            end
        end
    end
end)

function dhook(fn)
    local co = coroutine.create(fn)
    local ok, waitMS = coroutine.resume(co)
    if coroutine.status(co) ~= "dead" then
        table.insert(runningThreads, {
            thread = co,
            resumeTime = os.clock() * 1000 + (waitMS or 0)
        })
    end
end

function turu(ms)
    coroutine.yield(ms)
end

-- MAIN LOOP tanpa cek posisi karakter
function main()
    while true do
        loging(" Memulai cycle...")

        if getWorld().name ~= set.vend.world then
            loging(" Warp ke VEND world...")
            warp(set.vend.world)
            turu(set.vend.delay_warp)
        end

        findPath(set.vend.x, set.vend.y)
        turu(set.vend.delay_tp)

        loging(" Beli dari vending...")
        buyVend(set.vend.x, set.vend.y, set.vend.id, set.vend.harga, 200)
        turu(set.vend.delay_buy)

        loging(" Warp ke SAVE world...")
        warp(set.save.world)
        turu(set.save.delay_warp)

        findPath(kur , set.save.y)
        turu(set.save.delay_tp)

        local jumlah = inv(set.vend.id)
        if jumlah > 0 then
            loging(" Drop " .. jumlah .. " item...")
            drop(set.vend.id, math.min(jumlah, set.save.total_drop))
            turu(set.save.delay_drop)
        else
            loging(" Tidak ada item untuk di-drop.")
        end

        loging(" Cycle selesai, ulangi...")
        turu(1000)
    end
end

-- Jalankan coroutine
dhook(main)
