-- ==========================================
--  E Z Z  F L I C K  v19.0 (ULTIMATE BOT)
--  New: Auto-Space on Death (2 Jumps)
--  New: Auto-Deploy (2 Clicks)
--  Fix: 360 Rage Aim + Smart Wander
--  Rule: NOTHING DELETED
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
    RainbowGun = false,
    FOV = 5000,
    Smoothing = 0.4
}

local curHue = 0
local wanderAngle = 0
local isDeploying = false 
local isDeadProc = false -- Флаг для авто-прыжка
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- [ ПРОВЕРКА ВИДИМОСТИ ]
local function IsVisible(part)
    if not part or not LocalPlayer.Character then return false end
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local hit = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
    return hit == nil
end

-- [ ПОИСК ЦЕЛИ 360 ]
local function GetRageTarget()
    local target, lastDist = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = p.Character.HumanoidRootPart
            local dist = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if dist < lastDist and IsVisible(rootPart) then
                target = rootPart
                lastDist = dist
            end
        end
    end
    return target
end

-- [ ГЛАВНЫЙ ЦИКЛ ]
RunService.RenderStepped:Connect(function()
    curHue = (curHue + 0.005) % 1
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- === БЛОК АВТО-ПРЫЖКА ПРИ СМЕРТИ (НОВОЕ) ===
    if hum and hum.Health <= 0 and not isDeadProc then
        isDeadProc = true
        task.spawn(function()
            task.wait(0.2)
            for i = 1, 2 do
                VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                task.wait(0.1)
            end
            while hum and hum.Health <= 0 do task.wait() end
            isDeadProc = false
        end)
    end

    -- === БЛОК АВТО-ДЕПЛОЯ ===
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and not isDeploying then
        for _, v in pairs(pGui:GetDescendants()) do
            if v:IsA("TextButton") and v.Visible and (v.Text:lower():find("разместить") or v.Text:lower():find("deploy")) then
                isDeploying = true
                task.spawn(function()
                    local pos = v.AbsolutePosition
                    local size = v.AbsoluteSize
                    for i = 1, 2 do 
                        VIM:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 58, 0, true, game, 0)
                        VIM:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 58, 0, false, game, 0)
                        task.wait(0.1)
                    end
                    task.wait(3) 
                    isDeploying = false
                end)
                break
            end
        end
    end

    if not char or not hum or not root then return end

    local currentTarget = GetRageTarget()

    -- 1. ЛОГИКА АИМА
    if Settings.Aimbot and currentTarget then
        local targetLook = CFrame.new(Camera.CFrame.Position, currentTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetLook, Settings.Smoothing)
        if Settings.AI_Shoot then
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end

    -- 2. ЛОГИКА ДВИЖЕНИЯ И ГУЛЯНИЯ (WANDER)
    if Settings.AI_Active then
        rayParams.FilterDescendantsInstances = {char}
        
        if currentTarget then
            local moveVec = (currentTarget.Position - root.Position).Unit
            local strafe = root.CFrame.RightVector * math.sin(tick() * 7) * 1.2
            hum:Move(moveVec + strafe, false)
        else
            wanderAngle = wanderAngle + (math.noise(tick() * 0.5) * 2) 
            local forward = (root.CFrame * CFrame.Angles(0, math.rad(wanderAngle), 0)).LookVector
            
            local wall = workspace:Raycast(root.Position, forward * 10, rayParams)
            if wall then
                wanderAngle = wanderAngle + 90 
            end
            
            hum:Move(forward, false)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + forward), 0.05)
        end
        
        if workspace:Raycast(root.Position, root.CFrame.LookVector * 5, rayParams) then 
            hum.Jump = true 
        end
    end
end)

-- [ МЕНЮ ]
if CoreGui:FindFirstChild("EzzX") then CoreGui.EzzX:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "EzzX"
local Main = Instance.new("Frame", ScreenGui)
Main.Size, Main.Position = UDim2.new(0, 180, 0, 260), UDim2.new(0.5, -90, 0.4, 0)
Main.BackgroundColor3, Main.Active = Color3.fromRGB(20, 20, 25), true
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 2
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame", Main)
TopBar.Size, TopBar.BackgroundColor3 = UDim2.new(1, 0, 0, 30), Color3.fromRGB(30, 30, 35)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local HideBtn = Instance.new("TextButton", TopBar)
HideBtn.Size, HideBtn.Position, HideBtn.Text = UDim2.new(0, 25, 0, 25), UDim2.new(1, -28, 0, 2.5), "-"
HideBtn.BackgroundColor3, HideBtn.TextColor3 = Color3.fromRGB(40, 40, 45), Color3.new(1,1,1)
Instance.new("UICorner", HideBtn)

local Content = Instance.new("Frame", Main)
Content.Size, Content.Position, Content.BackgroundTransparency = UDim2.new(1, -20, 1, -40), UDim2.new(0, 10, 0, 35), 1
Instance.new("UIListLayout", Content).Padding = UDim.new(0, 5)

local function CreateBtn(text, field)
    local b = Instance.new("TextButton", Content)
    b.Size, b.BackgroundColor3, b.Text, b.TextColor3 = UDim2.new(1, 0, 0, 35), Color3.fromRGB(35, 35, 40), text, Color3.fromRGB(150, 150, 150)
    b.Font, b.TextSize = Enum.Font.GothamSemibold, 11; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        b.TextColor3 = Settings[field] and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(150, 150, 150)
        b.BackgroundColor3 = Settings[field] and Color3.fromRGB(40, 50, 45) or Color3.fromRGB(35, 35, 40)
    end)
end

CreateBtn("УМНЫЙ AI (ГУЛЯТЬ)", "AI_Active")
CreateBtn("АВТО-ВЫСТРЕЛ", "AI_Shoot")
CreateBtn("АИМБОТ (360)", "Aimbot")
CreateBtn("ВХ", "ESP")
CreateBtn("RAINBOW GUN", "RainbowGun")

-- ДРАГ
local d, s, p
TopBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true s = i.Position p = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s Main.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function() d = false end)
HideBtn.MouseButton1Click:Connect(function() Content.Visible = not Content.Visible; Main:TweenSize(Content.Visible and UDim2.new(0, 180, 0, 260) or UDim2.new(0, 180, 0, 30), "Out", "Quad", 0.2, true) end)
RunService.Heartbeat:Connect(function() Stroke.Color = Color3.fromHSV(curHue, 0.8, 1) end)
