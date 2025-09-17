-- UFO HUB X Game.lua
-- Dispatcher จัดแมพ → เลือกสคริปต์ของคุณอัตโนมัติ
-- ใช้:  loadstring(game:HttpGet("https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-Game/refs/heads/main/UFO%20HUB%20X%20Game.lua"))()

--==================== Utilities (compat) ====================
local function http_get(url)
    if http and http.request then
        local ok, res = pcall(http.request, {Url=url, Method="GET"})
        if ok and res and (res.Body or res.body) then return true, (res.Body or res.body) end
    end
    if syn and syn.request then
        local ok, res = pcall(syn.request, {Url=url, Method="GET"})
        if ok and res and (res.Body or res.body) then return true, (res.Body or res.body) end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and body then return true, body end
    return false, "httpget_failed"
end

local function run_remote(url)
    local ok1, src = http_get(url)
    if not ok1 then
        warn("[UFO HUB X / Game] HttpGet failed →", url)
        return false, "httpget_failed"
    end
    local f, err = loadstring(src)
    if not f then
        warn("[UFO HUB X / Game] loadstring error:", err)
        return false, "loadstring_failed"
    end
    local ok2, ret = pcall(f)
    if not ok2 then
        warn("[UFO HUB X / Game] runtime error:", ret)
        return false, "runtime_failed"
    end
    return true, ret
end

local function norm(s)
    s = tostring(s or ""):lower()
    s = s:gsub("%s+", " "):gsub("[%c%p]", "") -- ตัดอักขระควบคุม/วรรคเยอะ/เครื่องหมาย
    return s
end

--==================== Sources (จากที่คุณให้มา) ====================
local URLs = {
    GrowAGarden       = "https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-Grow-a-Garden/refs/heads/main/UFO%20HUB%20X%20Grow%20a%20Garden.lua",
    Nights99Forest    = "https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-99--Nights-in--the-Forest/refs/heads/main/UFO%20HUB%20X%2099%20Nights%20in%20the%20Forest.lua",
    StealBrainrot     = "https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-Steal-a--Brainrot/refs/heads/main/UFO%20HUB%20X%20Steal%20a%20Brainrot.lua",
    BloxFruit1        = "https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-Blox-Fruit1/refs/heads/main/UFO%20HUB%20X%20Blox%20Fruit1.lua",
    BloxFruit2        = "https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-Blox-Fruit2/refs/heads/main/UFO%20HUB%20X%20Blox%20Fruit2.lua",
    BloxFruit3        = "https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-Blox-Fruit3/refs/heads/main/UFO%20HUB%20X%20Blox%20Fruit3.lua",
    FishIt            = "https://raw.githubusercontent.com/UFO-HUB-X-Studio/UFO-HUB-X-Fish-it/refs/heads/main/UFO%20HUB%20X%20Fish%20it.lua",
}

--==================== Mapping ด้วย PlaceId (เติมเพิ่มได้) ====================
-- NOTE: ยังไม่ทราบ PlaceId ที่แท้จริงของแต่ละเกม/โลก → ใส่ทีหลังได้เลย
-- วิธีดู: print("PlaceId:", game.PlaceId) แล้วไปเพิ่มไว้ในตารางนี้
local PlaceMap = {
    -- [1234567890] = URLs.GrowAGarden,
    -- [1111111111] = URLs.Nights99Forest,
    -- [2222222222] = URLs.StealBrainrot,

    -- ตัวอย่าง Blox Fruit (ใส่ PlaceId ของโลก 1/2/3 ให้ถูก)
    -- [2753915549] = URLs.BloxFruit1, -- ตัวอย่าง (โปรดแก้เป็นของคุณ)
    -- [4442272183] = URLs.BloxFruit2, -- ตัวอย่าง
    -- [7449423635] = URLs.BloxFruit3, -- ตัวอย่าง

    -- [121864768012064] = URLs.FishIt,  -- ตัวอย่าง
}

--==================== Fallback ด้วยชื่อเกม ====================
-- ถ้า PlaceId ไม่ถูกแมพ จะลองวิเคราะห์ชื่อเกมแทน
local NameRules = {
    { key="grow a garden",              url=URLs.GrowAGarden },
    { key="99 nights in the forest",    url=URLs.Nights99Forest },
    { key="steal a brainrot",           url=URLs.StealBrainrot },
    { key="blox fruit",                 url=URLs.BloxFruit1,  hint="Blox Fruit พบจากชื่อ → ดีฟอลต์โลก 1 (แนะนำใส่ PlaceId แยกโลกให้ชัด)" },
    { key="fish it",                    url=URLs.FishIt },
}

--==================== Decide & Run ====================
local placeId = tonumber(game.PlaceId) or 0
local placeURL = PlaceMap[placeId]

if placeURL then
    print(("[UFO HUB X / Game] Match by PlaceId %s"):format(placeId))
    local ok = select(1, run_remote(placeURL))
    if ok then
        print("[UFO HUB X / Game] Loaded by PlaceId ✓")
        return true
    else
        warn("[UFO HUB X / Game] Load failed (PlaceId).")
        return false
    end
end

-- Fallback by name
local gname = norm(game.Name or game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or "")
for _, rule in ipairs(NameRules) do
    if gname:find(rule.key, 1, true) then
        print(("[UFO HUB X / Game] Match by name: \"%s\""):format(rule.key))
        if rule.hint then warn("[UFO HUB X / Game] HINT: "..rule.hint) end
        local ok = select(1, run_remote(rule.url))
        if ok then
            print("[UFO HUB X / Game] Loaded by name ✓")
            return true
        else
            warn("[UFO HUB X / Game] Load failed (name).")
            return false
        end
    end
end

-- ไม่รองรับ → แจ้งรายละเอียดไว้ให้เพิ่ม mapping ได้เลย
warn("[UFO HUB X / Game] ❌ ไม่พบสคริปต์ที่รองรับแมพนี้")
warn("[UFO HUB X / Game] กรุณาเพิ่ม PlaceId ลงใน PlaceMap ด้านบน:")
warn(("    [%s] = <URL ของสคริปต์>"):format(placeId))
warn(("[UFO HUB X / Game] GameName: %s"):format(game.Name or "Unknown"))
return false
