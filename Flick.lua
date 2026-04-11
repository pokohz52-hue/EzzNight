-- ==========================================
--  E Z Z  F L I C K  v15.0 [SPIN-SENSE]
--  Logic: Spin-search in tight spaces
--  Focus: 100% Kill Priority over Walls
--  ESP: Reverse Diamond Fix
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Active = false,
    Shoot = false,
    FOV = 500,
    Jitter = 3,
    ESP = true
}

local LockedTarget = nil
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- [ ПРОВЕРКА ВИДИМОСТИ ]
local function IsVisible(part)
    if not part or not part.Parent then return false end
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    local res = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
    return res == nil
end

-- [ ЛИДАР С ДЕТЕКТОРОМ ЗАМКНУТОГО ПРОСТРАНСТВА ]
local function AnalyzeSpace()
    local char = LocalPlayer.Character
    if not char then return nil, 0 end
    local root = char.HumanoidRootPart
    rayParams.FilterDescendantsInstances = {char}
    
    local freeSectors = 0
    local bestDir = root.CFrame.LookVector
    local maxD = 0
    
    for i = 1, 12 do
        local angle = math.rad(i * 30)
        local dir = Vector3.new(math.sin(angle), 0, math.cos(angle))
        local res = workspace:Raycast(root.Position, dir * 15, rayParams)
        local d = res and res.Distance or 15
        
        if d > 10 then freeSectors = freeSectors + 1 end
        if d > maxD then maxD = d; bestDir = dir end
    end
    
    -- Если свободных секторов мало (< 3), значит мы в "квадрате"
    return bestDir, freeSectors
end

-- [ ОБНОВЛЕНИЕ ВХ (РОМБЫ) ]
local function UpdateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local gui = p.Character:FindFirstChild("EzzDiamond")
            if Settings.ESP and p.Character.Humanoid.Health > 0 then
                if not gui then
                    gui = Instance.new("BillboardGui", p.Character)
                    gui.Name = "EzzDiamond"; gui.Size = UDim2.new(3,0,3,0); gui.AlwaysOnTop = true
                    local f = Instance.new("Frame", gui)
                    f.Size = UDim2.new(0.6,0,0.6,0); f.Position = UDim2.new(0.2,0,0.2,0)
                    f.Rotation = 45; f.BackgroundColor3 = Color3.new(1,0,0)
                    f.BackgroundTransparency = 0.4; Instance.new("UIStroke", f).Color = Color3.new(1,1,1)
                end
            elseif gui then gui:Destroy() end
        end
    end
end

-- [ ЦИКЛ ВЫЖИВАНИЯ ]
RunService.RenderStepped:Connect(function()
    if not Settings.Active then return end
    UpdateESP()
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game); task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game); return 
    end
    local root = char.HumanoidRootPart

    -- ПРИОРИТЕТ 1: ПОИСК ИГРОКА (ОТВЛЕКАЕМСЯ ТОЛЬКО НА НИХ)
    if not LockedTarget or not IsVisible(LockedTarget) or LockedTarget.Parent.Humanoid.Health <= 0 then
        LockedTarget = nil
        local minDist = Settings.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local head = p.Character.Head
                if IsVisible(head) then
                    local _, onScr = Camera:WorldToViewportPoint(head.Position)
                    if onScr then
                        local mag = (head.Position - root.Position).Magnitude
                        if mag < minDist then LockedTarget = head; minDist = mag end
                    end
                end
            end
        end
    end

    -- ПРИОРИТЕТ 2: ДЕЙСТВИЕ
    if LockedTarget then
        -- РЕЖИМ УБИЙЦЫ: Плевать на стены, идем к цели
        local jitter = Vector3.new(math.random(-5,5)/10, math.random(-5,5)/10, math.random(-5,5)/10) * Settings.Jitter
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, LockedTarget.Position + jitter), 0.2)
        
        hum:Move(root.CFrame:VectorToObjectSpace((LockedTarget.Position - root.Position).Unit), true)
        if Settings.Shoot then
            VIM:SendMouseButtonEvent(0,0,0,true,game,0); VIM:SendMouseButtonEvent(0,0,0,false,game,0)
        end
    else
        -- РЕЖИМ ПОИСКА / ВЫХОДА ИЗ КВАДРАТА
        local bestPath, sectors = AnalyzeSpace()
        if sectors < 3 then
            -- МЫ В КВАДРАТЕ: Крутимся (Spin-Scan)
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(20), 0)
            hum:Move(Vector3.new(0,0,-1), true)
            hum.Jump = true
        else
            -- ОТКРЫТОЕ ПРОСТРАНСТВО: Идем по лидару
            local targetCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + bestPath)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, 0.1)
            hum:Move(Vector3.new(0,0,-1), true)
        end
    end

    -- Прыжок от затыка
    if workspace:Raycast(root.Position, root.CFrame.LookVector * 4, rayParams) then hum.Jump = true end
end)

-- [ GUI CLASSIC ]
if CoreGui:FindFirstChild("EzzSpinV15") then CoreGui.EzzSpinV15:Destroy() end
local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "EzzSpinV15"
local m = Instance.new("Frame", sg)
m.Size = UDim2.new(0,200,0,200); m.Position = UDim2.new(0.5,-100,0.5,-100); m.BackgroundColor3 = Color3.new(0,0,0)
Instance.new("UIStroke", m).Color = Color3.new(1,0,0)
local l = Instance.new("Frame", m); l.Position = UDim2.new(0,10,0,45); l.Size = UDim2.new(1,-20,1,-55); l.BackgroundTransparency = 1
Instance.new("UIListLayout", l).Padding = UDim.new(0,5)

local function AddT(txt, f)
    local b = Instance.new("TextButton", l); b.Size = UDim2.new(1,0,0,40); b.Text = txt..": OFF"; b.BackgroundColor3 = Color3.new(0.1,0.1,0.1); b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function()
        Settings[f] = not Settings[f]
        b.Text = txt..(Settings[f] and ": ON" or ": OFF")
        b.BackgroundColor3 = Settings[f] and Color3.new(0.5,0,0) or Color3.new(0.1,0.1,0.1)
    end)
end

AddT("ЗАПУСК AI", "Active")
AddT("АВТО-ОГОНЬ", "Shoot")
AddT("ВХ (РОМБЫ)", "ESP")

-- Drag
local d, s, p
m.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true s = i.Position p = m.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local delta = i.Position - s m.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function() d = false end)
