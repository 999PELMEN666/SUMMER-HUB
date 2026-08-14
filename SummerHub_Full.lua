--[[
  SUMMER HUB — Neverlose-style
  Shape-safe glass (includes lenses) | UID | Themes | Configs
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

do
    local old = _G.SH
    if old then
        pcall(function()
            if old.conns then for _, c in pairs(old.conns) do pcall(function() c:Disconnect() end) end end
            if old.gui then old.gui:Destroy() end
            if old.tracers then old.tracers:Destroy() end
            if old.cc then old.cc:Destroy() end
            if old.wm then old.wm:Destroy() end
            if old.slotGui then old.slotGui:Destroy() end
        end)
        _G.SH = nil
        task.wait(0.12)
    end
end

_G.SH = { conns = {}, state = {}, skins = {} }
local SH = _G.SH
local function conn(c) table.insert(SH.conns, c) return c end

-- ================= UID =================
-- UID: sequential starting at 1. Bot API optional.
-- BOT_UID_URL should return JSON: {"max":12} or {"next":13} or {"banned":["3","5"]}
local UID_FILE = "SummerHub_UID.txt"
local BOT_UID_URL = "https://summer-hub.fly.dev"
local BAN_URL = ""
local function getOrCreateUID()
    local existing = nil
    pcall(function()
        if isfile and isfile(UID_FILE) then
            existing = readfile(UID_FILE):match("%d+")
        end
    end)
    if existing then
        return existing
    end
    local nextId = 1
    if BOT_UID_URL ~= "" then
        local base = BOT_UID_URL:gsub("/+$", "")
        local url = base
        if not base:find("/uid") then url = base .. "/uid/next" end
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if ok and body then
            local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
            if ok2 and type(data) == "table" then
                if type(data.next) == "number" then
                    nextId = math.max(1, math.floor(data.next))
                elseif type(data.max) == "number" then
                    nextId = math.max(1, math.floor(data.max) + 1)
                end
            end
        end
    else
        -- local counter shared on this PC
        local COUNTER = "SummerHub_UID_Max.txt"
        local maxLocal = 0
        pcall(function()
            if isfile and isfile(COUNTER) then
                maxLocal = tonumber(readfile(COUNTER):match("%d+")) or 0
            end
        end)
        nextId = maxLocal + 1
        pcall(function()
            if writefile then writefile(COUNTER, tostring(nextId)) end
        end)
    end
    local uid = tostring(nextId)
    pcall(function()
        if writefile then writefile(UID_FILE, uid) end
    end)
    -- optional register with bot
    if BOT_UID_URL ~= "" then
        pcall(function()
            local base = BOT_UID_URL:gsub("/+$", "")
            local u = base:find("/uid") and base:gsub("/next","/register"):gsub("/max","/register") or (base .. "/uid/register")
            game:HttpGet(u .. "?uid=" .. uid .. "&user=" .. tostring(LP.UserId))
        end)
    end
    return uid
end
local MY_UID = getOrCreateUID()
local function isBanned()
    local url = BAN_URL
    if (not url or url == "") and BOT_UID_URL ~= "" then
        local base = BOT_UID_URL:gsub("/+$", "")
        url = base:find("/uid") and base:gsub("/next","/bans"):gsub("/max","/bans") or (base .. "/uid/bans")
    end
    if not url or url == "" then return false end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok or not body then return false end
    local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok2 or type(data) ~= "table" then return false end
    local list = data.banned or {}
    for _, v in ipairs(list) do
        if tostring(v) == tostring(MY_UID) then return true end
    end
    return false
end
if isBanned() then
    warn("[SummerHub] UID "..MY_UID.." is banned")
    return
end

-- ================= THEMES =================
local Themes = {
    Neverlose = {
        bg=Color3.fromRGB(18,18,24), sidebar=Color3.fromRGB(14,14,20), panel=Color3.fromRGB(24,24,32),
        card=Color3.fromRGB(30,30,40), cardH=Color3.fromRGB(38,38,50),
        accent=Color3.fromRGB(90,130,255), accent2=Color3.fromRGB(120,160,255),
        text=Color3.fromRGB(230,230,240), dim=Color3.fromRGB(130,130,150),
        green=Color3.fromRGB(70,200,120), track=Color3.fromRGB(40,40,52), fill=Color3.fromRGB(90,130,255),
        stroke=Color3.fromRGB(50,50,70), toggleOn=Color3.fromRGB(90,130,255), toggleOff=Color3.fromRGB(45,45,58),
    },
    Summer = {
        bg=Color3.fromRGB(16,12,10), sidebar=Color3.fromRGB(12,9,8), panel=Color3.fromRGB(26,20,16),
        card=Color3.fromRGB(34,26,20), cardH=Color3.fromRGB(48,36,28),
        accent=Color3.fromRGB(255,130,40), accent2=Color3.fromRGB(255,180,80),
        text=Color3.fromRGB(255,240,220), dim=Color3.fromRGB(170,140,110),
        green=Color3.fromRGB(80,210,100), track=Color3.fromRGB(40,32,26), fill=Color3.fromRGB(255,130,40),
        stroke=Color3.fromRGB(80,50,30), toggleOn=Color3.fromRGB(255,130,40), toggleOff=Color3.fromRGB(45,36,30),
    },
    Midnight = {
        bg=Color3.fromRGB(10,12,20), sidebar=Color3.fromRGB(8,10,16), panel=Color3.fromRGB(16,18,28),
        card=Color3.fromRGB(22,24,36), cardH=Color3.fromRGB(30,34,50),
        accent=Color3.fromRGB(140,80,255), accent2=Color3.fromRGB(180,130,255),
        text=Color3.fromRGB(230,225,245), dim=Color3.fromRGB(140,130,170),
        green=Color3.fromRGB(80,210,140), track=Color3.fromRGB(32,30,48), fill=Color3.fromRGB(140,80,255),
        stroke=Color3.fromRGB(60,50,90), toggleOn=Color3.fromRGB(140,80,255), toggleOff=Color3.fromRGB(36,34,52),
    },
    Ocean = {
        bg=Color3.fromRGB(10,16,22), sidebar=Color3.fromRGB(8,12,18), panel=Color3.fromRGB(14,22,30),
        card=Color3.fromRGB(18,28,38), cardH=Color3.fromRGB(24,38,50),
        accent=Color3.fromRGB(40,200,220), accent2=Color3.fromRGB(80,230,240),
        text=Color3.fromRGB(220,240,250), dim=Color3.fromRGB(120,150,170),
        green=Color3.fromRGB(60,210,160), track=Color3.fromRGB(28,40,50), fill=Color3.fromRGB(40,200,220),
        stroke=Color3.fromRGB(30,70,90), toggleOn=Color3.fromRGB(40,200,220), toggleOff=Color3.fromRGB(30,42,52),
    },
    Crimson = {
        bg=Color3.fromRGB(18,10,12), sidebar=Color3.fromRGB(14,8,10), panel=Color3.fromRGB(28,14,18),
        card=Color3.fromRGB(36,18,22), cardH=Color3.fromRGB(50,24,30),
        accent=Color3.fromRGB(220,50,70), accent2=Color3.fromRGB(255,100,120),
        text=Color3.fromRGB(255,230,235), dim=Color3.fromRGB(180,130,140),
        green=Color3.fromRGB(80,210,100), track=Color3.fromRGB(40,22,26), fill=Color3.fromRGB(220,50,70),
        stroke=Color3.fromRGB(90,30,40), toggleOn=Color3.fromRGB(220,50,70), toggleOff=Color3.fromRGB(40,22,26),
    },
    Light = {
        bg=Color3.fromRGB(240,240,245), sidebar=Color3.fromRGB(230,230,238), panel=Color3.fromRGB(255,255,255),
        card=Color3.fromRGB(245,245,250), cardH=Color3.fromRGB(230,230,240),
        accent=Color3.fromRGB(70,110,230), accent2=Color3.fromRGB(50,90,210),
        text=Color3.fromRGB(30,30,40), dim=Color3.fromRGB(110,110,130),
        green=Color3.fromRGB(40,160,90), track=Color3.fromRGB(210,210,220), fill=Color3.fromRGB(70,110,230),
        stroke=Color3.fromRGB(200,200,210), toggleOn=Color3.fromRGB(70,110,230), toggleOff=Color3.fromRGB(200,200,210),
    },
    Custom = {
        bg=Color3.fromRGB(18,18,24), sidebar=Color3.fromRGB(14,14,20), panel=Color3.fromRGB(24,24,32),
        card=Color3.fromRGB(30,30,40), cardH=Color3.fromRGB(38,38,50),
        accent=Color3.fromRGB(90,130,255), accent2=Color3.fromRGB(120,160,255),
        text=Color3.fromRGB(230,230,240), dim=Color3.fromRGB(130,130,150),
        green=Color3.fromRGB(70,200,120), track=Color3.fromRGB(40,40,52), fill=Color3.fromRGB(90,130,255),
        stroke=Color3.fromRGB(50,50,70), toggleOn=Color3.fromRGB(90,130,255), toggleOff=Color3.fromRGB(45,45,58),
    },
}
local themeName = "Neverlose"
local T = {}
for k,v in pairs(Themes.Neverlose) do T[k]=v end
local uiScale = 1

local S = {
    armOn=false, gunOn=false, shieldOn=false,
    armT=0.55, gunT=0.55, shieldT=0.55,
    armColorOn=false, gunColorOn=false, shieldColorOn=false,
    armCol=Color3.fromRGB(255,80,160), gunCol=Color3.fromRGB(255,50,50), shieldCol=Color3.fromRGB(100,180,255),
    bodyOn=false, bodyT=0.6,
    tracers=false, rainbowTr=false, thick=0.1, life=0.85, trCol=Color3.fromRGB(255,255,255),
    worldOn=false, worldCol=Color3.fromRGB(180,80,255),
    worldBright=0, worldContrast=0.1, worldSat=0.2, worldTint=0.45,
    timeOn=false, timeOfDay=14,
    killFx=false, killFxColor=Color3.fromRGB(255, 60, 80),
    cfgName="default", autoSave=false,
    wmOn=true, wmStyle=1,
    wmShowFPS=true, wmShowPing=true, wmShowName=true, wmShowTime=true, wmImage="",
    menuKey=Enum.KeyCode.End, hideKey=Enum.KeyCode.RightShift,
}
SH.state = S

-- ================= GLASS (old system + lenses, Shape-safe) =================
local arms, guns, shields, bodyParts = {}, {}, {}, {}
local texBackup = {}

local function armName(n)
    n = string.lower(n or "")
    return n:find("arm",1,true) or n:find("hand",1,true) or n:find("glove",1,true)
        or n:find("sleeve",1,true) or n:find("viewmodel",1,true)
end
local function isShieldName(n)
    n = string.lower(n or "")
    return n:find("shield",1,true) or n:find("riot",1,true) or n:find("ballistic",1,true)
end

local function isLens(p)
    if not p then return false end
    local n = string.lower(p.Name)
    if n:find("lens",1,true) or n:find("reticle",1,true) or n:find("reticule",1,true) then return true end
    if n:find("viewport",1,true) or n:find("crosshair",1,true) or n:find("dot",1,true) then return true end
    if p:FindFirstChildOfClass("SurfaceGui") then return true end
    if p.Material == Enum.Material.Neon and p.Size.Magnitude < 0.55 then return true end
    if p:IsA("Part") then
        local ok, shape = pcall(function() return p.Shape end)
        if ok and shape == Enum.PartType.Ball and p.Size.Magnitude < 0.8 then return true end
    end
    return false
end

local function isSightBody(p)
    local n = string.lower(p.Name)
    if n:find("scope",1,true) or n:find("sight",1,true) or n:find("optic",1,true) then return true end
    if n:find("iron",1,true) or n:find("acog",1,true) or n:find("holo",1,true) or n:find("reflex",1,true) then return true end
    local cur = p.Parent
    for _ = 1, 6 do
        if not cur or cur == workspace or cur == Camera then break end
        local cn = string.lower(tostring(cur.Name))
        if cn:find("scope",1,true) or cn:find("sight",1,true) or cn:find("optic",1,true) then return true end
        cur = cur.Parent
    end
    return false
end

local function isGuts(p)
    local n = string.lower(p.Name)
    if n:find("bolt",1,true) or n:find("trigger",1,true) or n:find("spring",1,true) then return true end
    if n:find("chamber",1,true) or n:find("inner",1,true) or n:find("mech",1,true) then return true end
    return p.Size.Magnitude < 0.32
end

local function killSkin(p)
    pcall(function()
        if p:IsA("MeshPart") then
            if texBackup[p] == nil then texBackup[p] = p.TextureID end
            if p.TextureID ~= "" then p.TextureID = "" end
        end
        for _, ch in ipairs(p:GetChildren()) do
            if ch:IsA("Decal") or ch:IsA("Texture") then ch.Transparency = 1 end
            if ch.ClassName == "SurfaceAppearance" then ch:Destroy() end
        end
    end)
end

-- OLD glass: LTM + killSkin + white/color, INCLUDING lenses/sights
local function applyGlass(p, t, col, colorOn)
    if not p or not p.Parent then return end
    local wash = math.clamp(t * 1.15, 0, 1)
    local base = colorOn and col or Color3.new(1, 1, 1)
    local washed = base:Lerp(Color3.new(1, 1, 1), wash * 0.8)
    if isGuts(p) then
        p.LocalTransparencyModifier = 1
        killSkin(p)
        return
    end
    -- sight body + lens: LTM + killSkin + color (no Material force on lens-ish)
    if isSightBody(p) or isLens(p) then
        p.LocalTransparencyModifier = t
        killSkin(p)
        p.Color = washed
        return
    end
    killSkin(p)
    p.LocalTransparencyModifier = t
    pcall(function() p.Material = Enum.Material.SmoothPlastic end)
    p.Color = washed
end

local function scan()
    arms, guns, shields, bodyParts = {}, {}, {}, {}
    local cam, char = workspace.CurrentCamera, LP.Character
    local bodySet = {}
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then bodySet[p] = true end
        end
        for _, name in ipairs({
            "Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart",
            "Left Leg","Right Leg","Left Arm","Right Arm",
            "LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot",
            "LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand"
        }) do
            local p = char:FindFirstChild(name)
            if p and p:IsA("BasePart") then table.insert(bodyParts, p) end
        end
    end
    local seen = {}
    local function push(p, kind)
        if not p:IsA("BasePart") then return end
        if seen[p] then return end
        -- prefer shield classification if name matches
        if isShieldName(p.Name) or (p.Parent and isShieldName(p.Parent.Name)) then
            kind = "shield"
        end
        if bodySet[p] and kind ~= "shield" then
            if not p:FindFirstAncestorOfClass("Tool") then return end
            if kind == "arm" then kind = "gun" end
        end
        seen[p] = true
        if kind == "arm" then table.insert(arms, p)
        elseif kind == "shield" then table.insert(shields, p)
        else table.insert(guns, p) end
    end
    if cam then
        for _, obj in ipairs(cam:GetChildren()) do
            local isA, isS = armName(obj.Name), isShieldName(obj.Name)
            for _, p in ipairs(obj:GetDescendants()) do
                if p:IsA("BasePart") then
                    if isS or isShieldName(p.Name) then push(p, "shield")
                    elseif isA or armName(p.Name) then push(p, "arm")
                    else push(p, "gun") end
                end
            end
            if obj:IsA("BasePart") then
                if isS then push(obj,"shield") elseif isA then push(obj,"arm") else push(obj,"gun") end
            end
        end
    end
    -- Do NOT scan Character tools for FP glass (Camera viewmodel only).
    -- Scanning both Camera + Character caused double shield/gun ghosts.
end

local function hardRefresh()
    scan()
    for _, d in ipairs({0.03, 0.1, 0.25, 0.5, 1.0}) do
        task.delay(d, function() if _G.SH then scan() end end)
    end
end

conn(RunService.RenderStepped:Connect(function()
    if S.armOn or S.armColorOn then
        for i=1,#arms do
            local p=arms[i]
            if p and p.Parent then
                killSkin(p)
                pcall(function() p.Material = Enum.Material.SmoothPlastic end)
                if S.armOn then
                    p.LocalTransparencyModifier = S.armT
                end
                if S.armColorOn then
                    p.Color = S.armCol
                elseif S.armOn then
                    p.Color = Color3.new(1,1,1)
                end
            end
        end
    end
    if S.gunOn or S.gunColorOn then
        for i=1,#guns do
            local p=guns[i]
            if p and p.Parent and not isGuts(p) then
                if S.gunOn then
                    applyGlass(p, S.gunT, S.gunCol, S.gunColorOn)
                else
                    killSkin(p)
                    pcall(function() p.Material = Enum.Material.SmoothPlastic end)
                    p.Color = S.gunCol
                end
            end
        end
    end
    if S.shieldOn or S.shieldColorOn then
        for i=1,#shields do
            local p=shields[i]
            if p and p.Parent then
                if S.shieldOn then
                    applyGlass(p, S.shieldT, S.shieldCol, S.shieldColorOn)
                else
                    killSkin(p)
                    pcall(function() p.Material = Enum.Material.SmoothPlastic end)
                    p.Color = S.shieldCol
                end
            end
        end
    end
    if S.bodyOn then
        for i=1,#bodyParts do
            local p=bodyParts[i]
            if p and p.Parent then p.LocalTransparencyModifier = S.bodyT end
        end
    end
end))

conn(task.spawn(function()
    while _G.SH do
        if S.armOn or S.gunOn or S.shieldOn or S.armColorOn or S.gunColorOn or S.shieldColorOn or S.bodyOn then
            pcall(scan)
        end
        task.wait(0.45)
    end
end))

local function onTool(c)
    if c:IsA("Tool") or isShieldName(c.Name) then hardRefresh() end
end
local function hookChar(char)
    conn(char.ChildAdded:Connect(onTool))
    for _, c in ipairs(char:GetChildren()) do onTool(c) end
end
if LP.Character then hookChar(LP.Character) end
conn(LP.CharacterAdded:Connect(function(c) task.wait(0.25) hookChar(c) hardRefresh() end))
conn(Camera.ChildAdded:Connect(function() hardRefresh() end))

-- world
local cc = Instance.new("ColorCorrectionEffect")
cc.Name, cc.Enabled, cc.Parent = "SH_World", false, Lighting
SH.cc = cc
local function applyWorld()
    if S.worldOn then
        cc.Enabled = true
        cc.TintColor = Color3.new(1,1,1):Lerp(S.worldCol, S.worldTint)
        cc.Brightness, cc.Contrast, cc.Saturation = S.worldBright, S.worldContrast, S.worldSat
    else cc.Enabled = false end
end
conn(RunService.Heartbeat:Connect(function()
    if S.timeOn then pcall(function() if Lighting.ClockTime ~= S.timeOfDay then Lighting.ClockTime = S.timeOfDay end end) end
end))

-- ================= KILL EFFECT (screen edge flash) =================
local killGui = Instance.new("ScreenGui")
killGui.Name, killGui.ResetOnSpawn, killGui.DisplayOrder, killGui.IgnoreGuiInset = "SH_KillFX", false, 999990, true
killGui.Parent = CoreGui
local function mkEdge(pos, size)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = Color3.fromRGB(255, 40, 60)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Size, f.Position = size, pos
    f.Parent = killGui
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.45, 0.55),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Parent = f
    return f, g
end
local edgeL, gL = mkEdge(UDim2.new(0,0,0,0), UDim2.new(0, 120, 1, 0))
gL.Rotation = 0
local edgeR, gR = mkEdge(UDim2.new(1, -120, 0, 0), UDim2.new(0, 120, 1, 0))
gR.Rotation = 180
local edgeT, gT = mkEdge(UDim2.new(0,0,0,0), UDim2.new(1, 0, 0, 90))
gT.Rotation = 90
local edgeB, gB = mkEdge(UDim2.new(0,0,1,-90), UDim2.new(1, 0, 0, 90))
gB.Rotation = 270
local killBusy = false
local function playKillFX()
    if not S.killFx or killBusy then return end
    killBusy = true
    local col = S.killFxColor or Color3.fromRGB(255, 60, 80)
    for _, e in ipairs({edgeL, edgeR, edgeT, edgeB}) do
        e.BackgroundColor3 = col
        e.BackgroundTransparency = 0.15
        TweenService:Create(e, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
    end
    task.delay(0.6, function() killBusy = false end)
end
local function hookKill(char)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
    if not hum then return end
    conn(hum.Died:Connect(function()
        local tag = hum:FindFirstChild("creator") or hum:FindFirstChild("Creator")
        local killer = tag and tag.Value
        if killer == LP or (typeof(killer) == "Instance" and (killer == LP or killer:IsDescendantOf(LP))) then
            playKillFX()
        end
    end))
end
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then
        if plr.Character then hookKill(plr.Character) end
        conn(plr.CharacterAdded:Connect(hookKill))
    end
end
conn(Players.PlayerAdded:Connect(function(plr)
    if plr == LP then return end
    conn(plr.CharacterAdded:Connect(hookKill))
end))


-- tracers
local folder = Instance.new("Folder")
folder.Name, folder.Parent = "SH_Tracers", workspace
SH.tracers = folder
local function fireTracer()
    if not S.tracers then return end
    local char = LP.Character
    if not char then return end
    local origin = Camera.CFrame.Position + Camera.CFrame.LookVector * 0.5
    local dir = Camera.CFrame.LookVector
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, folder, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local hit = workspace:Raycast(origin, dir * 2500, params)
    local to = hit and hit.Position or (origin + dir * 800)
    local dist = (to - origin).Magnitude
    if dist < 0.5 then return end
    local col = S.rainbowTr and Color3.fromHSV((tick()*0.6)%1,1,1) or S.trCol
    local th = S.thick
    local core = Instance.new("Part")
    core.Anchored, core.CanCollide, core.CanQuery = true, false, false
    core.Material, core.Color = Enum.Material.Neon, col
    core.Size = Vector3.new(th*0.4, th*0.4, dist)
    core.CFrame = CFrame.lookAt(origin, to) * CFrame.new(0,0,-dist/2)
    core.Parent = folder
    local glow = core:Clone()
    glow.Size, glow.Transparency, glow.Parent = Vector3.new(th*1.15, th*1.15, dist), 0.75, folder
    local life = S.life
    task.delay(life*0.15, function()
        pcall(function()
            local info = TweenInfo.new(life*0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(core, info, {Transparency=1}):Play()
            TweenService:Create(glow, info, {Transparency=1}):Play()
        end)
        task.delay(life, function() pcall(function() core:Destroy() end) pcall(function() glow:Destroy() end) end)
    end)
end
conn(UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if S.tracers and inp.UserInputType == Enum.UserInputType.MouseButton1 then fireTracer() end
end))

-- name/slots/hud
local savedDisplayName, savedGameUsername, savedRank = "", "", ""
local namesEnabled, nameColorEnabled = false, false
local rainbowDisplayEnabled, rainbowUsernameEnabled, rainbowRankEnabled = false, false, false
local rainbowSpeed = 1
local slotActive, slotMode = true, "RGB"
local slotHighlights = {}
local RED_S, WHITE_S = Color3.fromRGB(216,30,27), Color3.new(1,1,1)
local gunHUDActive, gunHUDMode = true, "RGB"

local function applyNamesToChar(char)
    if savedDisplayName=="" and savedGameUsername=="" and savedRank=="" then return end
    char = char or LP.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:WaitForChild("Head",5)
    if not head then return end
    local nameTag = head:FindFirstChild("NameTag") or head:WaitForChild("NameTag",5)
    if not nameTag then return end
    if savedDisplayName ~= "" then
        local lbl = nameTag:FindFirstChild("Username")
        if lbl and lbl:IsA("TextLabel") then lbl.Text = savedDisplayName end
    end
    if savedGameUsername ~= "" then
        local lbl = nameTag:FindFirstChild("DisplayName")
        if lbl and lbl:IsA("TextLabel") then
            local u = savedGameUsername
            lbl.Text = (u:sub(1,1)=="@") and u or ("@"..u)
        end
    end
    local rankLbl = nameTag:FindFirstChild("Rank")
    if rankLbl and rankLbl:IsA("TextLabel") and savedRank ~= "" then
        rankLbl.Text = savedRank; rankLbl.Visible = true
    end
end

conn(RunService.RenderStepped:Connect(function()
    if not nameColorEnabled then return end
    if not (rainbowDisplayEnabled or rainbowUsernameEnabled or rainbowRankEnabled) then return end
    pcall(function()
        local char = LP.Character
        if not char then return end
        local head = char:FindFirstChild("Head"); if not head then return end
        local nameTag = head:FindFirstChild("NameTag"); if not nameTag then return end
        local rc = Color3.fromHSV(((tick()*rainbowSpeed*40)%360)/360, 1, 1)
        local un, dn, rk = nameTag:FindFirstChild("Username"), nameTag:FindFirstChild("DisplayName"), nameTag:FindFirstChild("Rank")
        if rainbowDisplayEnabled and un and un:IsA("TextLabel") then un.TextColor3 = rc end
        if rainbowUsernameEnabled and dn and dn:IsA("TextLabel") then dn.TextColor3 = rc end
        if rainbowRankEnabled and rk and rk:IsA("TextLabel") then rk.TextColor3 = rc end
    end)
end))
conn(LP.CharacterAdded:Connect(function(char) if namesEnabled then task.wait(1.2) applyNamesToChar(char) end end))

task.delay(1, function()
    local slots = {}
    pcall(function()
        local rg = CoreGui:FindFirstChild("RobloxGui")
        local bp = rg and rg:FindFirstChild("Backpack")
        local hb = bp and bp:FindFirstChild("Hotbar")
        if hb then
            for i=1,9 do slots[i]=hb:FindFirstChild(tostring(i)) end
            slots[10]=hb:FindFirstChild("0")
        end
    end)
    local slotGui = Instance.new("ScreenGui")
    slotGui.Name, slotGui.ResetOnSpawn, slotGui.Parent = "SH_RGBSlot", false, PGui
    SH.slotGui = slotGui
    for i=1,10 do
        local slot = slots[i]
        if slot and slot:IsA("GuiObject") then
            local h = Instance.new("Frame")
            h.Size, h.BackgroundColor3, h.BackgroundTransparency = UDim2.new(1,0,1,0), WHITE_S, 0.3
            h.BorderSizePixel, h.ZIndex, h.Name, h.Parent = 0, 1, "SH_HL", slot
            local g = Instance.new("UIGradient")
            g.Rotation=45
            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,WHITE_S), ColorSequenceKeypoint.new(0.2,WHITE_S),
                ColorSequenceKeypoint.new(0.7,RED_S), ColorSequenceKeypoint.new(1,RED_S),
            })
            g.Parent = h
            table.insert(slotHighlights, {frame=h, gradient=g})
        end
    end
end)
conn(RunService.RenderStepped:Connect(function()
    if not slotActive then return end
    local color = slotMode=="RGB" and Color3.fromHSV(tick()%6/6,1,1) or nil
    for _, h in ipairs(slotHighlights) do
        if h.frame and h.frame.Parent then
            h.frame.Visible = true
            if slotMode=="RGB" then h.gradient.Enabled=false; h.frame.BackgroundColor3=color
            else h.gradient.Enabled=true; h.frame.BackgroundColor3=WHITE_S end
        end
    end
end))
conn(RunService.RenderStepped:Connect(function()
    if not gunHUDActive then return end
    local gunHUD = PGui:FindFirstChild("StatusUI")
    gunHUD = gunHUD and gunHUD:FindFirstChild("GunHUD")
    if not gunHUD then return end
    local color = gunHUDMode=="RGB" and Color3.fromHSV(tick()%6/6,1,1) or Color3.fromRGB(216,30,27)
    for _, name in ipairs({"AmmoText","AmmoTextSecondary","FireMode","GunName","InfoText"}) do
        local el = gunHUD:FindFirstChild(name)
        if el then
            if el:IsA("TextLabel") or el:IsA("TextButton") then el.TextColor3=color end
            el.BackgroundColor3=color
        end
    end
end))

-- config
local CFG = "SummerHubConfigs"
local function listConfigs()
    local list = {}
    pcall(function()
        if isfolder and isfolder(CFG) and listfiles then
            for _, f in ipairs(listfiles(CFG)) do
                local name = f:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end
    end)
    table.sort(list)
    return list
end
local function saveCfg(name)
    if typeof(writefile) ~= "function" then return false, "no writefile" end
    name = tostring(name):gsub("%s+",""):gsub("[^%w_%-]","_")
    if name=="" then return false,"empty" end
    S.cfgName = name
    pcall(function() if makefolder and isfolder and not isfolder(CFG) then makefolder(CFG) end end)
    local data = {theme=themeName, uiScale=uiScale, autoSave=S.autoSave}
    for k,v in pairs(S) do
        if typeof(v)=="Color3" then data[k]={v.R,v.G,v.B}
        elseif typeof(v)=="EnumItem" then data[k]=tostring(v)
        elseif type(v)=="boolean" or type(v)=="number" or type(v)=="string" then data[k]=v
        end
    end
    pcall(function()
        local frames = {}
        if SH.wm then
            for _, ch in ipairs(SH.wm:GetChildren()) do
                if ch:IsA("Frame") then table.insert(frames, ch) end
            end
            if frames[1] then
                data.wm1Pos = {frames[1].Position.X.Scale, frames[1].Position.X.Offset, frames[1].Position.Y.Scale, frames[1].Position.Y.Offset}
            end
            if frames[2] then
                data.wm2Pos = {frames[2].Position.X.Scale, frames[2].Position.X.Offset, frames[2].Position.Y.Scale, frames[2].Position.Y.Offset}
            end
        end
        if SH.gui then
            local w = SH.gui:FindFirstChildWhichIsA("Frame")
            if w then
                data.winPos = {w.Position.X.Scale, w.Position.X.Offset, w.Position.Y.Scale, w.Position.Y.Offset}
            end
        end
    end)
    if Themes.Custom then
        data.customTheme = {}
        for k,v in pairs(Themes.Custom) do
            if typeof(v)=="Color3" then data.customTheme[k]={v.R,v.G,v.B} end
        end
    end
    local ok, err = pcall(function()
        writefile(CFG.."/"..name..".json", HttpService:JSONEncode(data))
    end)
    return ok, err
end
local function loadCfg(name)
    if typeof(readfile) ~= "function" then return false, "no readfile" end
    name = tostring(name):gsub("%s+",""):gsub("[^%w_%-]","_")
    local ok, d = pcall(function() return HttpService:JSONDecode(readfile(CFG.."/"..name..".json")) end)
    if not ok or type(d)~="table" then return false, "not found" end
    if d.customTheme then
        for k,v in pairs(d.customTheme) do
            if type(v)=="table" and #v==3 then Themes.Custom[k]=Color3.new(v[1],v[2],v[3]) end
        end
    end
    if d.theme and Themes[d.theme] then
        themeName = d.theme
        for k,v in pairs(Themes[themeName]) do T[k]=v end
        pcall(function() if applyTheme then applyTheme(themeName) end end)
    end
    if type(d.uiScale)=="number" then
        uiScale = math.clamp(d.uiScale, 0.75, 1.35)
        pcall(function() if scale then scale.Scale = uiScale end end)
    end
    if type(d.autoSave)=="boolean" then S.autoSave = d.autoSave end
    for k,v in pairs(d) do
        if S[k]~=nil then
            if type(v)=="table" and #v==3 and typeof(S[k])=="Color3" then
                S[k]=Color3.new(v[1],v[2],v[3])
            elseif type(v)=="boolean" or type(v)=="number" or type(v)=="string" then
                if typeof(S[k]) ~= "EnumItem" then S[k]=v end
            end
        end
    end
    -- restore positions
    pcall(function()
        local frames = {}
        if SH.wm then
            for _, ch in ipairs(SH.wm:GetChildren()) do
                if ch:IsA("Frame") then table.insert(frames, ch) end
            end
            if d.wm1Pos and frames[1] and type(d.wm1Pos)=="table" and #d.wm1Pos>=4 then
                frames[1].Position = UDim2.new(d.wm1Pos[1], d.wm1Pos[2], d.wm1Pos[3], d.wm1Pos[4])
            end
            if d.wm2Pos and frames[2] and type(d.wm2Pos)=="table" and #d.wm2Pos>=4 then
                frames[2].Position = UDim2.new(d.wm2Pos[1], d.wm2Pos[2], d.wm2Pos[3], d.wm2Pos[4])
            end
        end
        if d.winPos and SH.gui and type(d.winPos)=="table" and #d.winPos>=4 then
            local w = SH.gui:FindFirstChildWhichIsA("Frame")
            if w then
                w.Position = UDim2.new(d.winPos[1], d.winPos[2], d.winPos[3], d.winPos[4])
            end
        end
    end)
    S.cfgName = name
    applyWorld(); hardRefresh()
    for _, f in ipairs(repaint) do pcall(f) end
    return true
end

-- hide HUD

conn(task.spawn(function()
    while _G.SH do
        task.wait(45)
        if S.autoSave and S.cfgName and S.cfgName ~= "" then
            pcall(function() saveCfg(S.cfgName) end)
        end
    end
end))

local hidden, savedUI = false, {}
local paths = {
    "UI.Container.HUD.Map.Container","UI.Container.HUD.Menu.HUD.Left.Buttons",
    "UI.Container.HUD.Menu.HUD.Left.MedalEvent","UI.Container.HUD.Menu.HUD.Left.GuideButton",
    "UI.Container.HUD.Menu.HUD.Left.TycoonCompletion","UI.Container.HUD.Menu.HUD.Left.MedalsCurrencyDisplay",
    "UI.Container.HUD.Menu.HUD.Left.CashCurrencyDisplay","UI.Container.HUD.Menu.HUD.Left.BaseStatus",
    "UI.Container.HUD.Menu.HUD.Right.VIPButton","UI.Container.HUD.Menu.HUD.Right.SpinnerButton",
    "UI.Container.HUD.Menu.HUD.Right.OperationsButton","UI.Container.HUD.Menu.HUD.Right.FactionsButton",
    "UI.Container.HUD.Menu.HUD.Right.DailyRewardButton","UI.Container.HUD.Menu.HUD.Right.DailyButton",
    "UI.Container.HUD.Menu.HUD.Right.CamoButton",
}
local function getEl(path)
    local o = PGui
    for p in path:gmatch("[^%.]+") do o = o and o:FindFirstChild(p); if not o then return nil end end
    return o
end
local function hideGameUI()
    savedUI = {}
    for _, path in ipairs(paths) do
        pcall(function() local o=getEl(path); if o then savedUI[o]=o.Size; o.Size=UDim2.new(0,0,0,0) end end)
    end
end
local function showGameUI()
    for o,sz in pairs(savedUI) do pcall(function() o.Size=sz end) end
end

-- skins compact
local SK = SH.skins
do
    local IS_OLD = (game.PlaceId == 124195929639441)
    local PLACEHOLDER = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    local CFG_FOLDER = IS_OLD and "velochanger_oldwt" or "velochanger_newwt"
    local CFG_FILE = CFG_FOLDER.."/config_sc.json"
    local ATTRS = {"Camo1","Camo2","Camo1Animated","Camo2Animated","Camo1Color","Camo2Color"}
    pcall(function() if makefolder and isfolder and not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end)
    local function safe(root, ...)
        local c=root
        for _,n in ipairs({...}) do if not c then return nil end c=c:FindFirstChild(n) end
        return c
    end
    local RARS = {
        {id=1,cA=Color3.new(.52,.53,.52)},{id=2,cA=Color3.new(.32,.73,.85)},
        {id=3,cA=Color3.new(.72,.38,.87)},{id=4,cA=Color3.new(.83,.87,.27)},
        {id=5,cA=Color3.new(1,.11,.66)},{id=6,cA=Color3.new(.04,1,.71)},
    }
    local function rarityOf(g)
        if not g then return 1 end
        local kp=g.Color.Keypoints; if #kp<1 then return 1 end
        local f,bi,bd=kp[1].Value,1,math.huge
        for _,r in ipairs(RARS) do
            local d=math.abs(f.R-r.cA.R)+math.abs(f.G-r.cA.G)+math.abs(f.B-r.cA.B)
            if d<bd then bd,bi=d,r.id end
        end
        return bi
    end
    function SK.collectWeapons()
        local sc
        if IS_OLD then
            local gs=PGui:FindFirstChild("Guns Selections")
            sc=gs and safe(gs,"Guns","Body","Main","Scroll")
        else
            local ui=PGui:FindFirstChild("UI")
            sc=ui and safe(ui,"Container","Screen","Gun Selections","Guns","Body","Main","Frame","Scroll")
            if not sc then sc=ui and safe(ui,"Container","Screen","Gun Selections","Guns","Body","Main","Scroll") end
        end
        if not sc then return {} end
        local list={}
        for _,btn in ipairs(sc:GetChildren()) do
            if btn:IsA("ImageButton") or btn:IsA("TextButton") or btn:IsA("Frame") then
                local nO=btn:FindFirstChild("WeaponName") or btn:FindFirstChild("Name")
                local lO=btn:FindFirstChild("Locked")
                local wn=btn.Name
                if nO and (nO:IsA("TextLabel") or nO:IsA("TextButton")) and nO.Text~="" then wn=nO.Text end
                local lk=lO and ((lO:GetAttribute("Visible")==true) or lO.Visible) or false
                table.insert(list,{name=wn,locked=lk})
            end
        end
        table.sort(list,function(a,b) if a.locked~=b.locked then return not a.locked end return a.name:lower()<b.name:lower() end)
        return list
    end
    function SK.collectSkins()
        local fr
        if IS_OLD then
            local shop=PGui:FindFirstChild("GunSkinCrateShop")
            fr=shop and safe(shop,"Menu","Body","Main","Index","Frame")
        else
            local ui=PGui:FindFirstChild("UI")
            fr=ui and safe(ui,"Container","Screen","GunSkins","Menu","Body","Main","Index","Frame")
        end
        if not fr then return {} end
        local list={}
        for _,row in ipairs(fr:GetDescendants()) do
            if row:IsA("ImageButton") then
                local inO=row:FindFirstChild("ItemName")
                local aI=safe(row,"AnimateContainer","Icon")
                local rO=row:FindFirstChild("Rarity")
                local g=rO and rO:FindFirstChildWhichIsA("UIGradient")
                local dn=row.Name
                if inO and (inO:IsA("TextLabel") or inO:IsA("TextButton")) and inO.Text~="" then dn=inO.Text end
                local isAnim=false
                if aI then
                    local ai=aI.Image or ""
                    if ai~="" and ai~=PLACEHOLDER then isAnim=true end
                end
                local rid=rarityOf(g); local rd=RARS[rid]
                local rnames={"Common","Uncommon","Rare","Epic","Legendary","Exotic"}
                table.insert(list,{id=row.Name,displayName=dn,isAnimated=isAnim,cA=rd.cA,rarityName=rnames[rid] or "Skin"})
            end
        end
        return list
    end
    local function getAtt(name)
        local a=LP:FindFirstChild("Attachments")
        return a and a:FindFirstChild(name)
    end
    function SK.readWeapon(name)
        local wa,t=getAtt(name),{}
        for _,k in ipairs(ATTRS) do t[k]=wa and wa:GetAttribute(k) end
        return t
    end
    function SK.commitWeapon(name,pw)
        local wa=getAtt(name); if not wa then return false end
        wa:SetAttribute("Camo1",pw.Camo1 or nil)
        wa:SetAttribute("Camo2",pw.Camo2 or nil)
        local a1=pw.Camo1Animated; if a1==nil then a1=true end
        local a2=pw.Camo2Animated; if a2==nil then a2=true end
        wa:SetAttribute("Camo1Animated",a1 and true or false)
        wa:SetAttribute("Camo2Animated",a2 and true or false)
        wa:SetAttribute("Camo1Color",(pw.useColor1 and pw.Camo1Color) or nil)
        wa:SetAttribute("Camo2Color",(pw.useColor2 and pw.Camo2Color) or nil)
        return true
    end
    function SK.cfgSave()
        pcall(function()
            local atts=LP:FindFirstChild("Attachments"); if not atts then return end
            local data={}
            for _,wa in ipairs(atts:GetChildren()) do
                local entry,any={},false
                for _,k in ipairs(ATTRS) do
                    local v=wa:GetAttribute(k)
                    if v~=nil then any=true
                        if typeof(v)=="Color3" then entry[k]={_t="c3",r=v.R,g=v.G,b=v.B} else entry[k]=v end
                    end
                end
                if any then data[wa.Name]=entry end
            end
            writefile(CFG_FILE, HttpService:JSONEncode(data))
        end)
    end
    function SK.cfgLoad()
        pcall(function()
            if not isfile or not isfile(CFG_FILE) then return end
            local data=HttpService:JSONDecode(readfile(CFG_FILE))
            local atts=LP:FindFirstChild("Attachments"); if not atts then return end
            for wn,entry in pairs(data) do
                local wa=atts:FindFirstChild(wn)
                if wa then
                    for k,v in pairs(entry) do
                        if type(v)=="table" and v._t=="c3" then wa:SetAttribute(k,Color3.new(v.r,v.g,v.b))
                        elseif k=="Camo1Animated" or k=="Camo2Animated" then wa:SetAttribute(k,v and true or false)
                        else wa:SetAttribute(k,v) end
                    end
                end
            end
        end)
    end
    function SK.prerender()
        local targets={}
        if IS_OLD then
            targets={safe(PGui,"GunSkinCrateShop","Menu"), safe(PGui,"GunSkinCrateShop","Menu","Body","Main","Index")}
        else
            targets={
                safe(PGui,"UI","Container","Screen","GunSkins","Menu"),
                safe(PGui,"UI","Container","Screen","GunSkins","Menu","Body","Main","Index"),
                safe(PGui,"UI","Container","Screen","Gun Selections"),
            }
        end
        local orig={}
        for i,obj in ipairs(targets) do if obj then orig[i]=obj.Visible; obj.Visible=true end end
        task.wait(1)
        for i,obj in ipairs(targets) do if obj then obj.Visible=orig[i] end end
    end
    SK.weapons, SK.skinsList, SK.skinMap, SK.selWeapon, SK.pending = {},{},{},nil,{}
end

-- watermark
local wmGui = Instance.new("ScreenGui")
wmGui.Name, wmGui.ResetOnSpawn, wmGui.DisplayOrder, wmGui.IgnoreGuiInset = "SH_WM", false, 999998, true
wmGui.Parent = CoreGui
SH.wm = wmGui
local wm1 = Instance.new("Frame")
wm1.Size, wm1.Position = UDim2.new(0,200,0,58), UDim2.new(0,14,0,14)
wm1.BackgroundColor3, wm1.BackgroundTransparency, wm1.BorderSizePixel = Color3.fromRGB(16,16,22), 0.08, 0
wm1.Active, wm1.Parent = true, wmGui
Instance.new("UICorner", wm1).CornerRadius = UDim.new(0,12)
local wm1s = Instance.new("UIStroke", wm1)
wm1s.Color, wm1s.Thickness, wm1s.Transparency = Color3.fromRGB(90,130,255), 1.2, 0.3
local badge = Instance.new("Frame")
badge.Size, badge.Position = UDim2.new(0,42,0,42), UDim2.new(0,8,0.5,-21)
badge.BackgroundColor3, badge.BorderSizePixel, badge.Parent = Color3.fromRGB(90,130,255), 0, wm1
Instance.new("UICorner", badge).CornerRadius = UDim.new(0,10)
local badgeTxt = Instance.new("TextLabel")
badgeTxt.Size, badgeTxt.BackgroundTransparency = UDim2.new(1,0,1,0), 1
badgeTxt.Font, badgeTxt.TextSize, badgeTxt.TextColor3, badgeTxt.Text = Enum.Font.GothamBlack, 16, Color3.new(1,1,1), "SH"
badgeTxt.Parent = badge
local wm1Cfg = Instance.new("TextLabel")
wm1Cfg.Size, wm1Cfg.Position = UDim2.new(1,-60,0,18), UDim2.new(0,56,0,10)
wm1Cfg.BackgroundTransparency, wm1Cfg.Font, wm1Cfg.TextSize = 1, Enum.Font.GothamBold, 13
wm1Cfg.TextColor3, wm1Cfg.TextXAlignment, wm1Cfg.Text = Color3.fromRGB(220,220,240), Enum.TextXAlignment.Left, "default"
wm1Cfg.Parent = wm1
local wm1Stats = Instance.new("TextLabel")
wm1Stats.Size, wm1Stats.Position = UDim2.new(1,-60,0,16), UDim2.new(0,56,0,30)
wm1Stats.BackgroundTransparency, wm1Stats.Font, wm1Stats.TextSize = 1, Enum.Font.GothamMedium, 11
wm1Stats.TextColor3, wm1Stats.TextXAlignment, wm1Stats.Text = Color3.fromRGB(140,145,165), Enum.TextXAlignment.Left, "FPS --"
wm1Stats.Parent = wm1

local wm2 = Instance.new("Frame")
wm2.Size, wm2.Position = UDim2.new(0,0,0,28), UDim2.new(0,12,0,10)
wm2.BackgroundColor3, wm2.BackgroundTransparency, wm2.BorderSizePixel = Color3.fromRGB(14,14,20), 0.1, 0
wm2.Active, wm2.Visible, wm2.AutomaticSize = true, false, Enum.AutomaticSize.X
wm2.Parent = wmGui
Instance.new("UICorner", wm2).CornerRadius = UDim.new(0,8)
local wm2s = Instance.new("UIStroke", wm2)
wm2s.Color, wm2s.Thickness, wm2s.Transparency = Color3.fromRGB(90,130,255), 1, 0.35
local wm2Pad = Instance.new("UIPadding", wm2)
wm2Pad.PaddingLeft, wm2Pad.PaddingRight = UDim.new(0,10), UDim.new(0,10)
local wm2Text = Instance.new("TextLabel")
wm2Text.Size, wm2Text.AutomaticSize = UDim2.new(0,0,1,0), Enum.AutomaticSize.X
wm2Text.BackgroundTransparency, wm2Text.Font, wm2Text.TextSize = 1, Enum.Font.GothamBold, 12
wm2Text.TextColor3, wm2Text.Text = Color3.fromRGB(200,205,220), "SH"
wm2Text.Parent = wm2

local function makeDrag(frame)
    local drag,d0,p0=false,nil,nil
    frame.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag,d0,p0=true,i.Position,frame.Position end
    end)
    frame.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-d0
            frame.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X,p0.Y.Scale,p0.Y.Offset+d.Y)
        end
    end)
end
makeDrag(wm1); makeDrag(wm2)

local fpsN, fpsT, lastFPS = 0, tick(), 60
conn(RunService.RenderStepped:Connect(function()
    fpsN=fpsN+1
    local now=tick()
    if now-fpsT<0.4 then return end
    lastFPS=math.floor(fpsN/(now-fpsT)+0.5)
    fpsN,fpsT=0,now
    local ping=0
    pcall(function() ping=math.floor((LP:GetNetworkPing() or 0)*1000+0.5) end)
    local disp=LP.DisplayName or LP.Name
    local tstr=os.date("%H:%M")
    wm1.Visible = S.wmOn and S.wmStyle==1
    wm2.Visible = S.wmOn and S.wmStyle==2
    wm1Cfg.Text = tostring(S.cfgName)
    if S.wmStyle==1 then
        local parts={}
        if S.wmShowFPS then table.insert(parts,"FPS "..lastFPS) end
        if S.wmShowPing then table.insert(parts,"Ping "..ping) end
        wm1Stats.Text = table.concat(parts, "  ·  ")
    else
        local bits={"SH"}
        if S.wmShowFPS then table.insert(bits,"FPS "..lastFPS) end
        if S.wmShowPing then table.insert(bits,ping.." MS") end
        if S.wmShowTime then table.insert(bits,tstr) end
        if S.wmShowName then table.insert(bits,disp) end
        wm2Text.Text = table.concat(bits, "   ·   ")
    end
end))

-- ================= GUI =================
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "SummerHub", false, 999999
gui.Parent = CoreGui
SH.gui = gui

local scale = Instance.new("UIScale")
scale.Scale = uiScale
scale.Parent = gui

local BASE_W, BASE_H = 900, 560
local win = Instance.new("Frame")
win.Size, win.Position = UDim2.new(0, BASE_W, 0, BASE_H), UDim2.new(0.5, -BASE_W/2, 0.5, -BASE_H/2)
win.BackgroundColor3, win.BorderSizePixel, win.Active = T.bg, 0, true
win.Parent = gui
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 14)
local winStroke = Instance.new("UIStroke", win)
winStroke.Color, winStroke.Thickness, winStroke.Transparency = T.stroke, 1, 0.35

-- inject animation
win.BackgroundTransparency = 1
win.Size = UDim2.new(0, BASE_W*0.92, 0, BASE_H*0.92)
win.Position = UDim2.new(0.5, -BASE_W*0.46, 0.5, -BASE_H*0.46)
TweenService:Create(win, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Size = UDim2.new(0, BASE_W, 0, BASE_H),
    Position = UDim2.new(0.5, -BASE_W/2, 0.5, -BASE_H/2),
}):Play()

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size, sidebar.BackgroundColor3, sidebar.BorderSizePixel = UDim2.new(0, 190, 1, 0), T.sidebar, 0
sidebar.Parent = win
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)

-- logo area (prettier + bigger)
local logoWrap = Instance.new("Frame")
logoWrap.Size, logoWrap.Position = UDim2.new(1, -16, 0, 64), UDim2.new(0, 8, 0, 10)
logoWrap.BackgroundColor3, logoWrap.BorderSizePixel, logoWrap.Parent = T.card, 0, sidebar
Instance.new("UICorner", logoWrap).CornerRadius = UDim.new(0, 12)
local logoGrad = Instance.new("UIGradient")
logoGrad.Color = ColorSequence.new(T.card, T.panel)
logoGrad.Rotation = 90
logoGrad.Parent = logoWrap
local logoStroke = Instance.new("UIStroke")
logoStroke.Color, logoStroke.Thickness, logoStroke.Transparency = T.accent, 1, 0.55
logoStroke.Parent = logoWrap
local logoAccent = Instance.new("Frame")
logoAccent.Size, logoAccent.Position = UDim2.new(0, 4, 0.6, 0), UDim2.new(0, 0, 0.2, 0)
logoAccent.BackgroundColor3, logoAccent.BorderSizePixel, logoAccent.Parent = T.accent, 0, logoWrap
Instance.new("UICorner", logoAccent).CornerRadius = UDim.new(0, 3)
local logo = Instance.new("TextLabel")
logo.Size, logo.Position = UDim2.new(1, -20, 0, 28), UDim2.new(0, 16, 0, 8)
logo.BackgroundTransparency, logo.Font, logo.TextSize = 1, Enum.Font.GothamBlack, 20
logo.TextColor3, logo.TextXAlignment, logo.Text = T.accent2, Enum.TextXAlignment.Left, "SH Summer"
logo.Parent = logoWrap
local logoSub = Instance.new("TextLabel")
logoSub.Size, logoSub.Position = UDim2.new(1, -20, 0, 16), UDim2.new(0, 16, 0, 36)
logoSub.BackgroundTransparency, logoSub.Font, logoSub.TextSize = 1, Enum.Font.Gotham, 10
logoSub.TextColor3, logoSub.TextXAlignment, logoSub.Text = T.dim, Enum.TextXAlignment.Left, "visuals  ·  skins  ·  hub"
logoSub.Parent = logoWrap

-- config dropdown top of content (Neverlose-like)
local topBar = Instance.new("Frame")
topBar.Size, topBar.Position = UDim2.new(1, -206, 0, 36), UDim2.new(0, 198, 0, 10)
topBar.BackgroundTransparency, topBar.Parent = 1, win

-- Neverlose-style config selector
local cfgDrop = Instance.new("TextButton")
cfgDrop.Size, cfgDrop.Position = UDim2.new(0, 150, 0, 30), UDim2.new(0, 0, 0, 0)
cfgDrop.Text, cfgDrop.Font, cfgDrop.TextSize = S.cfgName.."  ▾", Enum.Font.GothamMedium, 12
cfgDrop.TextColor3, cfgDrop.TextXAlignment = T.text, Enum.TextXAlignment.Center
cfgDrop.BackgroundColor3, cfgDrop.BorderSizePixel, cfgDrop.Parent = T.card, 0, topBar
Instance.new("UICorner", cfgDrop).CornerRadius = UDim.new(0, 8)
local cfgDropStroke = Instance.new("UIStroke", cfgDrop)
cfgDropStroke.Color, cfgDropStroke.Transparency, cfgDropStroke.Thickness = T.stroke, 0.5, 1

local cfgListFrame = Instance.new("Frame")
cfgListFrame.Size, cfgListFrame.Position = UDim2.new(0, 220, 0, 0), UDim2.new(0, 0, 0, 34)
cfgListFrame.BackgroundColor3, cfgListFrame.BorderSizePixel, cfgListFrame.Visible = T.panel, 0, false
cfgListFrame.ZIndex, cfgListFrame.ClipsDescendants, cfgListFrame.Parent = 40, true, topBar
Instance.new("UICorner", cfgListFrame).CornerRadius = UDim.new(0, 10)
local cfgListStroke = Instance.new("UIStroke", cfgListFrame)
cfgListStroke.Color, cfgListStroke.Transparency = T.stroke, 0.4
local cfgListLay = Instance.new("UIListLayout", cfgListFrame)
cfgListLay.Padding = UDim.new(0, 3)
local cfgListPad = Instance.new("UIPadding", cfgListFrame)
cfgListPad.PaddingTop, cfgListPad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
cfgListPad.PaddingLeft, cfgListPad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)

local function setCfgDropText(name)
    cfgDrop.Text = tostring(name).."  ▾"
    S.cfgName = name
end

local function refreshCfgList()
    for _, ch in ipairs(cfgListFrame:GetChildren()) do
        if ch:IsA("TextButton") or ch:IsA("TextBox") or ch:IsA("TextLabel") or ch:IsA("Frame") then ch:Destroy() end
    end
    local list = listConfigs()
    local yCount = 0
    -- new config row
    local newRow = Instance.new("Frame")
    newRow.Size = UDim2.new(1, 0, 0, 30)
    newRow.BackgroundTransparency = 1
    newRow.ZIndex = 41
    newRow.Parent = cfgListFrame
    local newBox = Instance.new("TextBox")
    newBox.Size, newBox.Position = UDim2.new(0.62, 0, 1, 0), UDim2.new(0, 0, 0, 0)
    newBox.PlaceholderText, newBox.Text = "new name...", ""
    newBox.Font, newBox.TextSize, newBox.TextColor3 = Enum.Font.Gotham, 12, T.text
    newBox.BackgroundColor3, newBox.BorderSizePixel, newBox.ZIndex = T.card, 0, 42
    newBox.Parent = newRow
    Instance.new("UICorner", newBox).CornerRadius = UDim.new(0, 6)
    local saveNew = Instance.new("TextButton")
    saveNew.Size, saveNew.Position = UDim2.new(0.36, 0, 1, 0), UDim2.new(0.64, 0, 0, 0)
    saveNew.Text, saveNew.Font, saveNew.TextSize = "Save", Enum.Font.GothamBold, 12
    saveNew.TextColor3, saveNew.BackgroundColor3, saveNew.BorderSizePixel = Color3.new(1,1,1), T.accent, 0
    saveNew.ZIndex, saveNew.Parent = 42, newRow
    Instance.new("UICorner", saveNew).CornerRadius = UDim.new(0, 6)
    saveNew.MouseButton1Click:Connect(function()
        local n = newBox.Text:gsub("%s+", ""):gsub("[^%w_%-]", "_")
        if n == "" then n = "cfg"..tostring(os.time()%10000) end
        local ok = saveCfg(n)
        if ok then setCfgDropText(n) end
        refreshCfgList()
    end)
    yCount = yCount + 1
    if #list == 0 then table.insert(list, "default") end
    for _, name in ipairs(list) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundTransparency = 1
        row.ZIndex = 41
        row.Parent = cfgListFrame
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.7, 0, 1, 0)
        b.Text, b.Font, b.TextSize = "  "..name, Enum.Font.GothamMedium, 12
        b.TextColor3, b.TextXAlignment = T.text, Enum.TextXAlignment.Left
        b.BackgroundColor3 = (name == S.cfgName) and T.cardH or T.card
        b.BorderSizePixel, b.ZIndex, b.Parent = 0, 42, row
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function()
            loadCfg(name)
            setCfgDropText(name)
            cfgListFrame.Visible = false
            for _, f in ipairs(repaint) do pcall(f) end
        end)
        local sv = Instance.new("TextButton")
        sv.Size, sv.Position = UDim2.new(0, 36, 1, 0), UDim2.new(1, -108, 0, 0)
        sv.Text, sv.Font, sv.TextSize = "S", Enum.Font.GothamBold, 11
        sv.TextColor3, sv.BackgroundColor3, sv.BorderSizePixel = T.text, T.panel, 0
        sv.ZIndex, sv.Parent = 42, row
        Instance.new("UICorner", sv).CornerRadius = UDim.new(0, 6)
        sv.MouseButton1Click:Connect(function()
            saveCfg(name)
            setCfgDropText(name)
        end)
        local cp = Instance.new("TextButton")
        cp.Size, cp.Position = UDim2.new(0, 36, 1, 0), UDim2.new(1, -70, 0, 0)
        cp.Text, cp.Font, cp.TextSize = "C", Enum.Font.GothamBold, 11
        cp.TextColor3, cp.BackgroundColor3, cp.BorderSizePixel = T.text, T.panel, 0
        cp.ZIndex, cp.Parent = 42, row
        Instance.new("UICorner", cp).CornerRadius = UDim.new(0, 6)
        cp.MouseButton1Click:Connect(function()
            pcall(function()
                if isfile and isfile(CFG.."/"..name..".json") then
                    setclipboard(readfile(CFG.."/"..name..".json"))
                end
            end)
        end)
        local dl = Instance.new("TextButton")
        dl.Size, dl.Position = UDim2.new(0, 36, 1, 0), UDim2.new(1, -32, 0, 0)
        dl.Text, dl.Font, dl.TextSize = "X", Enum.Font.GothamBold, 11
        dl.TextColor3, dl.BackgroundColor3, dl.BorderSizePixel = Color3.new(1,0.4,0.4), T.panel, 0
        dl.ZIndex, dl.Parent = 42, row
        Instance.new("UICorner", dl).CornerRadius = UDim.new(0, 6)
        dl.MouseButton1Click:Connect(function()
            pcall(function()
                if delfile and isfile and isfile(CFG.."/"..name..".json") then
                    delfile(CFG.."/"..name..".json")
                end
            end)
            if S.cfgName == name then setCfgDropText("default") end
            refreshCfgList()
        end)
        b.Size = UDim2.new(1, -112, 1, 0)
        yCount = yCount + 1
    end
    -- autosave toggle row
    local asRow = Instance.new("TextButton")
    asRow.Size = UDim2.new(1, 0, 0, 28)
    asRow.Text = S.autoSave and "  Autosave: ON" or "  Autosave: OFF"
    asRow.Font, asRow.TextSize = Enum.Font.GothamMedium, 12
    asRow.TextColor3 = S.autoSave and T.green or T.dim
    asRow.TextXAlignment = Enum.TextXAlignment.Left
    asRow.BackgroundColor3, asRow.BorderSizePixel = T.card, 0
    asRow.ZIndex, asRow.Parent = 42, cfgListFrame
    Instance.new("UICorner", asRow).CornerRadius = UDim.new(0, 6)
    asRow.MouseButton1Click:Connect(function()
        S.autoSave = not S.autoSave
        asRow.Text = S.autoSave and "  Autosave: ON" or "  Autosave: OFF"
        asRow.TextColor3 = S.autoSave and T.green or T.dim
    end)
    yCount = yCount + 1
    cfgListFrame.Size = UDim2.new(0, 220, 0, yCount * 32 + 16)
end
cfgDrop.MouseButton1Click:Connect(function()
    cfgListFrame.Visible = not cfgListFrame.Visible
    if cfgListFrame.Visible then refreshCfgList() end
end)

local sideList = Instance.new("Frame")
sideList.Size, sideList.Position, sideList.BackgroundTransparency = UDim2.new(1,-12,1,-140), UDim2.new(0,6,0,84), 1
sideList.Parent = sidebar
local sideLay = Instance.new("UIListLayout", sideList)
sideLay.Padding = UDim.new(0, 3)

-- user bar with avatar + gear
local userBar = Instance.new("Frame")
userBar.Size, userBar.Position = UDim2.new(1,-16,0,48), UDim2.new(0,8,1,-56)
userBar.BackgroundColor3, userBar.BorderSizePixel, userBar.Parent = T.card, 0, sidebar
Instance.new("UICorner", userBar).CornerRadius = UDim.new(0, 10)

local avatar = Instance.new("ImageLabel")
avatar.Size, avatar.Position = UDim2.new(0, 34, 0, 34), UDim2.new(0, 7, 0.5, -17)
avatar.BackgroundColor3, avatar.BorderSizePixel, avatar.Parent = T.panel, 0, userBar
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
pcall(function()
    avatar.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
end)

local userLbl = Instance.new("TextLabel")
userLbl.Size, userLbl.Position = UDim2.new(1, -80, 0, 18), UDim2.new(0, 48, 0, 6)
userLbl.BackgroundTransparency, userLbl.Font, userLbl.TextSize = 1, Enum.Font.GothamBold, 12
userLbl.TextColor3, userLbl.TextXAlignment, userLbl.TextTruncate = T.text, Enum.TextXAlignment.Left, Enum.TextTruncate.AtEnd
userLbl.Text = LP.DisplayName or LP.Name
userLbl.Parent = userBar
local uidLbl = Instance.new("TextLabel")
uidLbl.Size, uidLbl.Position = UDim2.new(1, -80, 0, 14), UDim2.new(0, 48, 0, 26)
uidLbl.BackgroundTransparency, uidLbl.Font, uidLbl.TextSize = 1, Enum.Font.Gotham, 10
uidLbl.TextColor3, uidLbl.TextXAlignment = T.dim, Enum.TextXAlignment.Left
uidLbl.Text = "UID "..MY_UID
uidLbl.Parent = userBar

local gearBtn = Instance.new("TextButton")
gearBtn.Size, gearBtn.Position = UDim2.new(0, 28, 0, 28), UDim2.new(1, -34, 0.5, -14)
gearBtn.Text, gearBtn.Font, gearBtn.TextSize = "⚙", Enum.Font.GothamBold, 16
gearBtn.TextColor3, gearBtn.BackgroundColor3, gearBtn.BorderSizePixel = T.dim, T.panel, 0
gearBtn.Parent = userBar
Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0, 7)

-- settings popup (theme / scale / custom)
local settingsPop = Instance.new("Frame")
settingsPop.Size, settingsPop.Position = UDim2.new(0, 260, 0, 400), UDim2.new(0, 200, 1, -420)
settingsPop.BackgroundColor3, settingsPop.BorderSizePixel, settingsPop.Visible, settingsPop.ZIndex = T.panel, 0, false, 30
settingsPop.Parent = win
Instance.new("UICorner", settingsPop).CornerRadius = UDim.new(0, 12)
local setStroke = Instance.new("UIStroke", settingsPop)
setStroke.Color, setStroke.Transparency = T.stroke, 0.4
local setTitle = Instance.new("TextLabel")
setTitle.Size, setTitle.Position = UDim2.new(1,-16,0,24), UDim2.new(0,12,0,8)
setTitle.BackgroundTransparency, setTitle.Font, setTitle.TextSize = 1, Enum.Font.GothamBold, 14
setTitle.TextColor3, setTitle.TextXAlignment, setTitle.Text = T.accent2, Enum.TextXAlignment.Left, "Settings"
setTitle.ZIndex, setTitle.Parent = 31, settingsPop

gearBtn.MouseButton1Click:Connect(function()
    if settingsPop.Visible then
        TweenService:Create(settingsPop, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 240, 0, 360)
        }):Play()
        task.delay(0.18, function()
            settingsPop.Visible = false
            settingsPop.BackgroundTransparency = 0
            settingsPop.Size = UDim2.new(0, 260, 0, 400)
        end)
    else
        settingsPop.Visible = true
        settingsPop.BackgroundTransparency = 1
        settingsPop.Size = UDim2.new(0, 240, 0, 360)
        TweenService:Create(settingsPop, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 260, 0, 400)
        }):Play()
    end
end)

-- content
local content = Instance.new("Frame")
content.Size, content.Position = UDim2.new(1, -206, 1, -56), UDim2.new(0, 198, 0, 48)
content.BackgroundTransparency, content.Parent = 1, win

local pages, tabBtns, repaint, themePaintFns = {}, {}, {}, {}
local currentPage = "Visuals"
local visSub = "Glass" -- Glass | Tracers | World

local function showPage(name)
    currentPage = name
    if setVisSubsOpen then setVisSubsOpen(name == "Visuals") end
    for n, pg in pairs(pages) do
        if n == name then
            pg.Visible = true
            pg.CanvasPosition = Vector2.new(0, 0)
            for _, ch in ipairs(pg:GetChildren()) do
                if ch:IsA("GuiObject") and ch.Name ~= "UIListLayout" then
                    local o = ch.BackgroundTransparency
                    if ch:IsA("ScrollingFrame") then
                        -- skip
                    else
                        ch.BackgroundTransparency = math.min(1, (ch.BackgroundTransparency or 0) + 0.3)
                        TweenService:Create(ch, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundTransparency = o
                        }):Play()
                    end
                end
            end
        else
            pg.Visible = false
        end
    end
    for n, b in pairs(tabBtns) do
        local active = (n == name)
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundTransparency = active and 0 or 1,
            TextColor3 = active and T.accent2 or T.dim
        }):Play()
        b.BackgroundColor3 = T.card
        local ind = b:FindFirstChild("Ind")
        if ind then
            ind.Visible = active
            ind.BackgroundColor3 = T.accent
            if active then
                ind.Size = UDim2.new(0, 3, 0, 0)
                TweenService:Create(ind, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 3, 0.5, 0),
                    Position = UDim2.new(0, 0, 0.25, 0)
                }):Play()
            end
        end
    end
    for _, f in ipairs(repaint) do pcall(f) end
end

-- tabs: Visuals (with sub), Skins, Player, Main — Tracers/World as sub of Visuals
local tabOrder = {
    {name="Visuals", icon="◈"},
    {name="Skins", icon="◇"},
    {name="Player", icon="○"},
    {name="Main", icon="▣"},
}

for _, td in ipairs(tabOrder) do
    local b = Instance.new("TextButton")
    b.Size, b.Text = UDim2.new(1,0,0,34), "  "..td.icon.."  "..td.name
    b.Font, b.TextSize, b.TextXAlignment = Enum.Font.GothamMedium, 13, Enum.TextXAlignment.Left
    b.BackgroundColor3, b.BackgroundTransparency, b.TextColor3, b.BorderSizePixel = T.card, 1, T.dim, 0
    b.Parent = sideList
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local ind = Instance.new("Frame")
    ind.Name, ind.Size, ind.Position = "Ind", UDim2.new(0,3,0.5,-8), UDim2.new(0,0,0.5,0)
    ind.BackgroundColor3, ind.BorderSizePixel, ind.Visible, ind.Parent = T.accent, 0, false, b
    Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 2)
    tabBtns[td.name] = b

    local page = Instance.new("ScrollingFrame")
    page.Size, page.BackgroundTransparency, page.BorderSizePixel = UDim2.new(1,0,1,0), 1, 0
    page.ScrollBarThickness, page.ScrollBarImageColor3 = 3, T.accent
    page.CanvasSize, page.Visible, page.Parent = UDim2.new(0,0,0,600), false, content
    pages[td.name] = page
    b.MouseButton1Click:Connect(function() showPage(td.name) end)
end

-- Visuals internal pages with TOP sub-tabs
local visPages = {}
local visSubBtns = {}
do
    local subBar = Instance.new("Frame")
    subBar.Size, subBar.Position, subBar.BackgroundTransparency = UDim2.new(1, 0, 0, 34), UDim2.new(0, 0, 0, 0), 1
    subBar.Parent = pages.Visuals
    local subLay = Instance.new("UIListLayout", subBar)
    subLay.FillDirection, subLay.Padding = Enum.FillDirection.Horizontal, UDim.new(0, 6)

    for _, sub in ipairs({"Glass", "Tracers", "World"}) do
        local pg = Instance.new("ScrollingFrame")
        pg.Size, pg.Position = UDim2.new(1, 0, 1, -40), UDim2.new(0, 0, 0, 40)
        pg.BackgroundTransparency, pg.BorderSizePixel = 1, 0
        pg.ScrollBarThickness, pg.ScrollBarImageColor3 = 3, T.accent
        pg.CanvasSize, pg.Visible, pg.Parent = UDim2.new(0, 0, 0, 500), false, pages.Visuals
        visPages[sub] = pg

        local b = Instance.new("TextButton")
        b.Size, b.Text = UDim2.new(0, 100, 0, 30), sub
        b.Font, b.TextSize = Enum.Font.GothamMedium, 12
        b.BackgroundColor3, b.TextColor3, b.BorderSizePixel = T.card, T.dim, 0
        b.Parent = subBar
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
        visSubBtns[sub] = b
        b.MouseButton1Click:Connect(function()
            visSub = sub
            for n, pg2 in pairs(visPages) do pg2.Visible = (n == sub) end
            for n, btn in pairs(visSubBtns) do
                local on = (n == sub)
                btn.BackgroundColor3 = on and T.accent or T.card
                btn.TextColor3 = on and Color3.new(1, 1, 1) or T.dim
            end
        end)
    end
    visPages.Glass.Visible = true
    visSubBtns.Glass.BackgroundColor3 = T.accent
    visSubBtns.Glass.TextColor3 = Color3.new(1, 1, 1)
end

local function setVisSubsOpen(open)
    -- no-op (subs are always visible on Visuals page)
end

-- drag
do
    local drag,d0,p0=false,nil,nil
    logoWrap.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag,d0,p0=true,i.Position,win.Position end
    end)
    logoWrap.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-d0
            win.Position=UDim2.new(p0.X.Scale,p0.X.Offset+d.X,p0.Y.Scale,p0.Y.Offset+d.Y)
        end
    end)
end

local function section(parent, title, x, y, w, h)
    local card = Instance.new("Frame")
    card.Size, card.Position = UDim2.new(0,w,0,h), UDim2.new(0,x,0,y)
    card.BackgroundColor3, card.BorderSizePixel, card.Parent = T.panel, 0, parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
    local st = Instance.new("UIStroke", card)
    st.Color, st.Thickness, st.Transparency = T.stroke, 1, 0.5
    local hdr = Instance.new("TextLabel")
    hdr.Size, hdr.Position = UDim2.new(1,-16,0,22), UDim2.new(0,12,0,8)
    hdr.BackgroundTransparency, hdr.Font, hdr.TextSize = 1, Enum.Font.GothamBold, 11
    hdr.TextColor3, hdr.TextXAlignment, hdr.Text = T.dim, Enum.TextXAlignment.Left, string.upper(title)
    hdr.Parent = card
    table.insert(themePaintFns, function()
        card.BackgroundColor3=T.panel; st.Color=T.stroke; hdr.TextColor3=T.dim
    end)
    return card
end

local function mkToggle(parent, y, label, get, set)
    local row = Instance.new("Frame")
    row.Size, row.Position, row.BackgroundTransparency = UDim2.new(1,-20,0,28), UDim2.new(0,10,0,y), 1
    row.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size, l.BackgroundTransparency = UDim2.new(0.7,0,1,0), 1
    l.Font, l.TextSize, l.TextColor3 = Enum.Font.Gotham, 13, T.text
    l.TextXAlignment, l.Text, l.Parent = Enum.TextXAlignment.Left, label, row
    local b = Instance.new("TextButton")
    b.Size, b.Position, b.Text, b.BorderSizePixel = UDim2.new(0,40,0,20), UDim2.new(1,-40,0.5,-10), "", 0
    b.Parent = row
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame")
    dot.Size, dot.BackgroundColor3, dot.BorderSizePixel = UDim2.new(0,14,0,14), Color3.new(1,1,1), 0
    dot.Parent = b
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local function paint()
        local on=get()
        b.BackgroundColor3 = on and T.toggleOn or T.toggleOff
        dot.Position = on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        l.TextColor3 = T.text
    end
    paint()
    b.MouseButton1Click:Connect(function() set(not get()); paint(); hardRefresh(); applyWorld() end)
    table.insert(themePaintFns, paint)
    return paint
end

local function mkSlider(parent, y, label, min, max, dec, get, set)
    local wrap = Instance.new("Frame")
    wrap.Size, wrap.Position, wrap.BackgroundTransparency = UDim2.new(1,-20,0,40), UDim2.new(0,10,0,y), 1
    wrap.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size, l.BackgroundTransparency = UDim2.new(0.6,0,0,14), 1
    l.Font, l.TextSize, l.TextColor3 = Enum.Font.Gotham, 12, T.dim
    l.TextXAlignment, l.Text, l.Parent = Enum.TextXAlignment.Left, label, wrap
    local vlab = Instance.new("TextLabel")
    vlab.Size, vlab.Position, vlab.BackgroundTransparency = UDim2.new(0.35,0,0,14), UDim2.new(0.6,0,0,0), 1
    vlab.Font, vlab.TextSize, vlab.TextColor3 = Enum.Font.GothamBold, 12, T.text
    vlab.TextXAlignment, vlab.Parent = Enum.TextXAlignment.Right, wrap
    local track = Instance.new("Frame")
    track.Size, track.Position = UDim2.new(1,0,0,5), UDim2.new(0,0,0,24)
    track.BackgroundColor3, track.BorderSizePixel, track.Parent = T.track, 0, wrap
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame")
    fill.BackgroundColor3, fill.BorderSizePixel, fill.Parent = T.fill, 0, track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("TextButton")
    knob.Size, knob.BackgroundColor3, knob.Text, knob.BorderSizePixel = UDim2.new(0,12,0,12), Color3.new(1,1,1), "", 0
    knob.ZIndex, knob.Parent = 2, track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local drag=false
    local function paint()
        local val=get()
        local f=math.clamp((val-min)/(max-min),0,1)
        fill.Size=UDim2.new(f,0,1,0)
        knob.Position=UDim2.new(f,-6,0.5,-6)
        vlab.Text=string.format("%."..dec.."f", val)
        l.TextColor3,vlab.TextColor3=T.dim,T.text
        track.BackgroundColor3,fill.BackgroundColor3=T.track,T.fill
    end
    local function setF(f)
        f=math.clamp(f,0,1)
        local val=min+(max-min)*f
        if dec==0 then val=math.floor(val+0.5) end
        set(val); paint(); applyWorld()
    end
    paint()
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            setF((i.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1)); drag=true
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            setF((i.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1))
        end
    end)
    table.insert(themePaintFns, paint)
    return paint
end

local function mkBtn(parent, y, text, fn)
    local b = Instance.new("TextButton")
    b.Size, b.Position = UDim2.new(1,-20,0,30), UDim2.new(0,10,0,y)
    b.Text, b.Font, b.TextSize = text, Enum.Font.GothamMedium, 12
    b.TextColor3, b.BackgroundColor3, b.BorderSizePixel = T.text, T.card, 0
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)
    b.MouseEnter:Connect(function() b.BackgroundColor3=T.cardH end)
    b.MouseLeave:Connect(function() b.BackgroundColor3=T.card end)
    b.MouseButton1Click:Connect(fn)
    table.insert(themePaintFns, function() b.BackgroundColor3=T.card; b.TextColor3=T.text end)
    return b
end

local function mkColorBtn(parent, y, label, get, set)
    local row = Instance.new("Frame")
    row.Size, row.Position, row.BackgroundTransparency = UDim2.new(1,-20,0,28), UDim2.new(0,10,0,y), 1
    row.Parent = parent
    local l = Instance.new("TextLabel")
    l.Size, l.BackgroundTransparency = UDim2.new(0.55,0,1,0), 1
    l.Font, l.TextSize, l.TextColor3 = Enum.Font.Gotham, 13, T.text
    l.TextXAlignment, l.Text, l.Parent = Enum.TextXAlignment.Left, label, row
    local b = Instance.new("TextButton")
    b.Size, b.Position = UDim2.new(0,90,0,22), UDim2.new(1,-90,0.5,-11)
    b.Text, b.Font, b.TextSize = "  Color", Enum.Font.GothamBold, 11
    b.TextColor3, b.TextXAlignment, b.BackgroundColor3 = T.text, Enum.TextXAlignment.Left, get()
    b.BorderSizePixel, b.Parent = 0, row
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    local presets = {
        Color3.fromRGB(255,255,255), Color3.fromRGB(255,40,40), Color3.fromRGB(255,140,40),
        Color3.fromRGB(255,220,40), Color3.fromRGB(50,255,90), Color3.fromRGB(40,200,255),
        Color3.fromRGB(90,90,255), Color3.fromRGB(200,50,255), Color3.fromRGB(255,80,160),
    }
    b.MouseButton1Click:Connect(function()
        local cur=get(); local idx=1
        for i,c in ipairs(presets) do
            if math.abs(c.R-cur.R)+math.abs(c.G-cur.G)+math.abs(c.B-cur.B)<0.05 then idx=i%#presets+1 break end
        end
        set(presets[idx]); b.BackgroundColor3=presets[idx]; hardRefresh()
    end)
    return function() b.BackgroundColor3=get() end
end

local function applyTheme(name)
    if not Themes[name] then return end
    themeName = name
    for k,v in pairs(Themes[name]) do T[k]=v end
    win.BackgroundColor3=T.bg
    sidebar.BackgroundColor3=T.sidebar
    winStroke.Color=T.stroke
    logoWrap.BackgroundColor3=T.card
    logoAccent.BackgroundColor3=T.accent
    logo.TextColor3=T.accent2
    if logoSub then logoSub.TextColor3=T.dim end
    if logoStroke then logoStroke.Color=T.accent end
    if logoGrad then logoGrad.Color = ColorSequence.new(T.card, T.panel) end
    userBar.BackgroundColor3=T.card
    userLbl.TextColor3=T.text
    uidLbl.TextColor3=T.dim
    gearBtn.TextColor3=T.dim
    gearBtn.BackgroundColor3=T.panel
    avatar.BackgroundColor3=T.panel
    settingsPop.BackgroundColor3=T.panel
    setStroke.Color=T.stroke
    setTitle.TextColor3=T.accent2
    cfgDrop.BackgroundColor3=T.card
    cfgDrop.TextColor3=T.text
    if cfgDropStroke then cfgDropStroke.Color=T.stroke end
    wm1s.Color=T.accent
    wm2s.Color=T.accent
    badge.BackgroundColor3=T.accent
    for _,f in ipairs(themePaintFns) do pcall(f) end
    showPage(currentPage)
end

-- SETTINGS POP content
do
    local y = 36
    local lab = Instance.new("TextLabel")
    lab.Size, lab.Position = UDim2.new(1,-20,0,16), UDim2.new(0,10,0,y)
    lab.BackgroundTransparency, lab.Font, lab.TextSize = 1, Enum.Font.GothamBold, 11
    lab.TextColor3, lab.TextXAlignment, lab.Text = T.dim, Enum.TextXAlignment.Left, "THEME"
    lab.ZIndex, lab.Parent = 31, settingsPop
    y = y + 20
    for _, tn in ipairs({"Neverlose","Summer","Midnight","Ocean","Crimson","Light","Custom"}) do
        local b = Instance.new("TextButton")
        b.Size, b.Position = UDim2.new(1,-20,0,26), UDim2.new(0,10,0,y)
        b.Text, b.Font, b.TextSize = tn, Enum.Font.GothamMedium, 12
        b.TextColor3, b.BackgroundColor3, b.BorderSizePixel = T.text, T.card, 0
        b.ZIndex, b.Parent = 31, settingsPop
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function() applyTheme(tn) end)
        y = y + 30
    end
    y = y + 6
    local lab2 = Instance.new("TextLabel")
    lab2.Size, lab2.Position = UDim2.new(1,-20,0,16), UDim2.new(0,10,0,y)
    lab2.BackgroundTransparency, lab2.Font, lab2.TextSize = 1, Enum.Font.GothamBold, 11
    lab2.TextColor3, lab2.TextXAlignment, lab2.Text = T.dim, Enum.TextXAlignment.Left, "UI SCALE"
    lab2.ZIndex, lab2.Parent = 31, settingsPop
    y = y + 22
    local scaleLbl = Instance.new("TextLabel")
    scaleLbl.Size, scaleLbl.Position = UDim2.new(1,-20,0,16), UDim2.new(0,10,0,y)
    scaleLbl.BackgroundTransparency, scaleLbl.Font, scaleLbl.TextSize = 1, Enum.Font.Gotham, 12
    scaleLbl.TextColor3, scaleLbl.Text = T.text, string.format("%.2f", uiScale)
    scaleLbl.ZIndex, scaleLbl.Parent = 31, settingsPop
    y = y + 20
    local row = Instance.new("Frame")
    row.Size, row.Position, row.BackgroundTransparency = UDim2.new(1,-20,0,28), UDim2.new(0,10,0,y), 1
    row.ZIndex, row.Parent = 31, settingsPop
    for i, delta in ipairs({-0.1, 0.1}) do
        local b = Instance.new("TextButton")
        b.Size, b.Position = UDim2.new(0.48,0,1,0), UDim2.new(i==1 and 0 or 0.52, 0, 0, 0)
        b.Text = i==1 and "−" or "+"
        b.Font, b.TextSize = Enum.Font.GothamBold, 16
        b.TextColor3, b.BackgroundColor3, b.BorderSizePixel = T.text, T.card, 0
        b.ZIndex, b.Parent = 32, row
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function()
            uiScale = math.clamp(uiScale + delta, 0.75, 1.35)
            TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Scale = uiScale
            }):Play()
            scaleLbl.Text = string.format("%.2f", uiScale)
        end)
    end
    y = y + 40
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size, unloadBtn.Position = UDim2.new(1, -20, 0, 32), UDim2.new(0, 10, 0, y)
    unloadBtn.Text, unloadBtn.Font, unloadBtn.TextSize = "Unload Script", Enum.Font.GothamBold, 13
    unloadBtn.TextColor3, unloadBtn.BackgroundColor3, unloadBtn.BorderSizePixel = Color3.new(1,1,1), Color3.fromRGB(180, 50, 60), 0
    unloadBtn.ZIndex, unloadBtn.Parent = 31, settingsPop
    Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 8)
    unloadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            for _, c in pairs(SH.conns) do pcall(function() c:Disconnect() end) end
            if SH.gui then SH.gui:Destroy() end
            if SH.tracers then SH.tracers:Destroy() end
            if SH.cc then SH.cc:Destroy() end
            if SH.wm then SH.wm:Destroy() end
            if SH.slotGui then SH.slotGui:Destroy() end
            if killGui then killGui:Destroy() end
        end)
        _G.SH = nil
        print("[SummerHub] unloaded")
    end)
end

-- GLASS sub
do
    local p = visPages.Glass
    p.CanvasSize = UDim2.new(0,0,0,400)
    local left = section(p, "Arms / Body", 0, 0, 320, 250)
    repaint[#repaint+1]=mkToggle(left,32,"Arms glass",function() return S.armOn end,function(v) S.armOn=v end)
    repaint[#repaint+1]=mkSlider(left,64,"Arms amount",0,1,2,function() return S.armT end,function(v) S.armT=v end)
    repaint[#repaint+1]=mkToggle(left,112,"Arms color",function() return S.armColorOn end,function(v) S.armColorOn=v end)
    repaint[#repaint+1]=mkColorBtn(left,144,"Arms color",function() return S.armCol end,function(c) S.armCol=c; S.armColorOn=true end)
    repaint[#repaint+1]=mkToggle(left,180,"Body glass",function() return S.bodyOn end,function(v) S.bodyOn=v end)
    repaint[#repaint+1]=mkSlider(left,212,"Body amount",0,1,2,function() return S.bodyT end,function(v) S.bodyT=v end)
    local right = section(p, "Gun / Shield (+ lenses)", 336, 0, 320, 340)
    repaint[#repaint+1]=mkToggle(right,32,"Gun glass",function() return S.gunOn end,function(v) S.gunOn=v end)
    repaint[#repaint+1]=mkSlider(right,64,"Gun amount",0,1,2,function() return S.gunT end,function(v) S.gunT=v end)
    repaint[#repaint+1]=mkToggle(right,112,"Gun color",function() return S.gunColorOn end,function(v) S.gunColorOn=v end)
    repaint[#repaint+1]=mkColorBtn(right,144,"Gun color",function() return S.gunCol end,function(c) S.gunCol=c; S.gunColorOn=true end)
    repaint[#repaint+1]=mkToggle(right,184,"Shield glass",function() return S.shieldOn end,function(v) S.shieldOn=v end)
    repaint[#repaint+1]=mkSlider(right,216,"Shield amount",0,1,2,function() return S.shieldT end,function(v) S.shieldT=v end)
    repaint[#repaint+1]=mkToggle(right,264,"Shield color",function() return S.shieldColorOn end,function(v) S.shieldColorOn=v end)
    repaint[#repaint+1]=mkColorBtn(right,296,"Shield color",function() return S.shieldCol end,function(c) S.shieldCol=c; S.shieldColorOn=true end)
end

do
    local p = visPages.Tracers
    p.CanvasSize = UDim2.new(0,0,0,280)
    local card = section(p, "Tracers", 0, 0, 420, 250)
    repaint[#repaint+1]=mkToggle(card,32,"Enabled",function() return S.tracers end,function(v) S.tracers=v end)
    repaint[#repaint+1]=mkToggle(card,64,"Rainbow",function() return S.rainbowTr end,function(v) S.rainbowTr=v end)
    repaint[#repaint+1]=mkSlider(card,96,"Thickness",0.02,0.5,2,function() return S.thick end,function(v) S.thick=v end)
    repaint[#repaint+1]=mkSlider(card,144,"Lifetime",0.1,3,2,function() return S.life end,function(v) S.life=v end)
    repaint[#repaint+1]=mkColorBtn(card,196,"Color",function() return S.trCol end,function(c) S.trCol=c; S.rainbowTr=false end)
end

do
    local p = visPages.World
    p.CanvasSize = UDim2.new(0,0,0,420)
    local card = section(p, "World Color", 0, 0, 420, 260)
    repaint[#repaint+1]=mkToggle(card,32,"Enabled",function() return S.worldOn end,function(v) S.worldOn=v end)
    repaint[#repaint+1]=mkColorBtn(card,64,"Tint",function() return S.worldCol end,function(c) S.worldCol=c; S.worldOn=true end)
    repaint[#repaint+1]=mkSlider(card,96,"Tint strength",0,1,2,function() return S.worldTint end,function(v) S.worldTint=v end)
    repaint[#repaint+1]=mkSlider(card,144,"Brightness",-0.5,0.5,2,function() return S.worldBright end,function(v) S.worldBright=v end)
    repaint[#repaint+1]=mkSlider(card,192,"Contrast",-0.5,0.5,2,function() return S.worldContrast end,function(v) S.worldContrast=v end)
    repaint[#repaint+1]=mkSlider(card,240,"Saturation",-0.5,1,2,function() return S.worldSat end,function(v) S.worldSat=v end)
    local timeCard = section(p, "Time of Day", 0, 276, 420, 120)
    repaint[#repaint+1]=mkToggle(timeCard,32,"Lock time",function() return S.timeOn end,function(v) S.timeOn=v; if v then Lighting.ClockTime=S.timeOfDay end end)
    repaint[#repaint+1]=mkSlider(timeCard,64,"Clock (0-24)",0,24,1,function() return S.timeOfDay end,function(v) S.timeOfDay=v; if S.timeOn then Lighting.ClockTime=v end end)
    local killCard = section(p, "Kill Effect", 436, 0, 220, 140)
    repaint[#repaint+1]=mkToggle(killCard,32,"Enabled",function() return S.killFx end,function(v) S.killFx=v end)
    repaint[#repaint+1]=mkColorBtn(killCard,64,"FX color",function() return S.killFxColor end,function(c) S.killFxColor=c end)
    mkBtn(killCard, 100, "Test effect", function() playKillFX() end)
end

-- SKINS
do
    local p = pages.Skins
    p.CanvasSize = UDim2.new(0,0,0,500)
    local skHeader = Instance.new("Frame")
    skHeader.Size, skHeader.Position = UDim2.new(1, -8, 0, 36), UDim2.new(0, 4, 0, 0)
    skHeader.BackgroundColor3, skHeader.BorderSizePixel, skHeader.Parent = T.panel, 0, p
    Instance.new("UICorner", skHeader).CornerRadius = UDim.new(0, 8)
    local status = Instance.new("TextLabel")
    status.Size, status.Position = UDim2.new(1,-16,1,0), UDim2.new(0,12,0,0)
    status.BackgroundTransparency, status.Font, status.TextSize = 1, Enum.Font.GothamMedium, 12
    status.TextColor3, status.TextXAlignment, status.Text, status.Parent = T.dim, Enum.TextXAlignment.Left, "Open gun skins menu, then Reload", skHeader
    local wSearch = Instance.new("TextBox")
    wSearch.Size, wSearch.Position = UDim2.new(0.48,-8,0,30), UDim2.new(0,4,0,44)
    wSearch.PlaceholderText, wSearch.Text = "Weapon...", ""
    wSearch.Font, wSearch.TextSize, wSearch.TextColor3 = Enum.Font.Gotham, 12, T.text
    wSearch.BackgroundColor3, wSearch.BorderSizePixel, wSearch.Parent = T.card, 0, p
    Instance.new("UICorner", wSearch).CornerRadius = UDim.new(0,6)
    local sSearch = Instance.new("TextBox")
    sSearch.Size, sSearch.Position = UDim2.new(0.48,-8,0,30), UDim2.new(0.52,0,0,44)
    sSearch.PlaceholderText, sSearch.Text = "Skin...", ""
    sSearch.Font, sSearch.TextSize, sSearch.TextColor3 = Enum.Font.Gotham, 12, T.text
    sSearch.BackgroundColor3, sSearch.BorderSizePixel, sSearch.Parent = T.card, 0, p
    Instance.new("UICorner", sSearch).CornerRadius = UDim.new(0,6)
    local wScroll = Instance.new("ScrollingFrame")
    wScroll.Size, wScroll.Position = UDim2.new(0.48,-8,0,250), UDim2.new(0,4,0,82)
    wScroll.BackgroundColor3, wScroll.BorderSizePixel, wScroll.ScrollBarThickness = T.panel, 0, 3
    wScroll.CanvasSize, wScroll.Parent = UDim2.new(0,0,0,0), p
    Instance.new("UICorner", wScroll).CornerRadius = UDim.new(0,8)
    Instance.new("UIListLayout", wScroll).Padding = UDim.new(0,3)
    local sScroll = Instance.new("ScrollingFrame")
    sScroll.Size, sScroll.Position = UDim2.new(0.48,-8,0,250), UDim2.new(0.52,0,0,82)
    sScroll.BackgroundColor3, sScroll.BorderSizePixel, sScroll.ScrollBarThickness = T.panel, 0, 3
    sScroll.CanvasSize, sScroll.Parent = UDim2.new(0,0,0,0), p
    Instance.new("UICorner", sScroll).CornerRadius = UDim.new(0,8)
    Instance.new("UIListLayout", sScroll).Padding = UDim.new(0,3)
    local info = Instance.new("TextLabel")
    info.Size, info.Position = UDim2.new(1,-8,0,28), UDim2.new(0,4,0,340)
    info.BackgroundTransparency, info.Font, info.TextSize = 1, Enum.Font.Gotham, 12
    info.TextColor3, info.TextXAlignment, info.Text = T.text, Enum.TextXAlignment.Left, "LMB Primary · RMB Secondary"
    info.Parent = p
    local function clearC(sc) for _,ch in ipairs(sc:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end end
    local function updInfo()
        local w=SK.selWeapon
        if not w then info.Text="LMB Primary · RMB Secondary" return end
        local s1=SK.pending.Camo1 and SK.skinMap[SK.pending.Camo1]
        local s2=SK.pending.Camo2 and SK.skinMap[SK.pending.Camo2]
        info.Text=string.format("%s | P: %s | S: %s", w.name, s1 and s1.displayName or "-", s2 and s2.displayName or "-")
    end
    local function renderW(filt)
        clearC(wScroll); filt=(filt or ""):lower(); local y=0
        for _,w in ipairs(SK.weapons) do
            if filt=="" or w.name:lower():find(filt,1,true) then
                local row=Instance.new("TextButton")
                row.Size=UDim2.new(1,-6,0,28)
                row.BackgroundColor3=(SK.selWeapon and SK.selWeapon.name==w.name) and T.cardH or T.card
                row.Text="  "..w.name..(w.locked and " [L]" or "")
                row.Font, row.TextSize, row.TextColor3 = Enum.Font.GothamMedium, 12, w.locked and T.dim or T.text
                row.TextXAlignment, row.BorderSizePixel, row.Parent = Enum.TextXAlignment.Left, 0, wScroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0,5)
                if not w.locked then
                    row.MouseButton1Click:Connect(function()
                        SK.selWeapon=w
                        local ws=SK.readWeapon(w.name)
                        local a1=ws.Camo1Animated; if a1==nil then a1=true end
                        local a2=ws.Camo2Animated; if a2==nil then a2=true end
                        SK.pending={Camo1=ws.Camo1,Camo2=ws.Camo2,Camo1Animated=a1,Camo2Animated=a2,Camo1Color=ws.Camo1Color,Camo2Color=ws.Camo2Color,useColor1=ws.Camo1Color~=nil,useColor2=ws.Camo2Color~=nil}
                        updInfo(); renderW(wSearch.Text)
                    end)
                end
                y=y+31
            end
        end
        wScroll.CanvasSize=UDim2.new(0,0,0,y+4)
    end
    local function renderS(filt)
        clearC(sScroll); filt=(filt or ""):lower(); local y=0
        for _,sk in ipairs(SK.skinsList) do
            if filt=="" or sk.displayName:lower():find(filt,1,true) then
                local is1,is2=SK.pending.Camo1==sk.id, SK.pending.Camo2==sk.id
                local row=Instance.new("TextButton")
                row.Size=UDim2.new(1,-6,0,36)
                row.BackgroundColor3=is1 and T.cardH or (is2 and Color3.fromRGB(40,50,30) or T.card)
                row.Text=""
                row.BorderSizePixel, row.Parent = 0, sScroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
                local nm = Instance.new("TextLabel")
                nm.Size, nm.Position = UDim2.new(1,-8,0,18), UDim2.new(0,8,0,2)
                nm.BackgroundTransparency, nm.Font, nm.TextSize = 1, Enum.Font.GothamMedium, 12
                nm.TextColor3, nm.TextXAlignment = T.text, Enum.TextXAlignment.Left
                nm.Text = sk.displayName..(is1 and "  ·P" or "")..(is2 and "  ·S" or "")
                nm.Parent = row
                local rar = Instance.new("TextLabel")
                rar.Size, rar.Position = UDim2.new(1,-8,0,14), UDim2.new(0,8,0,18)
                rar.BackgroundTransparency, rar.Font, rar.TextSize = 1, Enum.Font.GothamBold, 10
                rar.TextColor3, rar.TextXAlignment = sk.cA, Enum.TextXAlignment.Left
                rar.Text = sk.rarityName or "Skin"
                rar.Parent = row
                row.MouseButton1Click:Connect(function()
                    if not SK.selWeapon then return end
                    SK.pending.Camo1=sk.id
                    if not sk.isAnimated then SK.pending.Camo1Animated=false end
                    updInfo(); renderS(sSearch.Text)
                end)
                row.MouseButton2Click:Connect(function()
                    if not SK.selWeapon then return end
                    SK.pending.Camo2=sk.id
                    if not sk.isAnimated then SK.pending.Camo2Animated=false end
                    updInfo(); renderS(sSearch.Text)
                end)
                y=y+39
            end
        end
        sScroll.CanvasSize=UDim2.new(0,0,0,y+4)
    end
    mkBtn(p, 376, "Save & Apply", function()
        if not SK.selWeapon then status.Text="Select weapon"; return end
        if SK.commitWeapon(SK.selWeapon.name, SK.pending) then SK.cfgSave(); status.Text="Applied"; status.TextColor3=T.green
        else status.Text="Failed"; status.TextColor3=Color3.fromRGB(255,80,80) end
    end)
    local rl = mkBtn(p, 416, "Reload lists", function() end)
    rl.MouseButton1Click:Connect(function()
        status.Text="Scanning..."; status.TextColor3=T.dim
        task.spawn(function()
            pcall(SK.prerender)
            SK.weapons=SK.collectWeapons()
            SK.skinsList=SK.collectSkins()
            SK.skinMap={}
            for _,s in ipairs(SK.skinsList) do SK.skinMap[s.id]=s end
            SK.cfgLoad()
            renderW(wSearch.Text); renderS(sSearch.Text)
            status.Text=string.format("W:%d S:%d", #SK.weapons, #SK.skinsList)
            status.TextColor3=(#SK.weapons>0 or #SK.skinsList>0) and T.green or Color3.fromRGB(255,120,80)
        end)
    end)
    wSearch:GetPropertyChangedSignal("Text"):Connect(function() renderW(wSearch.Text) end)
    sSearch:GetPropertyChangedSignal("Text"):Connect(function() renderS(sSearch.Text) end)
    task.delay(1.5, function() rl.MouseButton1Click:Fire() end)
end

-- PLAYER
do
    local p = pages.Player
    p.CanvasSize = UDim2.new(0,0,0,480)
    local nameCard = section(p, "Name Changer", 0, 0, 400, 200)
    local function tbox(yy, ph)
        local b=Instance.new("TextBox")
        b.Size, b.Position = UDim2.new(1,-20,0,26), UDim2.new(0,10,0,yy)
        b.PlaceholderText, b.Text = ph, ""
        b.Font, b.TextSize, b.TextColor3 = Enum.Font.Gotham, 12, T.text
        b.BackgroundColor3, b.BorderSizePixel, b.Parent = T.card, 0, nameCard
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end
    local dBox,uBox,rBox = tbox(32,"Display"), tbox(64,"Username @"), tbox(96,"Rank")
    mkBtn(nameCard, 132, "Apply", function()
        if dBox.Text~="" then savedDisplayName=dBox.Text end
        if uBox.Text~="" then savedGameUsername=uBox.Text end
        if rBox.Text~="" then savedRank=rBox.Text end
        applyNamesToChar()
    end)
    local autoB = mkBtn(nameCard, 166, "Auto respawn: OFF", function() end)
    autoB.MouseButton1Click:Connect(function()
        namesEnabled=not namesEnabled
        autoB.Text="Auto respawn: "..(namesEnabled and "ON" or "OFF")
    end)
    local colCard = section(p, "Name Colors", 0, 216, 400, 140)
    repaint[#repaint+1]=mkToggle(colCard,32,"Colors on",function() return nameColorEnabled end,function(v) nameColorEnabled=v end)
    repaint[#repaint+1]=mkToggle(colCard,64,"Rainbow Display",function() return rainbowDisplayEnabled end,function(v) rainbowDisplayEnabled=v end)
    repaint[#repaint+1]=mkToggle(colCard,96,"Rainbow Username",function() return rainbowUsernameEnabled end,function(v) rainbowUsernameEnabled=v end)
    local hudCard = section(p, "HUD / TP", 416, 0, 250, 220)
    repaint[#repaint+1]=mkToggle(hudCard,32,"RGB Slots",function() return slotActive end,function(v)
        slotActive=v; if not v then for _,h in ipairs(slotHighlights) do if h.frame then h.frame.Visible=false end end end
    end)
    repaint[#repaint+1]=mkToggle(hudCard,64,"GunHUD RGB",function() return gunHUDActive end,function(v) gunHUDActive=v end)
    mkBtn(hudCard, 100, "TP1  ]", function()
        local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(4041,1485,5620) end
    end)
    mkBtn(hudCard, 136, "TP2  [", function()
        local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(4266,-260,4236) end
    end)
end

-- MAIN
do
    local p = pages.Main
    p.CanvasSize = UDim2.new(0,0,0,620)
    local wmCard = section(p, "Watermark", 0, 0, 320, 240)
    repaint[#repaint+1]=mkToggle(wmCard,32,"Show",function() return S.wmOn end,function(v) S.wmOn=v end)
    mkBtn(wmCard,64,"Style 1 — Badge",function() S.wmStyle=1 end)
    mkBtn(wmCard,100,"Style 2 — Bar",function() S.wmStyle=2 end)
    repaint[#repaint+1]=mkToggle(wmCard,140,"FPS",function() return S.wmShowFPS end,function(v) S.wmShowFPS=v end)
    repaint[#repaint+1]=mkToggle(wmCard,172,"Ping",function() return S.wmShowPing end,function(v) S.wmShowPing=v end)
    repaint[#repaint+1]=mkToggle(wmCard,204,"Name / Time",function() return S.wmShowName end,function(v) S.wmShowName=v; S.wmShowTime=v end)

    local tipCard = section(p, "Configs", 336, 0, 320, 100)
    local tip = Instance.new("TextLabel")
    tip.Size, tip.Position = UDim2.new(1,-20,1,-36), UDim2.new(0,10,0,28)
    tip.BackgroundTransparency, tip.Font, tip.TextSize = 1, Enum.Font.Gotham, 12
    tip.TextColor3, tip.TextXAlignment, tip.TextYAlignment = T.dim, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
    tip.TextWrapped, tip.Text = true, "Use the config menu at the top of the window to create, save and load configs."
    tip.Parent = tipCard

    local contactCard = section(p, "Contacts", 0, 256, 320, 90)
    local c1 = Instance.new("TextLabel")
    c1.Size, c1.Position = UDim2.new(1,-16,0,20), UDim2.new(0,12,0,32)
    c1.BackgroundTransparency, c1.Font, c1.TextSize = 1, Enum.Font.GothamBold, 13
    c1.TextColor3, c1.TextXAlignment, c1.Text = T.accent2, Enum.TextXAlignment.Left, "discord.gg/9GEN"
    c1.Parent = contactCard
    local c2 = Instance.new("TextLabel")
    c2.Size, c2.Position = UDim2.new(1,-16,0,20), UDim2.new(0,12,0,56)
    c2.BackgroundTransparency, c2.Font, c2.TextSize = 1, Enum.Font.Gotham, 12
    c2.TextColor3, c2.TextXAlignment, c2.Text = T.text, Enum.TextXAlignment.Left, "ds — xleb_pelmen"
    c2.Parent = contactCard

    -- binds bottom
    local bindCard = section(p, "Binds", 0, 360, 656, 150)
    local menuKeyLbl = Instance.new("TextLabel")
    menuKeyLbl.Size, menuKeyLbl.Position = UDim2.new(1,-20,0,16), UDim2.new(0,10,0,32)
    menuKeyLbl.BackgroundTransparency, menuKeyLbl.Font, menuKeyLbl.TextSize = 1, Enum.Font.Gotham, 12
    menuKeyLbl.TextColor3, menuKeyLbl.TextXAlignment = T.dim, Enum.TextXAlignment.Left
    menuKeyLbl.Text, menuKeyLbl.Parent = "Menu: End", bindCard
    local waitingMenu, waitingHide = false, false
    mkBtn(bindCard, 52, "Rebind menu", function()
        waitingMenu=true; menuKeyLbl.Text="Press key..."; menuKeyLbl.TextColor3=T.accent
    end)
    local hideKeyLbl = Instance.new("TextLabel")
    hideKeyLbl.Size, hideKeyLbl.Position = UDim2.new(1,-20,0,16), UDim2.new(0,10,0,90)
    hideKeyLbl.BackgroundTransparency, hideKeyLbl.Font, hideKeyLbl.TextSize = 1, Enum.Font.Gotham, 12
    hideKeyLbl.TextColor3, hideKeyLbl.TextXAlignment = T.dim, Enum.TextXAlignment.Left
    hideKeyLbl.Text, hideKeyLbl.Parent = "Hide: RightShift", bindCard
    mkBtn(bindCard, 110, "Rebind hide", function()
        waitingHide=true; hideKeyLbl.Text="Press key..."; hideKeyLbl.TextColor3=T.accent
    end)
    conn(UIS.InputBegan:Connect(function(inp)
        if waitingMenu and inp.KeyCode~=Enum.KeyCode.Unknown then
            S.menuKey=inp.KeyCode; waitingMenu=false
            menuKeyLbl.Text="Menu: "..tostring(inp.KeyCode):gsub("Enum.KeyCode.",""); menuKeyLbl.TextColor3=T.dim
        end
        if waitingHide and inp.KeyCode~=Enum.KeyCode.Unknown then
            S.hideKey=inp.KeyCode; waitingHide=false
            hideKeyLbl.Text="Hide: "..tostring(inp.KeyCode):gsub("Enum.KeyCode.",""); hideKeyLbl.TextColor3=T.dim
        end
    end))
end

showPage("Visuals")

conn(UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode==S.menuKey then
        if win.Visible then
            TweenService:Create(win, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, BASE_W*0.94, 0, BASE_H*0.94)
            }):Play()
            task.delay(0.2, function()
                win.Visible = false
                win.BackgroundTransparency = 0
                win.Size = UDim2.new(0, BASE_W, 0, BASE_H)
            end)
        else
            win.Visible = true
            win.BackgroundTransparency = 1
            win.Size = UDim2.new(0, BASE_W*0.94, 0, BASE_H*0.94)
            TweenService:Create(win, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0,
                Size = UDim2.new(0, BASE_W, 0, BASE_H)
            }):Play()
        end
    end
    if inp.KeyCode==S.hideKey then
        hidden=not hidden
        if hidden then win.Visible=false; hideGameUI(); if SH.wm then SH.wm.Enabled=false end
        else win.Visible=true; showGameUI(); if SH.wm then SH.wm.Enabled=true end end
    end
    if inp.KeyCode==Enum.KeyCode.RightBracket then
        local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(4041,1485,5620) end
    end
    if inp.KeyCode==Enum.KeyCode.LeftBracket then
        local r=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(4266,-260,4236) end
    end
end))

hardRefresh()
print("[SummerHub] UID="..MY_UID.." | Shape-safe glass+lenses | Neverlose UI")
