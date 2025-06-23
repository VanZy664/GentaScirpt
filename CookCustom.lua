local place_delay = 200
local finished_cook_time = 60000 -- total waktu masak (misal 60 detik)

local oven = {
}

recipe = {
}

local runningThreads={}AddHook("OnRender","DelayCoroutineRunner",function()local now=os.clock()*1000 for i=#runningThreads,1,-1 do local t=runningThreads[i] if now>=t.resumeTime then local success,waitMS=coroutine.resume(t.thread) if coroutine.status(t.thread)=="dead" then table.remove(runningThreads,i) else t.resumeTime=now+(waitMS or 0)end end end end)function dhook(fn)local co=coroutine.create(fn)local ok,waitMS=coroutine.resume(co)if coroutine.status(co)~="dead" then table.insert(runningThreads,{thread=co,resumeTime=os.clock()*1000+(waitMS or 0)})end end function turu(ms)coroutine.yield(ms)end

function log(txt)
logToConsole("`w[`9Difan Script`w] `2"..txt)
end

function cook(x, y, id)
    sendPacket(2, "action|dialog_return\ndialog_name|oven\ntilex|"..x.."|\ntiley|"..y.."|\ncookthis|"..id.."|\nbuttonClicked|low\ndisplay_timer|1")
end

function place(x, y, id)
    sendPacketRaw(false, {
        type = 3,
        value = id,
        x = x * 32,
        y = y * 32,
        punchx = x,
        punchy = y
    })
end

function punch(x, y)
    sendPacketRaw(false, {type = 3, value = 18, x = x * 32, y = y * 32, punchx = x, punchy = y})

    local px = getLocal().pos.x // 32
    local state = nil
    if x > px then
        state = 2592
    elseif x < px then
        state = 2608
    end

    sendPacketRaw(false, {type = 0, state = state, x = getLocal().pos.x, y = getLocal().pos.y, punchx = x, punchy = y})
end

function main()
    local start_time = os.time() * 1000

    for index, item in ipairs(recipe) do
        for i = 1, item.total do
            local target_time = item.placeAt
            local now = os.time() * 1000
            local wait = target_time - (now - start_time)

            if wait > 0 then
                turu(wait)
            end

            for _, ovenPos in ipairs(oven) do
                if index == 1 then
                    cook(ovenPos.x, ovenPos.y, item.id)
                else
                    place(ovenPos.x, ovenPos.y, item.id)
                end
                turu(place_delay)
            end
        end
    end

    -- Tunggu hingga waktu masak selesai, lalu punch semua oven
    local time_now = os.time() * 1000
    local time_left = finished_cook_time - (time_now - start_time)
    if time_left > 0 then
        turu(time_left)
    end

    for _, ovenPos in ipairs(oven) do
        punch(ovenPos.x, ovenPos.y)
        turu(400)
    end
end

AddHook("OnTextPacket","Settings",function(t,p)

if p:lower():find("text|/oven (%d+) (%d+)") then
local x,y = p:lower():match("text|/oven (%d+) (%d+)")
table.insert(oven, {x = x, y = y})
for i = 1,#oven do;log("{x = "..oven[i].x..", y = "..oven[i].y.."}");end
return true
end

if p:lower():find("text|/add (%d+) (%d+) (%d+)") then
    local ids, totals, timer = p:lower():match("text|/add (%d+) (%d+) (%d+)")
    ids = tonumber(ids)
    totals = tonumber(totals)
    timer = tonumber(timer)

    local exists = false
    for i = 1, #recipe do
        if recipe[i].id == ids then
            exists = true
            break
        end
    end

    if not exists then
        table.insert(recipe, {id = ids, total = totals, placeAt = timer})
        log("Added To Table { id = " .. getItemByID(ids).name .. " (" .. ids .. "), total = " .. totals .. ", delay = " .. timer .. " }")
    else
        log(getItemByID(ids).name .. " sudah ada di table, gabisa ditambahin lagi pake /change buat ubah total atau delay nya")
    end
    return true
end

if p:lower():find("text|/list") then
for i = 1, #recipe do
log("{id = "..recipe[i].id..", total = "..recipe[i].total..", placeAt = "..recipe[i].placeAt.."}")
end
return true
end

if p:lower():find("text|/dplace (%d+)") then
delay = p:lower():match("text|/dplace (%d+)")
log("Delay Di Set Ke : "..delay)
return true
end

if p:lower():find("text|/cook") then
dhook(main)
return true
end

if p:lower():find("text|/resetoven") then
oven = {}
log("Oven Resetted")
return true
end

if p:lower():find("text|/resetrecipe") then
recipe = {}
log("Recipe Resetted")
return true
end

if p:lower():find("text|/finish (%d+)") then
finished_cook_time = p:lower():match("text|/finish (%d+)")
log("Masak Selesai Di "..finished_cook_time.."(ms)")
return true
end

if p:lower():find("text|/helpcook") then
log("Command : /add <id item> <total> <timer>, /oven <x oven> <y oven>, /resetrecipe (reset all recipe), /resetoven (reset all oven x,y), /finish <finish selesai brp milisec>, /dplace <delay place item ke oven>, /change <id item> <total> <timer>, /cook(start cooking)")
return true
end

if p:lower():find("text|/change (%d+) (%d+) (%d+)") then
    local ids, totals, timer = p:lower():match("text|/change (%d+) (%d+) (%d+)")
    ids = tonumber(ids)
    totals = tonumber(totals)
    timer = tonumber(timer)

    local found = false
    for i = 1, #recipe do
        if recipe[i].id == ids then
            recipe[i].id = ids
            recipe[i].total = totals
            recipe[i].placeAt = timer
            log("Success! Changed. Use /list to see.")
            found = true
            break
        end
    end

    if not found then
        log("This ID was not found in the recipe table.")
    end

    return true
end

end)

for i= 1,10 do
log("Script Cook Custom has been Running do Command /HelpCook, To See Command")
en
