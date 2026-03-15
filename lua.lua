local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local InputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Client = Players.LocalPlayer

local PepsisWorld = library:CreateWindow({
    Name = "Hitler Hub",
    Themeable = {
        Info = "Made by yyungs "
    }
})

-- Global tables for ESP
local ESPBoxes = {}
local ESP3DBoxes = {}
local ESPHeads = {}
local ESPArrows = {}
local ESPLabels = {}
local ESPTracers = {}
local ESPHealthBars = {}
local SkeletonData = {}

-- =====================
--       UNLOAD BUTTON (FIXED)
-- =====================
local function UnloadAll()
    -- Disconnect all connections safely
    local connections = {
        spinbotConnection, teleportToConnection, teleportEveryoneConnection,
        magnetConnection, aimbotConnection, fullbrightConnection, chamsConnection
    }
    for _, conn in ipairs(connections) do
        pcall(function()
            if conn then conn:Disconnect() end
        end)
    end
    
    -- Clear connection variables
    spinbotConnection = nil
    teleportToConnection = nil
    teleportEveryoneConnection = nil
    magnetConnection = nil
    aimbotConnection = nil
    fullbrightConnection = nil
    chamsConnection = nil
    
    -- Safely remove FOV drawings
    pcall(function() 
        if FOVCircle then FOVCircle:Remove() end
        if FOVFill then FOVFill:Remove() end
    end)
    
    -- Safely remove all ESP drawings with error handling
    pcall(function()
        for _, player in ipairs(Players:GetPlayers()) do
            -- Boxes
            if ESPBoxes and ESPBoxes[player] then
                for _, l in ipairs(ESPBoxes[player]) do
                    if l and l.outline then pcall(function() l.outline:Remove() end) end
                    if l and l.fill then pcall(function() l.fill:Remove() end) end
                end
            end
            
            -- 3D Boxes
            if ESP3DBoxes and ESP3DBoxes[player] then
                for _, l in ipairs(ESP3DBoxes[player]) do
                    if l and l.outline then pcall(function() l.outline:Remove() end) end
                    if l and l.fill then pcall(function() l.fill:Remove() end) end
                end
            end
            
            -- Head circles
            if ESPHeads and ESPHeads[player] then
                if ESPHeads[player].outline then pcall(function() ESPHeads[player].outline:Remove() end) end
                if ESPHeads[player].fill then pcall(function() ESPHeads[player].fill:Remove() end) end
            end
            
            -- Arrows
            if ESPArrows and ESPArrows[player] then
                for i=1,3 do
                    if ESPArrows[player][i] then
                        if ESPArrows[player][i].outline then pcall(function() ESPArrows[player][i].outline:Remove() end) end
                        if ESPArrows[player][i].fill then pcall(function() ESPArrows[player][i].fill:Remove() end) end
                    end
                end
                if ESPArrows[player][4] then pcall(function() ESPArrows[player][4]:Remove() end) end
            end
            
            -- Labels
            if ESPLabels and ESPLabels[player] then
                if ESPLabels[player].name then pcall(function() ESPLabels[player].name:Remove() end) end
                if ESPLabels[player].dist then pcall(function() ESPLabels[player].dist:Remove() end) end
            end
            
            -- Tracers
            if ESPTracers and ESPTracers[player] then
                if ESPTracers[player].outline then pcall(function() ESPTracers[player].outline:Remove() end) end
                if ESPTracers[player].fill then pcall(function() ESPTracers[player].fill:Remove() end) end
            end
            
            -- Health bars
            if ESPHealthBars and ESPHealthBars[player] then
                if ESPHealthBars[player].bg then pcall(function() ESPHealthBars[player].bg:Remove() end) end
                if ESPHealthBars[player].fill then pcall(function() ESPHealthBars[player].fill:Remove() end) end
            end
            
            -- Skeleton
            if SkeletonData and SkeletonData[player] then
                if SkeletonData[player].connection then
                    pcall(function() SkeletonData[player].connection:Disconnect() end)
                end
                if SkeletonData[player].limbs then
                    for _, v in pairs(SkeletonData[player].limbs) do
                        if v and v.outline then pcall(function() v.outline:Remove() end) end
                        if v and v.fill then pcall(function() v.fill:Remove() end) end
                    end
                end
            end
        end
    end)
    
    -- Remove chams highlights safely
    pcall(function()
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Highlight") and v.Name == "ChamHighlight" then
                v:Destroy()
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player and player.Character then
                for _, v in ipairs(player.Character:GetChildren()) do
                    if v:IsA("Highlight") and v.Name == "ChamHighlight" then
                        v:Destroy()
                    end
                end
            end
        end
    end)
    
    -- Reset head tilt safely
    pcall(function()
        if Client and Client.Character then
            resetHeadTilt(Client.Character)
        end
    end)
    
    -- Reset lighting
    pcall(function()
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Lighting.Ambient = Color3.new(0,0,0)
        Lighting.OutdoorAmbient = Color3.new(0,0,0)
        Lighting.ClockTime = 12
    end)
    
    -- Clear all tables
    ESPBoxes = {}
    ESP3DBoxes = {}
    ESPHeads = {}
    ESPArrows = {}
    ESPLabels = {}
    ESPTracers = {}
    ESPHealthBars = {}
    SkeletonData = {}
    
    -- Small delay before destroying library
    task.wait(0.1)
    
    -- Destroy the library window safely
    pcall(function()
        if PepsisWorld and PepsisWorld.Destroy then
            PepsisWorld:Destroy()
        end
    end)
end

local UnloadTab = PepsisWorld:CreateTab({ Name = "Unload" })
local UnloadSection = UnloadTab:CreateSection({ Name = "Script Control" })
UnloadSection:AddButton({
    Name = "Unload Script",
    Callback = function()
        UnloadAll()
    end
})

-- =====================
--       AIMBOT TAB
-- =====================
local AimbotTab = PepsisWorld:CreateTab({ Name = "Aimbot" })
local AimbotSection = AimbotTab:CreateSection({ Name = "Head Locking" })

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

local FOVFill = Drawing.new("Circle")
FOVFill.Visible = false
FOVFill.Thickness = 0
FOVFill.Color = Color3.fromRGB(255, 255, 255)
FOVFill.Filled = true
FOVFill.Transparency = 0.25

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    local center = camera.ViewportSize / 2
    local radius = library.Flags["Aimbot_FOVRadius"] or 150
    local fovEnabled = library.Flags["Aimbot_FOVEnabled"] or false
    local fillEnabled = library.Flags["Aimbot_FOVFill"] or false
    FOVCircle.Position = Vector2.new(center.X, center.Y)
    FOVCircle.Radius = radius
    FOVCircle.Visible = fovEnabled
    FOVCircle.Color = library.Flags["Aimbot_FOVColor"] or Color3.fromRGB(255, 255, 255)
    FOVFill.Position = Vector2.new(center.X, center.Y)
    FOVFill.Radius = radius
    FOVFill.Visible = fovEnabled and fillEnabled
    FOVFill.Color = library.Flags["Aimbot_FOVFillColor"] or Color3.fromRGB(255, 255, 255)
end)

local LimbMap = {
    ["Head"]  = { R15 = "Head",       R6 = "Head"     },
    ["Chest"] = { R15 = "UpperTorso", R6 = "Torso"    },
    ["Legs"]  = { R15 = "LowerTorso", R6 = "Torso"    },
    ["Feet"]  = { R15 = "LeftFoot",   R6 = "Left Leg" },
}

local function GetRig(char)
    return char and (char:FindFirstChild("UpperTorso") and "R15" or "R6")
end

local function GetAimPart(char)
    if not char then return nil end
    local limb = library.Flags["Aimbot_Limb"] or "Head"
    local rig = GetRig(char)
    if limb == "Feet" and rig == "R15" then
        return char:FindFirstChild("LeftFoot")
            or char:FindFirstChild("LeftLowerLeg")
            or char:FindFirstChild("RightFoot")
            or char:FindFirstChild("RightLowerLeg")
    end
    return char:FindFirstChild(LimbMap[limb][rig])
end

local function MoveMouseTowards(targetScreenPos, alpha)
    local camera = workspace.CurrentCamera
    local center = camera.ViewportSize / 2
    local delta = (targetScreenPos - center) * alpha * 0.1
    mousemoverel(delta.X, delta.Y)
end

local aimbotConnection = nil
local aimbotKeyDown = false

InputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E and library.Flags["Aimbot_LockOnHead"] then
        aimbotKeyDown = true
    end
end)

InputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.E then
        aimbotKeyDown = false
    end
end)

local function startAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        local mode = library.Flags["Aimbot_ActivationMode"] or "Toggle"
        local shouldAim = false
        
        if mode == "Toggle" then
            shouldAim = library.Flags["Aimbot_LockOnHead"]
        else
            shouldAim = aimbotKeyDown and library.Flags["Aimbot_LockOnHead"]
        end
        
        if not shouldAim then return end
        
        local LocalPlayer = Players.LocalPlayer
        local Camera = workspace.CurrentCamera
        local closestDist = math.huge
        local closestPart = nil
        local screenCenter = Camera.ViewportSize / 2
        local localChar = LocalPlayer.Character
        local localHum = localChar and localChar:FindFirstChildOfClass("Humanoid")
        if not localChar or not localHum or localHum.Health <= 0 then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local aimPart = GetAimPart(char)
            if not aimPart then continue end
            if library.Flags["Aimbot_FOVEnabled"] then
                local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                if not onScreen then continue end
                local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
                if (screenPoint - screenCenter).Magnitude > (library.Flags["Aimbot_FOVRadius"] or 150) then continue end
            end
            if library.Flags["Aimbot_VisibilityCheck"] then
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {localChar, char}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                if workspace:Raycast(Camera.CFrame.Position, aimPart.Position - Camera.CFrame.Position, rp) then continue end
            end
            local dist = (aimPart.Position - Camera.CFrame.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPart = aimPart
            end
        end
        if closestPart then
            local smoothing = library.Flags["Aimbot_Smoothing"] or 50
            local lerpAlpha = math.clamp(1 - (smoothing / 100), 0.05, 1)
            local aimMode = library.Flags["Aimbot_Mode"] or "CFrame"
            if aimMode == "CFrame" then
                local smoothedLook = Camera.CFrame.LookVector:Lerp(
                    (closestPart.Position - Camera.CFrame.Position).Unit, lerpAlpha)
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + smoothedLook)
            elseif aimMode == "Mouse" then
                local screenPos, onScreen = Camera:WorldToViewportPoint(closestPart.Position)
                if onScreen then
                    MoveMouseTowards(Vector2.new(screenPos.X, screenPos.Y), lerpAlpha)
                end
            end
        end
    end)
end

AimbotSection:AddToggle({
    Name = "Lock On Target",
    Flag = "Aimbot_LockOnHead",
    Keybind = Enum.KeyCode.E,
    Callback = function(State)
        startAimbot()
    end
})

AimbotSection:AddDropdown({ 
    Name = "Activation Mode", 
    Flag = "Aimbot_ActivationMode", 
    List = {"Toggle", "Hold"}, 
    Value = "Toggle",
    Callback = function()
        startAimbot()
    end
})

AimbotSection:AddDropdown({ Name = "Aimbot Mode", Flag = "Aimbot_Mode", List = {"CFrame", "Mouse"}, Value = "CFrame" })
AimbotSection:AddDropdown({ Name = "Aim Limb",    Flag = "Aimbot_Limb", List = {"Head", "Chest", "Legs", "Feet"}, Value = "Head" })
AimbotSection:AddToggle({ Name = "FOV Circle",      Flag = "Aimbot_FOVEnabled" })
AimbotSection:AddToggle({ Name = "Fill FOV",         Flag = "Aimbot_FOVFill" })
AimbotSection:AddToggle({ Name = "Visibility Check", Flag = "Aimbot_VisibilityCheck" })
AimbotSection:AddSlider({
    Name = "FOV Radius", Flag = "Aimbot_FOVRadius", Value = 150, Min = 10, Max = 500,
    Format = function(v) return "FOV Radius: " .. v .. "px" end
})
AimbotSection:AddSlider({
    Name = "Smoothing", Flag = "Aimbot_Smoothing", Value = 50, Min = 0, Max = 100,
    Format = function(v)
        if v == 0 then return "Smoothing: Instant (Max Strength)"
        elseif v == 100 then return "Smoothing: Max (Slowest)"
        else return "Smoothing: " .. v end
    end
})
AimbotSection:AddColorpicker({ Name = "FOV Color",  Flag = "Aimbot_FOVColor",     Value = Color3.fromRGB(255, 255, 255) })
AimbotSection:AddColorpicker({ Name = "Fill Color", Flag = "Aimbot_FOVFillColor", Value = Color3.fromRGB(255, 255, 255) })

-- =====================
--        ESP TAB (MERGED WITH WORLD AND CHAMS)
-- =====================
local ESPTab = PepsisWorld:CreateTab({ Name = "ESP" })

-- Player ESP Section
local ESPSection = ESPTab:CreateSection({ Name = "Player ESP" })

local Camera = workspace.CurrentCamera

local function NewLine()
    local outline = Drawing.new("Line")
    outline.Visible = false outline.Thickness = 3
    outline.Color = Color3.fromRGB(0, 0, 0) outline.Transparency = 1
    local fill = Drawing.new("Line")
    fill.Visible = false fill.Thickness = 1
    fill.Color = Color3.fromRGB(255, 255, 255) fill.Transparency = 1
    return { outline = outline, fill = fill }
end

local function NewTracer(color, thickness)
    local outline = Drawing.new("Line")
    outline.Visible = false
    outline.Thickness = thickness + 2
    outline.Color = Color3.fromRGB(0, 0, 0)
    outline.Transparency = 1
    
    local fill = Drawing.new("Line")
    fill.Visible = false
    fill.Thickness = thickness
    fill.Color = color
    fill.Transparency = 1
    
    return { outline = outline, fill = fill }
end

local function NewHealthBar()
    local bg = Drawing.new("Line")
    bg.Visible = false
    bg.Thickness = 4
    bg.Color = Color3.fromRGB(0, 0, 0)
    bg.Transparency = 1
    
    local fill = Drawing.new("Line")
    fill.Visible = false
    fill.Thickness = 2
    fill.Color = Color3.fromRGB(0, 255, 0)
    fill.Transparency = 1
    
    return { bg = bg, fill = fill }
end

local function SetLine(pair, from, to, color, thickness, visible)
    if not pair or not pair.outline or not pair.fill then return end
    pair.outline.From = from pair.outline.To = to
    pair.outline.Thickness = thickness + 2 pair.outline.Visible = visible
    pair.fill.From = from pair.fill.To = to
    pair.fill.Color = color pair.fill.Thickness = thickness pair.fill.Visible = visible
end

local function RemoveLine(pair)
    if not pair then return end
    pcall(function()
        if pair.outline then pair.outline:Remove() end
        if pair.fill then pair.fill:Remove() end
    end)
end

-- 2D Box
local function CreateBox()
    local lines = {}
    for i = 1, 4 do lines[i] = NewLine() end
    return lines
end

local function RemoveBox(player)
    if ESPBoxes and ESPBoxes[player] then
        for _, l in ipairs(ESPBoxes[player]) do RemoveLine(l) end
        ESPBoxes[player] = nil
    end
end

local function GetCharacterBounds(char)
    if not char then return nil end
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local s = part.Size
            for _, o in ipairs({
                Vector3.new( s.X/2, s.Y/2, s.Z/2), Vector3.new(-s.X/2, s.Y/2, s.Z/2),
                Vector3.new( s.X/2,-s.Y/2, s.Z/2), Vector3.new(-s.X/2,-s.Y/2, s.Z/2),
                Vector3.new( s.X/2, s.Y/2,-s.Z/2), Vector3.new(-s.X/2, s.Y/2,-s.Z/2),
                Vector3.new( s.X/2,-s.Y/2,-s.Z/2), Vector3.new(-s.X/2,-s.Y/2,-s.Z/2),
            }) do
                local wp = part.CFrame:PointToWorldSpace(o)
                local sp, on = Camera:WorldToViewportPoint(wp)
                if on then
                    any = true
                    minX=math.min(minX,sp.X) minY=math.min(minY,sp.Y)
                    maxX=math.max(maxX,sp.X) maxY=math.max(maxY,sp.Y)
                end
            end
        end
    end
    if not any then return nil end
    return minX, minY, maxX, maxY
end

local function DrawBox2D(lines, minX, minY, maxX, maxY, color, thickness)
    if not lines then return end
    local tl=Vector2.new(minX,minY) local tr=Vector2.new(maxX,minY)
    local bl=Vector2.new(minX,maxY) local br=Vector2.new(maxX,maxY)
    SetLine(lines[1],tl,tr,color,thickness,true)
    SetLine(lines[2],bl,br,color,thickness,true)
    SetLine(lines[3],tl,bl,color,thickness,true)
    SetLine(lines[4],tr,br,color,thickness,true)
end

-- 3D Box
local function Create3DBox()
    local lines = {}
    for i = 1, 12 do lines[i] = NewLine() end
    return lines
end

local function Remove3DBox(player)
    if ESP3DBoxes and ESP3DBoxes[player] then
        for _, l in ipairs(ESP3DBoxes[player]) do RemoveLine(l) end
        ESP3DBoxes[player] = nil
    end
end

local function Draw3DBox(lines, char, color, thickness)
    if not lines or not char then return end
    local mnX,mnY,mnZ = math.huge,math.huge,math.huge
    local mxX,mxY,mxZ = -math.huge,-math.huge,-math.huge
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local s = part.Size
            for _, o in ipairs({
                Vector3.new( s.X/2, s.Y/2, s.Z/2), Vector3.new(-s.X/2, s.Y/2, s.Z/2),
                Vector3.new( s.X/2,-s.Y/2, s.Z/2), Vector3.new(-s.X/2,-s.Y/2, s.Z/2),
                Vector3.new( s.X/2, s.Y/2,-s.Z/2), Vector3.new(-s.X/2, s.Y/2,-s.Z/2),
                Vector3.new( s.X/2,-s.Y/2,-s.Z/2), Vector3.new(-s.X/2,-s.Y/2,-s.Z/2),
            }) do
                local wp = part.CFrame:PointToWorldSpace(o)
                mnX=math.min(mnX,wp.X) mnY=math.min(mnY,wp.Y) mnZ=math.min(mnZ,wp.Z)
                mxX=math.max(mxX,wp.X) mxY=math.max(mxY,wp.Y) mxZ=math.max(mxZ,wp.Z)
            end
        end
    end
    local corners = {
        Vector3.new(mnX,mnY,mnZ), Vector3.new(mxX,mnY,mnZ),
        Vector3.new(mxX,mxY,mnZ), Vector3.new(mnX,mxY,mnZ),
        Vector3.new(mnX,mnY,mxZ), Vector3.new(mxX,mnY,mxZ),
        Vector3.new(mxX,mxY,mxZ), Vector3.new(mnX,mxY,mxZ),
    }
    local sc = {} local allVis = true
    for i, c in ipairs(corners) do
        local sp = Camera:WorldToViewportPoint(c)
        if sp.Z <= 0 then allVis = false end
        sc[i] = Vector2.new(sp.X, sp.Y)
    end
    if not allVis then
        for _, l in ipairs(lines) do 
            if l then
                l.outline.Visible=false 
                l.fill.Visible=false 
            end
        end
        return
    end
    local edges = {{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}
    for i, e in ipairs(edges) do 
        if lines[i] then
            SetLine(lines[i],sc[e[1]],sc[e[2]],color,thickness,true) 
        end
    end
end

-- Head Circle
local function CreateHeadCircle()
    local outline = Drawing.new("Circle")
    outline.Visible=false outline.Filled=false outline.Thickness=3
    outline.Color=Color3.fromRGB(0,0,0) outline.Transparency=1
    local fill = Drawing.new("Circle")
    fill.Visible=false fill.Filled=true fill.Thickness=1
    fill.Color=Color3.fromRGB(255,255,255) fill.Transparency=0.2
    return { outline=outline, fill=fill }
end

local function RemoveHeadCircle(player)
    if ESPHeads and ESPHeads[player] then
        pcall(function()
            ESPHeads[player].outline:Remove() 
            ESPHeads[player].fill:Remove()
        end)
        ESPHeads[player] = nil
    end
end

local function DrawHeadCircle(headCircle, pos, radius, color)
    if not headCircle then return end
    headCircle.outline.Position = pos
    headCircle.outline.Radius = radius + 1
    headCircle.outline.Visible = true
    headCircle.fill.Position = pos
    headCircle.fill.Radius = radius
    headCircle.fill.Color = color
    headCircle.fill.Visible = true
end

-- Arrow ESP
local function CreateArrow()
    local parts = {}
    for i = 1, 3 do parts[i] = NewLine() end
    local label = Drawing.new("Text")
    label.Visible=false label.Size=13 label.Center=true
    label.Outline=true label.Color=Color3.fromRGB(255,255,255) label.Font=Drawing.Fonts.UI
    parts[4] = label
    return parts
end

local function RemoveArrow(player)
    if ESPArrows and ESPArrows[player] then
        for i=1,3 do RemoveLine(ESPArrows[player][i]) end
        pcall(function() ESPArrows[player][4]:Remove() end)
        ESPArrows[player] = nil
    end
end

local function DrawArrowOnCircle(parts, angle, color, distText)
    if not parts then return end
    local vp = Camera.ViewportSize local sc = vp/2
    local maxR = math.min(vp.X,vp.Y)/2-30 local minR = 40
    local t = (library.Flags["ESP_ArrowPadding"] or 60)/400
    local radius = maxR-(maxR-minR)*t
    local cosA,sinA = math.cos(angle),math.sin(angle)
    local tipPos = Vector2.new(sc.X+cosA*radius,sc.Y+sinA*radius)
    local forward = Vector2.new(cosA,sinA) local perp = Vector2.new(-sinA,cosA)
    local base = tipPos-forward*20
    local bl = base-perp*8 local br = base+perp*8
    SetLine(parts[1],tipPos,bl,color,2,true)
    SetLine(parts[2],tipPos,br,color,2,true)
    SetLine(parts[3],bl,br,color,2,true)
    parts[4].Position=base-forward*14
    parts[4].Text=distText parts[4].Color=color parts[4].Visible=true
end

-- Name + Distance
local function CreateLabels()
    local n = Drawing.new("Text")
    n.Visible=false n.Size=14 n.Center=true n.Outline=true
    n.Color=Color3.fromRGB(255,255,255) n.Font=Drawing.Fonts.UI
    local d = Drawing.new("Text")
    d.Visible=false d.Size=12 d.Center=true d.Outline=true
    d.Color=Color3.fromRGB(255,255,255) d.Font=Drawing.Fonts.UI
    return { name=n, dist=d }
end

local function RemoveLabels(player)
    if ESPLabels and ESPLabels[player] then
        pcall(function()
            ESPLabels[player].name:Remove() 
            ESPLabels[player].dist:Remove()
        end)
        ESPLabels[player] = nil
    end
end

-- Skeleton ESP
local function NewSkelLine() return NewLine() end

local function CreateSkeletonR15()
    return {
        Head_UpperTorso=NewSkelLine(), UpperTorso_LowerTorso=NewSkelLine(),
        UpperTorso_LeftUpperArm=NewSkelLine(), LeftUpperArm_LeftLowerArm=NewSkelLine(), LeftLowerArm_LeftHand=NewSkelLine(),
        UpperTorso_RightUpperArm=NewSkelLine(), RightUpperArm_RightLowerArm=NewSkelLine(), RightLowerArm_RightHand=NewSkelLine(),
        LowerTorso_LeftUpperLeg=NewSkelLine(), LeftUpperLeg_LeftLowerLeg=NewSkelLine(), LeftLowerLeg_LeftFoot=NewSkelLine(),
        LowerTorso_RightUpperLeg=NewSkelLine(), RightUpperLeg_RightLowerLeg=NewSkelLine(), RightLowerLeg_RightFoot=NewSkelLine(),
    }
end

local function CreateSkeletonR6()
    return {
        Head_Spine=NewSkelLine(), Spine=NewSkelLine(),
        LeftArm=NewSkelLine(), LeftArm_UpperTorso=NewSkelLine(),
        RightArm=NewSkelLine(), RightArm_UpperTorso=NewSkelLine(),
        LeftLeg=NewSkelLine(), LeftLeg_LowerTorso=NewSkelLine(),
        RightLeg=NewSkelLine(), RightLeg_LowerTorso=NewSkelLine(),
    }
end

local function SetSkeletonVisibility(limbs, state)
    if not limbs then return end
    for _, v in pairs(limbs) do 
        if v then
            v.outline.Visible=state 
            v.fill.Visible=state 
        end
    end
end

local function RemoveSkeleton(player)
    if SkeletonData and SkeletonData[player] then
        if SkeletonData[player].connection then
            pcall(function() SkeletonData[player].connection:Disconnect() end)
        end
        if SkeletonData[player].limbs then
            for _, v in pairs(SkeletonData[player].limbs) do 
                RemoveLine(v) 
            end
        end
        SkeletonData[player] = nil
    end
end

local function w2v(pos) 
    if not pos then return Vector2.new(0,0) end
    local p = Camera:WorldToViewportPoint(pos) 
    return Vector2.new(p.X,p.Y) 
end

local function SetSkelLine(pair, from, to, color) 
    if pair then
        SetLine(pair,from,to,color,1,true) 
    end
end

local function StartSkeletonR15(player, limbs)
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not player or not Players:FindFirstChild(player.Name) then
            if limbs then SetSkeletonVisibility(limbs,false) end
            if conn then conn:Disconnect() end
            if SkeletonData then SkeletonData[player] = nil end
            return
        end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not library.Flags or not library.Flags["ESP_SkeletonESP"] or not char or not hum or hum.Health<=0 then 
            if limbs then SetSkeletonVisibility(limbs,false) end
            return 
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then SetSkeletonVisibility(limbs,false) return end
        local _,vis = Camera:WorldToViewportPoint(root.Position)
        if not vis then SetSkeletonVisibility(limbs,false) return end
        local col = (library.Flags and library.Flags["ESP_SkeletonColor"]) or Color3.fromRGB(255,255,255)
        
        -- Check if all required parts exist
        if not char.Head or not char.UpperTorso or not char.LowerTorso or
           not char.LeftUpperArm or not char.LeftLowerArm or not char.LeftHand or
           not char.RightUpperArm or not char.RightLowerArm or not char.RightHand or
           not char.LeftUpperLeg or not char.LeftLowerLeg or not char.LeftFoot or
           not char.RightUpperLeg or not char.RightLowerLeg or not char.RightFoot then
            SetSkeletonVisibility(limbs,false)
            return
        end
        
        local H=w2v(char.Head.Position) 
        local UT=w2v(char.UpperTorso.Position) 
        local LT=w2v(char.LowerTorso.Position)
        local LUA=w2v(char.LeftUpperArm.Position) 
        local LLA=w2v(char.LeftLowerArm.Position) 
        local LH=w2v(char.LeftHand.Position)
        local RUA=w2v(char.RightUpperArm.Position) 
        local RLA=w2v(char.RightLowerArm.Position) 
        local RH=w2v(char.RightHand.Position)
        local LUL=w2v(char.LeftUpperLeg.Position) 
        local LLL=w2v(char.LeftLowerLeg.Position) 
        local LF=w2v(char.LeftFoot.Position)
        local RUL=w2v(char.RightUpperLeg.Position) 
        local RLL=w2v(char.RightLowerLeg.Position) 
        local RF=w2v(char.RightFoot.Position)
        
        SetSkelLine(limbs.Head_UpperTorso,H,UT,col) 
        SetSkelLine(limbs.UpperTorso_LowerTorso,UT,LT,col)
        SetSkelLine(limbs.UpperTorso_LeftUpperArm,UT,LUA,col) 
        SetSkelLine(limbs.LeftUpperArm_LeftLowerArm,LUA,LLA,col) 
        SetSkelLine(limbs.LeftLowerArm_LeftHand,LLA,LH,col)
        SetSkelLine(limbs.UpperTorso_RightUpperArm,UT,RUA,col) 
        SetSkelLine(limbs.RightUpperArm_RightLowerArm,RUA,RLA,col) 
        SetSkelLine(limbs.RightLowerArm_RightHand,RLA,RH,col)
        SetSkelLine(limbs.LowerTorso_LeftUpperLeg,LT,LUL,col) 
        SetSkelLine(limbs.LeftUpperLeg_LeftLowerLeg,LUL,LLL,col) 
        SetSkelLine(limbs.LeftLowerLeg_LeftFoot,LLL,LF,col)
        SetSkelLine(limbs.LowerTorso_RightUpperLeg,LT,RUL,col) 
        SetSkelLine(limbs.RightUpperLeg_RightLowerLeg,RUL,RLL,col) 
        SetSkelLine(limbs.RightLowerLeg_RightFoot,RLL,RF,col)
    end)
    return conn
end

local function StartSkeletonR6(player, limbs)
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not player or not Players:FindFirstChild(player.Name) then
            if limbs then SetSkeletonVisibility(limbs,false) end
            if conn then conn:Disconnect() end
            if SkeletonData then SkeletonData[player] = nil end
            return
        end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not library.Flags or not library.Flags["ESP_SkeletonESP"] or not char or not hum or hum.Health<=0 then 
            if limbs then SetSkeletonVisibility(limbs,false) end
            return 
        end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then SetSkeletonVisibility(limbs,false) return end
        local _,vis = Camera:WorldToViewportPoint(root.Position)
        if not vis then SetSkeletonVisibility(limbs,false) return end
        local col = (library.Flags and library.Flags["ESP_SkeletonColor"]) or Color3.fromRGB(255,255,255)
        
        local torso = char:FindFirstChild("Torso")
        if not torso then SetSkeletonVisibility(limbs,false) return end
        local TH=torso.Size.Y/2-0.2
        local H=w2v(char.Head.Position)
        local UT=w2v((torso.CFrame*CFrame.new(0,TH,0)).p)
        local LT=w2v((torso.CFrame*CFrame.new(0,-TH,0)).p)
        local LA=char:FindFirstChild("Left Arm") 
        local RA=char:FindFirstChild("Right Arm")
        local LL=char:FindFirstChild("Left Leg") 
        local RL=char:FindFirstChild("Right Leg")
        if not LA or not RA or not LL or not RL then 
            SetSkeletonVisibility(limbs,false) 
            return 
        end
        local LUA=w2v((LA.CFrame*CFrame.new(0,LA.Size.Y/2-0.2,0)).p) 
        local LLA=w2v((LA.CFrame*CFrame.new(0,-LA.Size.Y/2+0.2,0)).p)
        local RUA=w2v((RA.CFrame*CFrame.new(0,RA.Size.Y/2-0.2,0)).p) 
        local RLA=w2v((RA.CFrame*CFrame.new(0,-RA.Size.Y/2+0.2,0)).p)
        local LUL=w2v((LL.CFrame*CFrame.new(0,LL.Size.Y/2-0.2,0)).p) 
        local LLL=w2v((LL.CFrame*CFrame.new(0,-LL.Size.Y/2+0.2,0)).p)
        local RUL=w2v((RL.CFrame*CFrame.new(0,RL.Size.Y/2-0.2,0)).p) 
        local RLL=w2v((RL.CFrame*CFrame.new(0,-RL.Size.Y/2+0.2,0)).p)
        
        SetSkelLine(limbs.Head_Spine,H,UT,col) 
        SetSkelLine(limbs.Spine,UT,LT,col)
        SetSkelLine(limbs.LeftArm_UpperTorso,UT,LUA,col) 
        SetSkelLine(limbs.LeftArm,LUA,LLA,col)
        SetSkelLine(limbs.RightArm_UpperTorso,UT,RUA,col) 
        SetSkelLine(limbs.RightArm,RUA,RLA,col)
        SetSkelLine(limbs.LeftLeg_LowerTorso,LT,LUL,col) 
        SetSkelLine(limbs.LeftLeg,LUL,LLL,col)
        SetSkelLine(limbs.RightLeg_LowerTorso,LT,RUL,col) 
        SetSkelLine(limbs.RightLeg,RUL,RLL,col)
    end)
    return conn
end

local function InitSkeleton(player)
    if not player or SkeletonData[player] then return end
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local isR15 = hum.RigType == Enum.HumanoidRigType.R15
    local limbs = isR15 and CreateSkeletonR15() or CreateSkeletonR6()
    local conn = isR15 and StartSkeletonR15(player,limbs) or StartSkeletonR6(player,limbs)
    SkeletonData[player] = { limbs=limbs, connection=conn }
    player.CharacterAdded:Connect(function()
        RemoveSkeleton(player) 
        task.wait(1) 
        InitSkeleton(player)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then 
        coroutine.wrap(function()
            pcall(function() InitSkeleton(player) end)
        end)()
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= Players.LocalPlayer then 
        coroutine.wrap(function()
            pcall(function() InitSkeleton(player) end)
        end)()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        RemoveBox(player) 
        Remove3DBox(player) 
        RemoveHeadCircle(player)
        RemoveArrow(player) 
        RemoveLabels(player) 
        RemoveSkeleton(player)
    end)
end)

-- Main ESP render loop
RunService.RenderStepped:Connect(function()
    -- Safely check if library and flags exist
    if not library or not library.Flags then return end
    
    local boxEnabled = library.Flags["ESP_BoxESP"]
    local box3DEnabled = library.Flags["ESP_3DBoxESP"]
    local headEnabled = library.Flags["ESP_HeadESP"]
    local arrowEnabled = library.Flags["ESP_ArrowESP"]
    local skeletonEnabled = library.Flags["ESP_SkeletonESP"]
    local nameEnabled = library.Flags["ESP_NameESP"]
    local distEnabled = library.Flags["ESP_DistESP"]
    local tracerEnabled = library.Flags["ESP_Tracers"]
    local healthEnabled = library.Flags["ESP_HealthBar"]
    
    local boxColor = library.Flags["ESP_BoxColor"] or Color3.fromRGB(255,255,255)
    local box3DColor = library.Flags["ESP_3DBoxColor"] or Color3.fromRGB(255,100,100)
    local headColor = library.Flags["ESP_HeadColor"] or Color3.fromRGB(255,80,80)
    local arrowColor = library.Flags["ESP_ArrowColor"] or Color3.fromRGB(100,220,100)
    local nameColor = library.Flags["ESP_NameColor"] or Color3.fromRGB(255,255,255)
    local distColor = library.Flags["ESP_DistColor"] or Color3.fromRGB(255,200,0)
    local skeletonColor = library.Flags["ESP_SkeletonColor"] or Color3.fromRGB(255,255,255)
    local tracerColor = library.Flags["ESP_TracerColor"] or Color3.fromRGB(255,0,0)
    local tracerOrigin = library.Flags["ESP_TracerOrigin"] or "Bottom"
    local tracerFollowMouse = library.Flags["ESP_TracerFollowMouse"] or false
    local thickness = library.Flags["ESP_BoxThickness"] or 1
    
    local Cam = workspace.CurrentCamera
    if not Cam then return end
    local screenCenter = Cam.ViewportSize / 2
    local mousePos = InputService:GetMouseLocation()
    local LocalPlayer = Players.LocalPlayer

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        -- Safely get character components
        local char = player.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local alive = hum and hum.Health and hum.Health > 0
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local rightArm = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") -- For health bar attachment
        
        if not alive or not root then 
            -- Hide all ESP for this player if not valid
            if ESPBoxes and ESPBoxes[player] then 
                for _,l in ipairs(ESPBoxes[player]) do 
                    if l then
                        l.outline.Visible=false 
                        l.fill.Visible=false 
                    end
                end 
            end
            if ESP3DBoxes and ESP3DBoxes[player] then 
                for _,l in ipairs(ESP3DBoxes[player]) do 
                    if l then
                        l.outline.Visible=false 
                        l.fill.Visible=false 
                    end
                end 
            end
            if ESPHeads and ESPHeads[player] then 
                ESPHeads[player].outline.Visible=false 
                ESPHeads[player].fill.Visible=false 
            end
            if ESPArrows and ESPArrows[player] then
                for i=1,3 do 
                    if ESPArrows[player][i] then
                        ESPArrows[player][i].outline.Visible=false 
                        ESPArrows[player][i].fill.Visible=false 
                    end
                end
                if ESPArrows[player][4] then ESPArrows[player][4].Visible=false end
            end
            if ESPLabels and ESPLabels[player] then 
                ESPLabels[player].name.Visible=false 
                ESPLabels[player].dist.Visible=false 
            end
            if ESPTracers and ESPTracers[player] then 
                ESPTracers[player].outline.Visible=false 
                ESPTracers[player].fill.Visible=false 
            end
            if ESPHealthBars and ESPHealthBars[player] then 
                ESPHealthBars[player].bg.Visible=false 
                ESPHealthBars[player].fill.Visible=false 
            end
            continue 
        end

        -- 2D Box
        if boxEnabled then
            if not ESPBoxes[player] then ESPBoxes[player] = CreateBox() end
            local minX,minY,maxX,maxY = GetCharacterBounds(char)
            if minX then 
                DrawBox2D(ESPBoxes[player],minX,minY,maxX,maxY,boxColor,thickness)
            elseif ESPBoxes[player] then
                for _,l in ipairs(ESPBoxes[player]) do 
                    if l then
                        l.outline.Visible=false 
                        l.fill.Visible=false 
                    end
                end 
            end
        elseif ESPBoxes[player] then
            for _,l in ipairs(ESPBoxes[player]) do 
                if l then
                    l.outline.Visible=false 
                    l.fill.Visible=false 
                end
            end 
        end

        -- 3D Box
        if box3DEnabled then
            if not ESP3DBoxes[player] then ESP3DBoxes[player] = Create3DBox() end
            Draw3DBox(ESP3DBoxes[player],char,box3DColor,thickness)
        elseif ESP3DBoxes[player] then
            for _,l in ipairs(ESP3DBoxes[player]) do 
                if l then
                    l.outline.Visible=false 
                    l.fill.Visible=false 
                end
            end 
        end

        -- Head Circle
        if headEnabled and head then
            if not ESPHeads[player] then ESPHeads[player] = CreateHeadCircle() end
            local hsp = Cam:WorldToViewportPoint(head.Position)
            if hsp.Z > 0 then
                local edgeSP = Cam:WorldToViewportPoint(head.Position + Cam.CFrame.RightVector * (head.Size.X/2))
                local screenRadius = math.max((Vector2.new(edgeSP.X,edgeSP.Y)-Vector2.new(hsp.X,hsp.Y)).Magnitude, 4)
                local pos2D = Vector2.new(hsp.X,hsp.Y)
                DrawHeadCircle(ESPHeads[player], pos2D, screenRadius, headColor)
            else
                if ESPHeads[player] then
                    ESPHeads[player].outline.Visible=false 
                    ESPHeads[player].fill.Visible=false
                end
            end
        elseif ESPHeads[player] then
            ESPHeads[player].outline.Visible=false 
            ESPHeads[player].fill.Visible=false
        end

        -- Arrow
        if arrowEnabled then
            if not ESPArrows[player] then ESPArrows[player] = CreateArrow() end
            local sp3, onScreen = Cam:WorldToViewportPoint(root.Position)
            local dist = math.round((root.Position-Cam.CFrame.Position).Magnitude)
            local dir = Vector2.new(sp3.X-screenCenter.X, sp3.Y-screenCenter.Y)
            local angle = math.atan2(dir.Y,dir.X)
            if onScreen then
                if ESPArrows[player] then
                    for i=1,3 do 
                        if ESPArrows[player][i] then
                            ESPArrows[player][i].outline.Visible=false 
                            ESPArrows[player][i].fill.Visible=false 
                        end
                    end
                    if ESPArrows[player][4] then ESPArrows[player][4].Visible=false end
                end
            else 
                DrawArrowOnCircle(ESPArrows[player],angle,arrowColor,dist.."m") 
            end
        elseif ESPArrows[player] then
            for i=1,3 do 
                if ESPArrows[player][i] then
                    ESPArrows[player][i].outline.Visible=false 
                    ESPArrows[player][i].fill.Visible=false 
                end
            end
            if ESPArrows[player][4] then ESPArrows[player][4].Visible=false end
        end

        -- Name + Distance
        if (nameEnabled or distEnabled) and head then
            if not ESPLabels[player] then ESPLabels[player] = CreateLabels() end
            local hsp2, onScreen = Cam:WorldToViewportPoint(head.Position)
            if not onScreen then 
                if ESPLabels[player] then
                    ESPLabels[player].name.Visible=false 
                    ESPLabels[player].dist.Visible=false 
                end
            else
                local dist = math.round((root.Position-Cam.CFrame.Position).Magnitude)
                local hp2 = Vector2.new(hsp2.X,hsp2.Y)
                if nameEnabled then
                    ESPLabels[player].name.Text=player.Name 
                    ESPLabels[player].name.Color=nameColor
                    ESPLabels[player].name.Position=Vector2.new(hp2.X,hp2.Y-30) 
                    ESPLabels[player].name.Visible=true
                else 
                    ESPLabels[player].name.Visible=false 
                end
                if distEnabled then
                    local off = nameEnabled and 44 or 30
                    ESPLabels[player].dist.Text=dist.."m" 
                    ESPLabels[player].dist.Color=distColor
                    ESPLabels[player].dist.Position=Vector2.new(hp2.X,hp2.Y-off) 
                    ESPLabels[player].dist.Visible=true
                else 
                    ESPLabels[player].dist.Visible=false 
                end
            end
        elseif ESPLabels[player] then
            ESPLabels[player].name.Visible=false 
            ESPLabels[player].dist.Visible=false
        end
        
        -- Tracer ESP
        if tracerEnabled then
            if not ESPTracers[player] then
                ESPTracers[player] = NewTracer(tracerColor, thickness)
            end
            
            local rootPos, onScreen = Cam:WorldToViewportPoint(root.Position)
            if onScreen then
                local startPos
                if tracerFollowMouse then
                    startPos = Vector2.new(mousePos.X, mousePos.Y)
                elseif tracerOrigin == "Middle" then
                    startPos = screenCenter
                else -- Bottom
                    startPos = Vector2.new(screenCenter.X, Cam.ViewportSize.Y)
                end
                
                local endPos = Vector2.new(rootPos.X, rootPos.Y - 20)
                
                if ESPTracers[player] then
                    ESPTracers[player].outline.From = startPos
                    ESPTracers[player].outline.To = endPos
                    ESPTracers[player].outline.Visible = true
                    
                    ESPTracers[player].fill.From = startPos
                    ESPTracers[player].fill.To = endPos
                    ESPTracers[player].fill.Color = tracerColor
                    ESPTracers[player].fill.Visible = true
                end
            else
                if ESPTracers[player] then
                    ESPTracers[player].outline.Visible = false
                    ESPTracers[player].fill.Visible = false
                end
            end
        elseif ESPTracers[player] then
            ESPTracers[player].outline.Visible = false
            ESPTracers[player].fill.Visible = false
        end
        
        -- Health Bar ESP (ATTACHED TO RIGHT ARM)
        if healthEnabled and rightArm then
            if not ESPHealthBars[player] then
                ESPHealthBars[player] = NewHealthBar()
            end
            
            local armPos, onScreen = Cam:WorldToViewportPoint(rightArm.Position)
            
            if onScreen then
                local healthPercent = hum.Health / hum.MaxHealth
                local barHeight = 35
                local barWidth = 4
                
                -- Position bar to the right of the right arm
                local armX = armPos.X
                local armY = armPos.Y
                
                -- Bar background (vertical line)
                local barStart = Vector2.new(armX + 15, armY - 15) -- Top of bar
                local barEnd = Vector2.new(armX + 15, armY + 20) -- Bottom of bar
                
                -- Health color based on health (red to green)
                local healthColor = Color3.fromRGB(
                    255 * (1 - healthPercent),
                    255 * healthPercent,
                    0
                )
                
                -- Background (black outline)
                ESPHealthBars[player].bg.From = barStart
                ESPHealthBars[player].bg.To = barEnd
                ESPHealthBars[player].bg.Thickness = barWidth + 2
                ESPHealthBars[player].bg.Visible = true
                
                -- Health fill (colored) - fills from top down based on health
                local healthEnd = Vector2.new(
                    armX + 15,
                    armY - 15 + (35 * (1 - healthPercent))
                )
                
                ESPHealthBars[player].fill.From = barStart
                ESPHealthBars[player].fill.To = healthEnd
                ESPHealthBars[player].fill.Color = healthColor
                ESPHealthBars[player].fill.Thickness = barWidth
                ESPHealthBars[player].fill.Visible = true
            else
                if ESPHealthBars[player] then
                    ESPHealthBars[player].bg.Visible = false
                    ESPHealthBars[player].fill.Visible = false
                end
            end
        elseif ESPHealthBars[player] then
            ESPHealthBars[player].bg.Visible = false
            ESPHealthBars[player].fill.Visible = false
        end
    end
end)

-- ESP Toggles
ESPSection:AddToggle({ Name = "Box ESP",      Flag = "ESP_BoxESP" })
ESPSection:AddToggle({ Name = "3D Box ESP",   Flag = "ESP_3DBoxESP" })
ESPSection:AddToggle({ Name = "Head ESP",     Flag = "ESP_HeadESP" })
ESPSection:AddToggle({ Name = "Arrow ESP",    Flag = "ESP_ArrowESP" })
ESPSection:AddToggle({ Name = "Skeleton ESP", Flag = "ESP_SkeletonESP" })
ESPSection:AddToggle({ Name = "Name ESP",     Flag = "ESP_NameESP" })
ESPSection:AddToggle({ Name = "Distance ESP", Flag = "ESP_DistESP" })
ESPSection:AddToggle({ Name = "Tracers",      Flag = "ESP_Tracers" })
ESPSection:AddToggle({ Name = "Health Bars",  Flag = "ESP_HealthBar" })
ESPSection:AddSlider({ Name = "Box Thickness", Flag = "ESP_BoxThickness", Value = 1, Min = 1, Max = 5, Format = function(v) return "Thickness: "..v.."px" end })
ESPSection:AddSlider({
    Name = "Arrow Radius", Flag = "ESP_ArrowPadding", Value = 60, Min = 0, Max = 400,
    Format = function(v)
        if v == 0 then return "Arrow Radius: Screen Edge"
        elseif v >= 400 then return "Arrow Radius: FOV Mode"
        else return "Arrow Radius: "..v end
    end
})
ESPSection:AddDropdown({
    Name = "Tracer Origin",
    Flag = "ESP_TracerOrigin",
    List = {"Bottom", "Middle"},
    Value = "Bottom"
})
ESPSection:AddToggle({ Name = "Tracer Follow Mouse", Flag = "ESP_TracerFollowMouse" })
ESPSection:AddColorpicker({ Name = "Tracer Color", Flag = "ESP_TracerColor", Value = Color3.fromRGB(255, 0, 0) })
ESPSection:AddColorpicker({ Name = "Box Color",      Flag = "ESP_BoxColor",      Value = Color3.fromRGB(255,255,255) })
ESPSection:AddColorpicker({ Name = "3D Box Color",   Flag = "ESP_3DBoxColor",    Value = Color3.fromRGB(255,100,100) })
ESPSection:AddColorpicker({ Name = "Head Color",     Flag = "ESP_HeadColor",     Value = Color3.fromRGB(255,80,80)   })
ESPSection:AddColorpicker({ Name = "Arrow Color",    Flag = "ESP_ArrowColor",    Value = Color3.fromRGB(100,220,100) })
ESPSection:AddColorpicker({ Name = "Skeleton Color", Flag = "ESP_SkeletonColor", Value = Color3.fromRGB(255,255,255) })
ESPSection:AddColorpicker({ Name = "Name Color",     Flag = "ESP_NameColor",     Value = Color3.fromRGB(255,255,255) })
ESPSection:AddColorpicker({ Name = "Distance Color", Flag = "ESP_DistColor",     Value = Color3.fromRGB(255,200,0)   })

-- =====================
-- WORLD SETTINGS (IN ESP TAB)
-- =====================
local WorldSection = ESPTab:CreateSection({ Name = "World Settings" })

local fullbrightConnection
local originalBrightness = Lighting.Brightness
local originalShadows = Lighting.GlobalShadows
local originalFogEnd = Lighting.FogEnd
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalColorShiftTop = Lighting.ColorShift_Top
local originalColorShiftBottom = Lighting.ColorShift_Bottom

WorldSection:AddToggle({
    Name = "Fullbright",
    Flag = "World_Fullbright",
    Callback = function(state)
        if fullbrightConnection then
            fullbrightConnection:Disconnect()
            fullbrightConnection = nil
        end
        
        if state then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 100000
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
            Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
            
            fullbrightConnection = RunService.RenderStepped:Connect(function()
                if not library or not library.Flags or not library.Flags["World_Fullbright"] then return end
                Lighting.Brightness = 2
                Lighting.GlobalShadows = false
            end)
        else
            Lighting.Brightness = originalBrightness
            Lighting.GlobalShadows = originalShadows
            Lighting.FogEnd = originalFogEnd
            Lighting.Ambient = originalAmbient
            Lighting.OutdoorAmbient = originalOutdoorAmbient
            Lighting.ColorShift_Top = originalColorShiftTop
            Lighting.ColorShift_Bottom = originalColorShiftBottom
        end
    end
})

WorldSection:AddSlider({
    Name = "Brightness",
    Flag = "World_Brightness",
    Value = 1,
    Min = 0,
    Max = 5,
    Format = function(v) return "Brightness: " .. v end,
    Callback = function(v)
        if not library or not library.Flags or not library.Flags["World_Fullbright"] then
            Lighting.Brightness = v
        end
    end
})

WorldSection:AddToggle({
    Name = "Shadows",
    Flag = "World_Shadows",
    Value = true,
    Callback = function(v)
        Lighting.GlobalShadows = v
    end
})

WorldSection:AddSlider({
    Name = "Fog Distance",
    Flag = "World_FogEnd",
    Value = 100000,
    Min = 0,
    Max = 100000,
    Format = function(v) 
        if v >= 100000 then return "Fog: Disabled"
        else return "Fog: " .. v .. " studs" end
    end,
    Callback = function(v)
        Lighting.FogEnd = v
    end
})

WorldSection:AddSlider({
    Name = "Clock Time",
    Flag = "World_ClockTime",
    Value = 12,
    Min = 0,
    Max = 24,
    Format = function(v) 
        local hour = math.floor(v)
        local minute = (v - hour) * 60
        return string.format("Time: %02d:%02d", hour, minute)
    end,
    Callback = function(v)
        Lighting.ClockTime = v
    end
})

WorldSection:AddSlider({
    Name = "Geographic Latitude",
    Flag = "World_GeographicLatitude",
    Value = 41.7,
    Min = -90,
    Max = 90,
    Format = function(v) return "Latitude: " .. v .. "°" end,
    Callback = function(v)
        Lighting.GeographicLatitude = v
    end
})

-- =====================
-- CHAMS SETTINGS (IN ESP TAB)
-- =====================
local ChamsSection = ESPTab:CreateSection({ Name = "Player Chams" })

local chamsConnection
local chamsInstances = {}

local function UpdateChams()
    pcall(function()
        for _, cham in pairs(chamsInstances) do
            if cham then cham:Destroy() end
        end
    end)
    chamsInstances = {}
    
    if not library or not library.Flags or not library.Flags["Chams_Enabled"] then return end
    
    local fillColor = library.Flags["Chams_FillColor"] or Color3.fromRGB(40, 119, 208)
    local outlineColor = library.Flags["Chams_OutlineColor"] or Color3.fromRGB(0, 0, 0)
    local fillTrans = library.Flags["Chams_FillTransparency"] or 0.3
    local outlineTrans = library.Flags["Chams_OutlineTransparency"] or 0.5
    local visibleMode = library.Flags["Chams_VisibleMode"] or "AlwaysOnTop"
    local occludedMode = library.Flags["Chams_OccludedMode"] or "AlwaysOnTop"
    local teamCheck = library.Flags["Chams_TeamCheck"] or false
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Client then continue end
        if teamCheck and player.Team and Client.Team and player.Team == Client.Team then continue end
        
        local char = player.Character
        if char then
            pcall(function()
                -- Visible chams
                local visibleCham = Instance.new("Highlight")
                visibleCham.Name = "ChamHighlight"
                visibleCham.Parent = char
                visibleCham.FillColor = fillColor
                visibleCham.OutlineColor = outlineColor
                visibleCham.FillTransparency = fillTrans
                visibleCham.OutlineTransparency = outlineTrans
                visibleCham.DepthMode = visibleMode == "AlwaysOnTop" and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                table.insert(chamsInstances, visibleCham)
                
                -- Occluded chams
                if library.Flags["Chams_Occluded"] then
                    local occludedCham = Instance.new("Highlight")
                    occludedCham.Name = "ChamHighlight"
                    occludedCham.Parent = workspace
                    occludedCham.Adornee = char
                    occludedCham.FillColor = library.Flags["Chams_OccludedColor"] or fillColor
                    occludedCham.OutlineColor = outlineColor
                    occludedCham.FillTransparency = library.Flags["Chams_OccludedTransparency"] or 0.1
                    occludedCham.OutlineTransparency = outlineTrans
                    occludedCham.DepthMode = occludedMode == "AlwaysOnTop" and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                    table.insert(chamsInstances, occludedCham)
                end
            end)
        end
    end
end

ChamsSection:AddToggle({
    Name = "Enable Chams",
    Flag = "Chams_Enabled",
    Callback = function(state)
        UpdateChams()
        
        if state then
            if chamsConnection then chamsConnection:Disconnect() end
            chamsConnection = Players.PlayerAdded:Connect(function()
                task.wait(0.5)
                UpdateChams()
            end)
        else
            if chamsConnection then
                chamsConnection:Disconnect()
                chamsConnection = nil
            end
            pcall(function()
                for _, cham in pairs(chamsInstances) do
                    if cham then cham:Destroy() end
                end
            end)
            chamsInstances = {}
        end
    end
})

ChamsSection:AddToggle({
    Name = "Team Check",
    Flag = "Chams_TeamCheck",
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddToggle({
    Name = "Occluded Chams",
    Flag = "Chams_Occluded",
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddColorpicker({
    Name = "Fill Color",
    Flag = "Chams_FillColor",
    Value = Color3.fromRGB(40, 119, 208),
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddColorpicker({
    Name = "Outline Color",
    Flag = "Chams_OutlineColor",
    Value = Color3.fromRGB(0, 0, 0),
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddColorpicker({
    Name = "Occluded Color",
    Flag = "Chams_OccludedColor",
    Value = Color3.fromRGB(176, 221, 22),
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddSlider({
    Name = "Fill Transparency",
    Flag = "Chams_FillTransparency",
    Value = 0.3,
    Min = 0,
    Max = 1,
    Format = function(v) return "Transparency: " .. math.floor(v * 100) .. "%" end,
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddSlider({
    Name = "Outline Transparency",
    Flag = "Chams_OutlineTransparency",
    Value = 0.5,
    Min = 0,
    Max = 1,
    Format = function(v) return "Transparency: " .. math.floor(v * 100) .. "%" end,
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddSlider({
    Name = "Occluded Transparency",
    Flag = "Chams_OccludedTransparency",
    Value = 0.1,
    Min = 0,
    Max = 1,
    Format = function(v) return "Transparency: " .. math.floor(v * 100) .. "%" end,
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddDropdown({
    Name = "Visible Mode",
    Flag = "Chams_VisibleMode",
    List = {"AlwaysOnTop", "Occluded"},
    Value = "AlwaysOnTop",
    Callback = function()
        UpdateChams()
    end
})

ChamsSection:AddDropdown({
    Name = "Occluded Mode",
    Flag = "Chams_OccludedMode",
    List = {"AlwaysOnTop", "Occluded"},
    Value = "AlwaysOnTop",
    Callback = function()
        UpdateChams()
    end
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    UpdateChams()
end)

Players.PlayerRemoving:Connect(function()
    UpdateChams()
end)

-- =====================
--     EXPLOITS TAB
-- =====================
local ExploitsTab = PepsisWorld:CreateTab({ Name = "Exploits" })

-- Shared exploit variables
local LP = Players.LocalPlayer
local teamCheckEnabled = false

-- Helper: get valid targets
local function getValidTargets()
    local valid = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player == LP then continue end
        if teamCheckEnabled then
            if LP.Team and player.Team and LP.Team == player.Team then continue end
        end
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health and hum.Health > 0 and root then
                table.insert(valid, player)
            end
        end
    end
    return valid
end

local function getClosestPlayer()
    local targets = getValidTargets()
    if #targets == 0 then return nil end
    local localRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    local closest, closestDist = nil, math.huge
    for _, player in pairs(targets) do
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (localRoot.Position - root.Position).Magnitude
            if dist < closestDist then closestDist = dist closest = player end
        end
    end
    return closest
end

-- =====================
-- SPINBOT
-- =====================
local spinbotConnection
local SpinSection = ExploitsTab:CreateSection({ Name = "Spinbot" })

SpinSection:AddToggle({
    Name = "Spinbot",
    Flag = "Exploit_Spinbot",
    Callback = function(state)
        if spinbotConnection then 
            spinbotConnection:Disconnect() 
            spinbotConnection = nil 
        end
        if not state then return end
        local t = 0
        spinbotConnection = RunService.RenderStepped:Connect(function(dt)
            t = t + dt
            if not library or not library.Flags or not library.Flags["Exploit_Spinbot"] then return end
            local char = LP.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local speed = library.Flags["Exploit_SpinSpeed"] or 50
                local wobble = math.sin(t * 2) * math.rad(speed * 0.1)
                root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed) + wobble, 0)
            end
        end)
    end
})

SpinSection:AddSlider({
    Name = "Spin Speed", Flag = "Exploit_SpinSpeed", Value = 50, Min = 1, Max = 360,
    Format = function(v) return "Speed: " .. v end
})

SpinSection:AddToggle({
    Name = "Team Check", Flag = "Exploit_TeamCheck",
    Callback = function(v) teamCheckEnabled = v end
})

-- =====================
-- HEAD TILT (YAW)
-- =====================
local originalNeckCF = {}
local originalWaistCF = {}

local function resetHeadTilt(character)
    if not character then return end
    pcall(function()
        if originalNeckCF[character] then
            local head = character:FindFirstChild("Head")
            if head then
                local neck = head:FindFirstChild("Neck")
                if neck then neck.C0 = originalNeckCF[character] end
            end
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            if torso then
                local neck = torso:FindFirstChild("Neck")
                if neck then neck.C0 = originalNeckCF[character] end
                local waist = torso:FindFirstChild("Waist")
                if waist and originalWaistCF[character] then waist.C0 = originalWaistCF[character] end
            end
        end
    end)
    originalNeckCF[character] = nil
    originalWaistCF[character] = nil
end

local function applyHeadTilt(character)
    if not character then return end
    if not library or not library.Flags then return end
    
    local yawEnabled = library.Flags["Exploit_YawEnabled"]
    local yawType = library.Flags["Exploit_YawDirection"] or "None"
    local yawAmount = library.Flags["Exploit_YawAmount"] or 60

    if not yawEnabled or yawType == "None" then
        resetHeadTilt(character) 
        return
    end
    
    resetHeadTilt(character)

    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local angle = yawType == "Up" and math.rad(yawAmount) or math.rad(-yawAmount)
    local secondaryAngle = yawType == "Up" and math.rad(yawAmount * 0.3) or math.rad(-yawAmount * 0.3)

    pcall(function()
        if hum.RigType == Enum.HumanoidRigType.R15 then
            local head = character:FindFirstChild("Head")
            if head then
                local neck = head:FindFirstChild("Neck")
                if neck then
                    originalNeckCF[character] = neck.C0
                    neck.C0 = neck.C0 * CFrame.Angles(angle, 0, 0)
                end
            end
        else
            local torso = character:FindFirstChild("Torso")
            if torso then
                local neck = torso:FindFirstChild("Neck")
                if neck then
                    originalNeckCF[character] = neck.C0
                    neck.C0 = neck.C0 * CFrame.Angles(angle, 0, 0)
                end
                local waist = torso:FindFirstChild("Waist")
                if waist then
                    originalWaistCF[character] = waist.C0
                    waist.C0 = waist.C0 * CFrame.Angles(secondaryAngle, 0, 0)
                end
            end
        end
    end)
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applyHeadTilt(char)
end)
if LP.Character then applyHeadTilt(LP.Character) end

local YawSection = ExploitsTab:CreateSection({ Name = "Head Tilt" })

YawSection:AddToggle({
    Name = "Enabled", Flag = "Exploit_YawEnabled",
    Callback = function(v)
        if LP.Character then
            if v then applyHeadTilt(LP.Character)
            else resetHeadTilt(LP.Character) end
        end
    end
})

YawSection:AddDropdown({
    Name = "Direction", Flag = "Exploit_YawDirection",
    List = {"None", "Up", "Down"}, Value = "None",
    Callback = function()
        if LP.Character then applyHeadTilt(LP.Character) end
    end
})

YawSection:AddSlider({
    Name = "Tilt Amount", Flag = "Exploit_YawAmount", Value = 60, Min = 5, Max = 90,
    Format = function(v) return "Degrees: " .. v end,
    Callback = function()
        if LP.Character and library and library.Flags and library.Flags["Exploit_YawEnabled"] then
            applyHeadTilt(LP.Character)
        end
    end
})

-- =====================
-- TELEPORT TO PLAYER
-- =====================
local teleportToConnection
local teleportTarget = nil
local TeleportToSection = ExploitsTab:CreateSection({ Name = "Teleport To Player" })

TeleportToSection:AddToggle({
    Name = "Enabled", Flag = "Exploit_TeleportToEnabled",
    Callback = function(state)
        if teleportToConnection then 
            teleportToConnection:Disconnect() 
            teleportToConnection = nil 
        end
        if not state then teleportTarget = nil return end
        local lastTeleport = 0
        teleportToConnection = RunService.Heartbeat:Connect(function()
            if not library or not library.Flags or not library.Flags["Exploit_TeleportToEnabled"] then return end
            local localChar = LP.Character
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            if not teleportTarget then
                teleportTarget = getClosestPlayer()
            else
                local stillValid = false
                for _, p in pairs(getValidTargets()) do
                    if p == teleportTarget then stillValid = true break end
                end
                if not stillValid then teleportTarget = getClosestPlayer() end
            end

            if not teleportTarget or not teleportTarget.Character then return end
            local targetRoot = teleportTarget.Character:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end

            local now = tick()
            if now - lastTeleport < 0.1 then return end
            lastTeleport = now

            local pos = library.Flags["Exploit_TeleportToPosition"] or "Behind"
            local dist = library.Flags["Exploit_TeleportToDist"] or 5
            local cf

            if pos == "Behind" then
                cf = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * dist)
            elseif pos == "Above" then
                cf = CFrame.new(targetRoot.Position + Vector3.new(0, dist, 0))
            elseif pos == "Left" then
                cf = CFrame.new(targetRoot.Position - targetRoot.CFrame.RightVector * dist)
            elseif pos == "Right" then
                cf = CFrame.new(targetRoot.Position + targetRoot.CFrame.RightVector * dist)
            elseif pos == "Inside" then
                cf = targetRoot.CFrame
            end

            if cf then localRoot.CFrame = cf end
        end)
    end
})

TeleportToSection:AddDropdown({
    Name = "Position", Flag = "Exploit_TeleportToPosition",
    List = {"Behind", "Above", "Left", "Right", "Inside"}, Value = "Behind"
})

TeleportToSection:AddSlider({
    Name = "Distance", Flag = "Exploit_TeleportToDist", Value = 5, Min = 2, Max = 50,
    Format = function(v) return "Distance: " .. v end
})

-- =====================
-- TELEPORT EVERYONE TO ME
-- =====================
local teleportEveryoneConnection
local TeleportEveryoneSection = ExploitsTab:CreateSection({ Name = "Teleport Everyone To Me" })

TeleportEveryoneSection:AddToggle({
    Name = "Enabled", Flag = "Exploit_TeleportEveryoneEnabled",
    Callback = function(state)
        if teleportEveryoneConnection then 
            teleportEveryoneConnection:Disconnect() 
            teleportEveryoneConnection = nil 
        end
        if not state then return end
        local t = 0
        teleportEveryoneConnection = RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if not library or not library.Flags or not library.Flags["Exploit_TeleportEveryoneEnabled"] then return end
            local localChar = LP.Character
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            for _, player in pairs(getValidTargets()) do
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local dist = library.Flags["Exploit_TeleportEveryoneDist"] or 5
                    local swirlAngle = t * 2 + (player.UserId % 10)
                    local swirlOffset = Vector3.new(
                        math.cos(swirlAngle) * 3,
                        math.sin(t * 3 + player.UserId) * 2,
                        math.sin(swirlAngle) * 3
                    )
                    local teleportPos = localRoot.Position + (localRoot.CFrame.LookVector * dist) + swirlOffset
                    targetRoot.CFrame = CFrame.new(teleportPos, localRoot.Position)
                end
            end
        end)
    end
})

TeleportEveryoneSection:AddSlider({
    Name = "Distance", Flag = "Exploit_TeleportEveryoneDist", Value = 5, Min = 2, Max = 100,
    Format = function(v) return "Distance: " .. v end
})

-- =====================
-- PLAYER MAGNET
-- =====================
local magnetConnection
local MagnetSection = ExploitsTab:CreateSection({ Name = "Player Magnet" })

MagnetSection:AddToggle({
    Name = "Enabled", Flag = "Exploit_MagnetEnabled",
    Callback = function(state)
        if magnetConnection then 
            magnetConnection:Disconnect() 
            magnetConnection = nil 
        end
        if not state then return end
        local t = 0
        magnetConnection = RunService.Heartbeat:Connect(function(dt)
            t = t + dt
            if not library or not library.Flags or not library.Flags["Exploit_MagnetEnabled"] then return end
            local localChar = LP.Character
            if not localChar then return end
            local localRoot = localChar:FindFirstChild("HumanoidRootPart")
            if not localRoot then return end

            local centerPos = localRoot.Position
            local strength = library.Flags["Exploit_MagnetStrength"] or 50
            local gravityMode = library.Flags["Exploit_MagnetGravity"]
            local vortexMode = library.Flags["Exploit_MagnetVortex"]
            local vortexStrength = library.Flags["Exploit_MagnetVortexStrength"] or 10
            local vortexRot = library.Flags["Exploit_MagnetVortexRotation"] or 30
            local swingAmt = library.Flags["Exploit_MagnetSwing"] or 3

            for _, player in pairs(getValidTargets()) do
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local direction = (centerPos - targetRoot.Position).Unit
                    local distance = (centerPos - targetRoot.Position).Magnitude

                    if vortexMode then
                        local vortexAngle = math.atan2(targetRoot.Position.Z - centerPos.Z, targetRoot.Position.X - centerPos.X)
                        local vortexForce = Vector3.new(
                            math.cos(vortexAngle + t * vortexRot),
                            0,
                            math.sin(vortexAngle + t * vortexRot)
                        ) * vortexStrength
                        targetRoot.CFrame = targetRoot.CFrame + vortexForce * dt
                    end

                    if gravityMode then
                        local forceMultiplier = strength / math.max(distance * distance * 0.1, 1)
                        local swingOffset = Vector3.new(
                            math.sin(t * 2 + player.UserId) * swingAmt,
                            math.cos(t * 1.5 + player.UserId) * swingAmt * 0.5,
                            math.cos(t * 2 + player.UserId) * swingAmt
                        ) * 0.1
                        targetRoot.CFrame = targetRoot.CFrame + (direction * forceMultiplier + swingOffset) * dt * 60
                    else
                        local forceMultiplier = strength / math.max(distance, 10)
                        if distance > 5 then
                            targetRoot.CFrame = targetRoot.CFrame + direction * forceMultiplier
                        end
                    end
                end
            end
        end)
    end
})

MagnetSection:AddSlider({
    Name = "Strength", Flag = "Exploit_MagnetStrength", Value = 50, Min = 1, Max = 100,
    Format = function(v) return "Strength: " .. v end
})

MagnetSection:AddToggle({ Name = "Gravity Mode",  Flag = "Exploit_MagnetGravity" })
MagnetSection:AddToggle({ Name = "Vortex Effect",  Flag = "Exploit_MagnetVortex" })

MagnetSection:AddSlider({
    Name = "Swing Amount", Flag = "Exploit_MagnetSwing", Value = 3, Min = 0, Max = 10,
    Format = function(v) return "Swing: " .. v end
})
MagnetSection:AddSlider({
    Name = "Vortex Strength", Flag = "Exploit_MagnetVortexStrength", Value = 10, Min = 1, Max = 50,
    Format = function(v) return "Vortex: " .. v end
})
MagnetSection:AddSlider({
    Name = "Vortex Rotation", Flag = "Exploit_MagnetVortexRotation", Value = 30, Min = 1, Max = 100,
    Format = function(v) return "Rotation: " .. v end
})
