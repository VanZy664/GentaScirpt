local delay = 200 --Delay Punch Tree
local rad = 2 
local set = {
id = {
Tree_id = 3200,
Axe_id = 3206,
Coupon_id = 16566
},
save = {
World = "ROADTOABSOVAN",
Gem_Display_x = 98,
Gem_Display_y = 36
}
}

local runningThreads={}AddHook("OnRender","DelayCoroutineRunner",function()local now=os.clock()*1000 for i=#runningThreads,1,-1 do local t=runningThreads[i] if now>=t.resumeTime then local success,waitMS=coroutine.resume(t.thread) if coroutine.status(t.thread)=="dead" then table.remove(runningThreads,i) else t.resumeTime=now+(waitMS or 0)end end end end)function dhook(fn)local co=coroutine.create(fn)local ok,waitMS=coroutine.resume(co)if coroutine.status(co)~="dead" then table.insert(runningThreads,{thread=co,resumeTime=os.clock()*1000+(waitMS or 0)})end end function turu(ms)coroutine.yield(ms)end


function log(txt)
  logToConsole("`w[`9Difan Script`w] `2" .. txt)
end

function warp(world)
sendPacket(3, "action|join_request\nname|"..world.."\ninvitedWorld|1\n")
end

function use(id)
sendPacketRaw(false,{type = 10, value = id})
end

function inv(id)
for _, obj in pairs(getInventory()) do
if obj.id == id then
return obj.amount
end
end
return 0
end

function drop(id, amount)
sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..amount.."|\n")
end

function punch(x, y)
sendPacketRaw(false,{type=3,value=18,x=x*32,y=y*32,punchx=x,punchy=y})

local px = getLocal().pos.x//32
local state = nil
if x > px then
state = 2592
elseif x < px then
state = 2608
end

sendPacketRaw(false,{type=0,state=state,x=getLocal().pos.x,y=getLocal().pos.y,punchx=x,punchy=y})

end

function FindDroped(id)

for _, obj in pairs(getWorldObject()) do
if obj.id == id then
--findPath(obj.pos.x//32,obj.pos.y//32)
sendPacketRaw(false,{type=11,value=obj.oid,x=obj.pos.x,y=obj.pos.y})
return true
end
end
return false
end

function FindTree(radius)
  local px, py = getLocal().pos.x // 32, getLocal().pos.y // 32
  local world = getWorld()

  local positions = {}
  for dx = -radius, radius do
    for dy = -radius, radius do
      table.insert(positions, {x = px + dx, y = py + dy})
    end
  end

  -- Urutkan dari posisi terdekat ke player
  table.sort(positions, function(a, b)
    local da = (a.x - px)^2 + (a.y - py)^2
    local db = (b.x - px)^2 + (b.y - py)^2
    return da < db
  end)

  -- Periksa tile satu per satu
  for _, pos in ipairs(positions) do
    local tx, ty = pos.x, pos.y

    if tx >= 0 and ty >= 0 and tx < world.width and ty < world.height then
      local tile = checkTile(tx, ty)
      if tile.fg == set.id.Tree_id then
        punch(tx, ty)
        return true
      end
    end
  end

  return false
end


function main()
while true do
if inv(set.id.Axe_id) <= 0 then
repeat
warp(set.save.World)
turu(2000)
until getWorld().name == set.save.World
FindDroped(set.id.Axe_id)
use(set.id.Axe_id)
findPath(set.save.Gem_Display_x,set.save.Gem_Display_y)
repeat
turu(1000)
drop(set.id.Coupon_id, inv(set.id.Coupon_id))
until inv(set.id.Coupon_id) > 0
turu(1000)
warp("GROWCH")
turu(2000)
else
FindTree(rad)
turu(delay)
end
if brek then
break
end
end
end

AddHook("OnTextPacket","Settings",function(t,p)
if p:lower():find("text|/delay (%d+)") then
delay = tonumber(p:lower():match("text|/delay (%d+)"))
log("Delay Setting Ke "..delay)
return true
end

if p:lower():find("text|/radius (%d+)") then
rad = tonumber(p:lower():match("text|/radius (%d+)"))
log("Radius Di Atur Ke "..rad)
return true
end

if p:lower():find("text|/setdisplay") then
set.save.Gem_Display_x,set.save.Gem_Display_y=getLocal().pos.x//32,getLocal().pos.y//32
log("Display Drop Coupon Di Atur Ke "..set.save.Gem_Display_x..", "..set.save.Gem_Display_y)
return true
end

if p:lower():find("text|/world (.+)") then
set.save.World = p:lower():match("text|/world (.+)")
log("World Save Di Atur Ke "..set.save.World)
return true
end

if p:lower():find("text|/start") then
log("Memulai Auto Cut")
dhook(main)
return true
end

if p:lower():find("text|/stop") then
brek = true
log("Stopping Auto")
return true
end

end)


log("Command : /world <World Save>, /setdisplay (Save Coupon Ke World Save), /delay <delay mukul pohon>, /start (mulai auto), /radius <radius pohon yg mau di pukul>, /stop (Memberhentikan Auto)")
