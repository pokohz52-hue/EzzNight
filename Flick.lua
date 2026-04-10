-- ==========================================
--  E Z Z  F L I C K  v2.8 (TG UPDATE)
--  Сделал @MrFixTop | TG: @buypass_script
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot = false,
    ESP = false,
    NoRecoil = false,
    SpecAlert = true,
    Hitsound = true,
    FOV = 250,
    Smoothing = 0.35,
    Color = Color3.fromRGB(0, 255, 0),
    TG_Link = "https://t.me/buypass_script"
}

local CurrentTarget = nil
local CurrentPartName = "Head"

if CoreGui:FindFirstChild("EzzFlick") then CoreGui.EzzFlick:Destroy() end

-- [ ФУНКЦИЯ УВЕДОМЛЕНИЙ ]
local function Notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- [ ИНТЕРФЕЙС ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EzzFlick"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 350) -- Чуть увеличил высоту для новой кнопки
Main.Position = UDim2.new(0.5, -110, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UIStroke", Main).Color = Settings.Color

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | v2.8"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 13

local SpecLabel = Instance.new("TextLabel", ScreenGui)
SpecLabel.Size = UDim2.new(0, 200, 0, 30)
SpecLabel.Position = UDim2.new(0.5, -100, 0, 50)
SpecLabel.BackgroundTransparency = 1
SpecLabel.Text = "Spectators: 0"
SpecLabel.TextColor3 = Color3.new(1, 1, 1)
SpecLabel.Font = Enum.Font.SourceSansBold
SpecLabel.TextSize = 18
SpecLabel.Visible = Settings.SpecAlert

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -295)
List.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", List)
Layout.Padding = UDim.new(0, 5)

-- [ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ]
local function PlayHitSound()
    if not Settings.Hitsound then return end
    local s = Instance.new("Sound", game:GetService("SoundService"))
    s.SoundId = "rbxassetid://160432334"
    s.Volume = 2
    s:Play()
    game:GetService("Debris"):AddItem(s, 1)
end

local function IsVisible(part)
    local char = LocalPlayer.Character
    local rayP = RaycastParams.new()
    rayP.FilterType = Enum.RaycastFilterType.Exclude
    rayP.FilterDescendantsInstances = {char, Camera}
    local res = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude, rayP)
    local obs = Camera:GetPartsObscuringTarget({part.Position}, {char, part.Parent})
    return (not res or res.Instance:IsDescendantOf(part.Parent)) and #obs == 0
end

local function GetTarget()
    if CurrentTarget and CurrentTarget.Parent and CurrentTarget.Parent:FindFirstChild("Humanoid") and CurrentTarget.Parent.Humanoid.Health > 0 then
        local p = CurrentTarget.Parent:FindFirstChild(CurrentPartName) or CurrentTarget.Parent:FindFirstChild("Head")
        if p and IsVisible(p) then return p end
    end
    local target, dist = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pName = (math.random(1,100) <= 50) and "Head" or "UpperTorso"
            local part = p.Character:FindFirstChild(pName) or p.Character:FindFirstChild("Head")
            if part and IsVisible(part) then
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then target = part; CurrentPartName = part.Name; dist = mag end
                end
            end
        end
    end
    CurrentTarget = target
    return target
end

-- [ ЦИКЛ ]
RunService.RenderStepped:Connect(function(dt)
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character == nil then count = count + 1 end
    end
    SpecLabel.Text = "SPECTATORS: " .. count
    SpecLabel.TextColor3 = count > 0 and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hi = p.Character:FindFirstChild("EzzHighlight") or Instance.new("Highlight", p.Character)
            hi.Name = "EzzHighlight"
            hi.Enabled = Settings.ESP
            hi.FillColor = Settings.Color
            if p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health <= 0 and p.Character.Head == CurrentTarget then
                PlayHitSound()
                CurrentTarget = nil
            end
        end
    end

    if Settings.NoRecoil then
        local r = Camera:FindFirstChild("Recoil") or Camera:FindFirstChild("Shake")
        if r then r:Destroy() end
    end

    if Settings.Aimbot then
        local t = GetTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Settings.Smoothing * (dt * 60))
        end
    else
        CurrentTarget = nil
    end
end)

-- [ КНОПКИ ]
local function CreateToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
        if field == "SpecAlert" then SpecLabel.Visible = Settings.SpecAlert end
    end)
end

CreateToggle("Sticky Mix Aim", "Aimbot")
CreateToggle("Green ESP", "ESP")
CreateToggle("No Recoil", "NoRecoil")
CreateToggle("Spectator Alert", "SpecAlert")
CreateToggle("Hit Sound", "Hitsound")

-- Кнопка ТГ
local TG_Btn = Instance.new("TextButton", List)
TG_Btn.Size = UDim2.new(1, 0, 0, 35)
TG_Btn.BackgroundColor3 = Color3.fromRGB(0, 136, 204) -- Цвет Telegram
TG_Btn.Text = "ТГК СО СКРИПТАМИ"
TG_Btn.TextColor3 = Color3.new(1, 1, 1)
TG_Btn.Font = Enum.Font.SourceSansBold
TG_Btn.TextSize = 14
Instance.new("UICorner", TG_Btn).CornerRadius = UDim.new(0, 4)

TG_Btn.MouseButton1Click:Connect(function()
    setclipboard(Settings.TG_Link)
    Notify("Telegram", "Ссылка скопирована в буфер обмена!")
end)

-- ПЕРЕТАСКИВАНИЕ И СВОРАЧИВАНИЕ
local dragging, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local min = false
Title.MouseButton1Click:Connect(function()
    if not dragging then
        min = not min
        Main:TweenSize(min and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 350), "Out", "Quart", 0.3, true)
        List.Visible = not min
    end
end)

Notify("Ezz Flick", "v2.8 Успешно запущен!")
