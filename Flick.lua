-- ==========================================
--  E Z Z  F L I C K  v10.5
--  Style: Classic Menu (v3-v5)
--  Fix: No Shooting through walls
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    AI_Active = false,
    AI_Shoot = false,
    Aimbot = false,
    ESP = false,
    FOV = 350,
    Smoothing = 0.15
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- [ ПРОВЕРКА ВИДИМОСТИ (БЕЗ ПРОСТРЕЛА СТЕН) ]
local function IsStrictlyVisible(targetPart)
    if not LocalPlayer.Character then return false end
    
    -- Игнорируем себя и модель цели при проверке луча
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local rayResult = workspace:Raycast(origin, direction, rayParams)
    
    -- Если луч ни во что не врезался до цели — значит путь чист
    return rayResult == nil
end

-- [ УМНАЯ НАВИГАЦИЯ ]
local function GetPath()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart
    
    rayParams.FilterDescendantsInstances = {char}
    local startPos = root.Position + Vector3.new(0, 1, 0)
    
    local bestDist = 0
    local bestDir = nil
    
    -- Сканируем 12 направлений вокруг
    for i = 1, 12 do
        local angle = math.rad((i-1) * 30)
        local dir = (CFrame.Angles(0, angle, 0) * root.CFrame.LookVector).Unit
        local res = workspace:Raycast(startPos, dir * 20, rayParams)
        local d = res and res.Distance or 20
        
        if d > bestDist then
            bestDist = d
            bestDir = dir
        end
    end
    return bestDir, bestDist
end

-- [ ЦИКЛ ОБРАБОТКИ ]
RunService.RenderStepped:Connect(function()
    if not Settings.AI_Active then return end
    
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then 
        -- Респавн (Пробел)
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        return 
    end
    
    local root = char.HumanoidRootPart
    local hum = char.Humanoid

    -- 1. ПОИСК ЦЕЛИ
    local target = nil
    local minDist = Settings.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen and IsStrictlyVisible(head) then
                local screenDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if screenDist < minDist then
                    target = head
                    minDist = screenDist
                end
            end
        end
    end

    -- 2. ЛОГИКА
    if target then
        -- БОЙ: Наводка на видимого врага
        local goal = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(goal, Settings.Smoothing)
        
        if Settings.AI_Shoot then
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        hum:Move(Vector3.new(math.sin(tick()*2), 0, -0.5), true) -- Стрейф
    else
        -- ИССЛЕДОВАНИЕ
        local moveDir, dist = GetPath()
        if moveDir then
            local lookGoal = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + moveDir)
            Camera.CFrame = Camera.CFrame:Lerp(lookGoal, 0.08)
        end
        hum:Move(Vector3.new(0, 0, -1), true)
        
        -- Прыжок только если впереди низкая преграда
        local wall = workspace:Raycast(root.Position, root.CFrame.LookVector * 4, rayParams)
        if wall and dist > 5 then
            local high = workspace:Raycast(root.Position + Vector3.new(0, 4, 0), root.CFrame.LookVector * 4, rayParams)
            if not high then hum.Jump = true end
        end
    end

    -- 3. ESP
    if Settings.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hi = p.Character:FindFirstChild("EzzHigh") or Instance.new("Highlight", p.Character)
                hi.Name = "EzzHigh"; hi.FillColor = Color3.fromRGB(0, 255, 150); hi.Enabled = true
            end
        end
    end
end)

-- [ СТАРОЕ ДОБРОЕ МЕНЮ ]
if CoreGui:FindFirstChild("EzzClassicV10") then CoreGui.EzzClassicV10:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "EzzClassicV10"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 250); Main.Position = UDim2.new(0.5, -100, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true
Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 255, 120)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.BackgroundColor3 = Color3.fromRGB(0, 60, 30)
Title.Text = "EZZ FLICK v10.5 AI"; Title.TextColor3 = Color3.new(1, 1, 1); Title.Font = Enum.Font.SourceSansBold

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45); List.Size = UDim2.new(1, -20, 1, -55); List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

local function AddToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(0, 120, 60) or Color3.fromRGB(30, 30, 30)
    end)
end

AddToggle("ОСОЗНАННЫЙ AI", "AI_Active")
AddToggle("АВТО-СТРЕЛЬБА", "AI_Shoot")
AddToggle("АИМБОТ (LEGIT)", "Aimbot")
AddToggle("ВХ (HIGHLIGHTS)", "ESP")

-- Drag (Перетаскивание)
local d, s, p
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true s = i.Position p = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s Main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function() d = false end)
