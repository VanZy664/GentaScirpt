local delay = 300 --Delay Punch Tree
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
findPath(obj.pos.x//32,obj.pos.y//32)
return true
end
end
return false
end

function FindTree()
local x, y = getLocal().pos.x // 32, getLocal().pos.y // 32
for xxnx = 1, 99 do
for yyny = 1, 53 do
local tile = checkTile(xxnx, yyny)
if tile.fg == set.id.Tree_id then
if math.abs(x - xxnx) + math.abs(y - yyny) <= 5 then
punch(xxnx, yyny)
return true  -- Sukses menemukan dan memukul pohon
end
end
end
end
return false -- Tidak ada pohon dalam radius
end


function main()
while true do

if inv(set.id.Axe_id) <= 0 then
repeat
warp(set.save.World)
turu(2000)
until getWorld().name == set.save.World
FindDroped(set.id.Axe_id)
turu(1000)
findPath(set.save.Gem_Display_x,set.save.Gem_Display_y)
while inv(set.id.Coupon_id) > 0 do
turu(1000)
drop(set.id.Coupon_id, inv(set.id.Coupon_id))
end
turu(1000)
warp("GROWCH")
turu(1000)
else
FindTree()
turu(delay)
end

end
end


dhook(main)




