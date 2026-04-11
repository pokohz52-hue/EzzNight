-- ==========================================
--  E Z Z  F L I C K  [CLEAN VERSION]
--  Only: AIMBOT, ESP, SPECTATORS
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot = false,
    ESP = false,
    SpecAlert = true,
    FOV = 250,
    Smoothing = 0.2, -- Поправил плавность
    Color = Color3.fromRGB(0, 255, 0)
}

if CoreGui:FindFirstChild("EzzFlick") then CoreGui.EzzFlick:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EzzFlick"

-- ОСНОВНОЕ МЕНЮ
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 220)
Main.Position = UDim2.new(0.5, -100, 0.5, -110)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UIStroke", Main).Color = Settings.Color

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | LEGIT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14

-- ОКНО СПЕКТАТОРОВ
local SpecFrame = Instance.new("Frame", ScreenGui)
SpecFrame.Size = UDim2.new(0, 180, 0, 100)
SpecFrame.Position = UDim2.new(0, 20, 0.5, -50)
SpecFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SpecFrame.BorderSizePixel = 0
Instance.new("UIStroke", SpecFrame).Color = Color3.fromRGB(255, 0, 0)

local SpecTitle = Instance.new("TextLabel", SpecFrame)
SpecTitle.Size = UDim2.new(1, 0, 0, 25)
SpecTitle.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
SpecTitle.Text = "WATCHING YOU:"
SpecTitle.TextColor3 = Color3.new(1, 1, 1)
SpecTitle.Font = Enum.Font.SourceSansBold

local SpecList = Instance.new("TextLabel", SpecFrame)
SpecList.Size = UDim2.new(1, -10, 1, -30)
SpecList.Position = UDim2.new(0, 5, 0, 30)
SpecList.BackgroundTransparency = 1
SpecList.Text = "Nobody"
SpecList.TextColor3 = Color3.new(0.8, 0.8, 0.8)
SpecList.TextYAlignment = Enum.TextYAlignment.Top

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -55)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ЛОГИКА ]
local function IsVisible(part)
    local obs = Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, part.Parent})
    return #obs == 0
end

local function GetTarget()
    local target, dist = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local part = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis and IsVisible(part) then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then target = part; dist = mag end
                end
            end
        end
    end
    return target
end

-- [ ЦИКЛ ]
RunService.RenderStepped:Connect(function(dt)
    -- Спектаторы
    local specs = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not p.Character then table.insert(specs, p.Name) end
    end
    SpecList.Text = #specs == 0 and "Nobody" or table.concat(specs, "\n")
    SpecFrame.Visible = Settings.SpecAlert

    -- ВХ (ESP)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hi = p.Character:FindFirstChild("EzzHighlight") or Instance.new("Highlight", p.Character)
            hi.Name = "EzzHighlight"
            hi.Enabled = Settings.ESP
            hi.FillColor = Settings.Color
        end
    end

    -- АИМБОТ (Поправленный)
    if Settings.Aimbot then
        local t = GetTarget()
        if t then
            local targetPos = CFrame.new(Camera.CFrame.Position, t.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetPos, Settings.Smoothing)
        end
    end
end)

-- [ КНОПКИ ]
local function AddToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

AddToggle("Aimbot", "Aimbot")
AddToggle("ESP (WH)", "ESP")
AddToggle("Spectators", "SpecAlert")

-- ПЕРЕТАСКИВАНИЕ
local function Drag(f, h)
    local d, i, s, p
    h.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            d = true; s = input.Position; p = f.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if d and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - s
            f.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) d = false end)
end

Drag(Main, Title)
Drag(SpecFrame, SpecTitle)
