-- ==========================================
--  E Z Z  F L I C K  v19.0 [AUTO-BUTTON]
--  Feature: Auto-Clicker for Lobby Buttons
--  Aim: Snappy Jitter + God Prediction
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local Settings = {
    Active = false,
    Shoot = false,
    FOV = 450,
    Prediction = 0.18,
    AutoClick = true, -- Авто-нажатие кнопок
    ESP = true
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- [ УМНЫЙ ПОИСК И КЛИК ПО КНОПКЕ ]
local function ClickLobbyButtons()
    if not Settings.AutoClick then return end
    
    -- Ищем по всем GUI игрока
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, btn in pairs(gui:GetDescendants()) do
                if btn:IsA("TextButton") and btn.Visible and btn.TextBounds.X > 0 then
                    local text = btn.Text:lower()
                    -- Список триггеров для нажатия
                    if text:find("play") or text:find("start") or text:find("spawn") or 
                       text:find("играть") or text:find("начать") or text:find("готов") or 
                       text:find("ready") then
                        
                        -- Кликаем в центр кнопки
                        local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
                        VIM:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, true, game, 0)
                        VIM:SendMouseButtonEvent(pos.X, pos.Y + 36, 0, false, game, 0)
                    end
                end
            end
        end
    end
end

-- [ ПРОВЕРКА ВИДИМОСТИ ]
local function IsVisible(part)
    if not part or not part.Parent then return false end
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local res = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
    return res == nil
end

-- [ ГЛАВНЫЙ ЦИКЛ ]
RunService.RenderStepped:Connect(function()
    if not Settings.Active then return end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    -- 1. ЛОГИКА ЛОББИ (Если нет персонажа или ХП на нуле)
    if not hum or hum.Health <= 0 then
        ClickLobbyButtons()
        return 
    end

    -- 2. ПОИСК ЦЕЛИ (AIMBOT)
    local target = nil
    local minDist = Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local _, vis = Camera:WorldToViewportPoint(head.Position)
            if vis and IsVisible(head) then
                local mag = (head.Position - root.Position).Magnitude
                if mag < minDist then target = head; minDist = mag end
            end
        end
    end

    -- 3. ПОВЕДЕНИЕ В БОЮ
    if target then
        local vel = target.Parent.HumanoidRootPart.Velocity
        local predPos = target.Position + (vel * Settings.Prediction)
        local jitter = Vector3.new(math.random(-2,2), math.random(-2,2), math.random(-2,2))/45
        
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predPos + jitter), 0.25)
        
        if Settings.Shoot then
            VIM:SendMouseButtonEvent(0,0,0,true,game,0)
            VIM:SendMouseButtonEvent(0,0,0,false,game,0)
        end
        hum:Move(root.CFrame:VectorToObjectSpace((target.Position - root.Position).Unit), true)
    else
        -- Если боя нет, всё равно проверяем кнопки (вдруг вылезло меню)
        ClickLobbyButtons()
        
        -- Свободное движение (Лидар)
        rayParams.FilterDescendantsInstances = {char}
        local wall = workspace:Raycast(root.Position, root.CFrame.LookVector * 6, rayParams)
        if wall then 
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(45), 0)
        end
    end

    -- ESP (Перевернутые ромбы)
    if Settings.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if not p.Character:FindFirstChild("EzzDiamond") then
                    local b = Instance.new("BillboardGui", p.Character)
                    b.Name = "EzzDiamond"; b.Size = UDim2.new(3,0,3,0); b.AlwaysOnTop = true
                    local f = Instance.new("Frame", b)
                    f.Size = UDim2.new(0.5,0,0.5,0); f.Position = UDim2.new(0.25,0,0.25,0); f.Rotation = 45; f.BackgroundColor3 = Color3.new(1,0,0.2)
                    Instance.new("UIStroke", f).Color = Color3.new(1,1,1)
                end
            end
        end
    end
end)

-- [ ИНТЕРФЕЙС ]
if CoreGui:FindFirstChild("EzzClickV19") then CoreGui.EzzClickV19:Destroy() end
local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "EzzClickV19"
local m = Instance.new("Frame", sg)
m.Size = UDim2.new(0, 200, 0, 250); m.Position = UDim2.new(0.5, -100, 0.5, -125); m.BackgroundColor3 = Color3.new(0,0,0)
Instance.new("UIStroke", m).Color = Color3.fromRGB(0, 255, 120)

local l = Instance.new("Frame", m); l.Position = UDim2.new(0,10,0,45); l.Size = UDim2.new(1,-20,1,-55); l.BackgroundTransparency = 1
Instance.new("UIListLayout", l).Padding = UDim.new(0,5)

local function AddT(txt, f)
    local b = Instance.new("TextButton", l); b.Size = UDim2.new(1,0,0,40); b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.Text = txt .. ": OFF"; b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function()
        Settings[f] = not Settings[f]
        b.Text = txt .. (Settings[f] and ": ON" or ": OFF")
        b.BackgroundColor3 = Settings[f] and Color3.fromRGB(0, 150, 80) or Color3.new(0.1,0.1,0.1)
    end)
end

AddT("AI ACTIVE", "Active")
AddT("AUTO-SHOOT", "Shoot")
AddT("AUTO-CLICK", "AutoClick")
AddT("DIAMOND ESP", "ESP")

-- Drag
local d, s, p
m.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true s = i.Position p = m.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s m.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function() d = false end)
