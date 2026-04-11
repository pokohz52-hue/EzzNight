-- ==========================================
--  E Z Z  F L I C K  (MODDED VERSION)
--  Оригинал: @MrFixTop
--  Функции: Speed, Fly, TP Items, Explore
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
    Speed = 16,
    Fly = false,
    Explore = false,
    FOV = 250,
    Smoothing = 0.35,
    Color = Color3.fromRGB(0, 255, 0),
    TG_Link = "https://t.me/buypass_script"
}

if CoreGui:FindFirstChild("EzzFlick") then CoreGui.EzzFlick:Destroy() end

local function Notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
end

-- [ ИНТЕРФЕЙС ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EzzFlick"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 420) -- Увеличил размер под новые кнопки
Main.Position = UDim2.new(0.5, -110, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UIStroke", Main).Color = Settings.Color

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | MODDED"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 13

-- ОКНО СПЕКТАТОРОВ
local SpecFrame = Instance.new("Frame", ScreenGui)
SpecFrame.Size = UDim2.new(0, 180, 0, 100)
SpecFrame.Position = UDim2.new(0, 20, 0.5, -50)
SpecFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SpecFrame.BorderSizePixel = 0
SpecFrame.Visible = Settings.SpecAlert
Instance.new("UIStroke", SpecFrame).Color = Color3.fromRGB(255, 0, 0)

local SpecTitle = Instance.new("TextLabel", SpecFrame)
SpecTitle.Size = UDim2.new(1, 0, 0, 25)
SpecTitle.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
SpecTitle.Text = "SPECTATING YOU:"
SpecTitle.TextColor3 = Color3.new(1, 1, 1)
SpecTitle.Font = Enum.Font.SourceSansBold
SpecTitle.TextSize = 14

local SpecList = Instance.new("TextLabel", SpecFrame)
SpecList.Size = UDim2.new(1, -10, 1, -30)
SpecList.Position = UDim2.new(0, 5, 0, 30)
SpecList.BackgroundTransparency = 1
SpecList.Text = "Nobody"
SpecList.TextColor3 = Color3.new(0.8, 0.8, 0.8)
SpecList.Font = Enum.Font.SourceSans
SpecList.TextSize = 14
SpecList.TextYAlignment = Enum.TextYAlignment.Top

local List = Instance.new("ScrollingFrame", Main) -- Сделал список прокручиваемым
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -55)
List.BackgroundTransparency = 1
List.CanvasSize = UDim2.new(0, 0, 0, 450)
List.ScrollBarThickness = 2
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ЛОГИКА ]
local function GetSpectators()
    local spectators = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and not p.Character then
             table.insert(spectators, p.Name)
        end
    end
    SpecList.Text = #spectators == 0 and "Nobody" or table.concat(spectators, "\n")
end

-- [ ФУНКЦИИ ]
local function CreateToggle(text, field, callback)
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
        if callback then callback(Settings[field]) end
    end)
end

-- 1. Спидхак через ползунок (имитация "ускоренного времени")
local SpeedBtn = Instance.new("TextButton", List)
SpeedBtn.Size = UDim2.new(1, 0, 0, 32)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBtn.Text = "Speed: 16"
SpeedBtn.TextColor3 = Color3.new(1, 1, 1)
SpeedBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 4)
SpeedBtn.MouseButton1Click:Connect(function()
    if Settings.Speed == 16 then Settings.Speed = 100 else Settings.Speed = 16 end
    SpeedBtn.Text = "Speed: " .. tostring(Settings.Speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Speed
    end
end)

-- 2. Флай
CreateToggle("Fly Mode", "Fly", function(state)
    local char = LocalPlayer.Character
    if state and char and char:FindFirstChild("HumanoidRootPart") then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "FlickFly"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        task.spawn(function()
            while Settings.Fly do
                bv.Velocity = Camera.CFrame.LookVector * 100
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

-- 3. ТП вещей
local TPBtn = Instance.new("TextButton", List)
TPBtn.Size = UDim2.new(1, 0, 0, 32)
TPBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TPBtn.Text = "Bring Glowing Items"
TPBtn.TextColor3 = Color3.new(1, 1, 1)
TPBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 4)
TPBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("PointLight") or v:IsA("SurfaceLight") then
            if v.Parent:IsA("BasePart") then
                v.Parent.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

-- 4. Исследование
CreateToggle("Auto Explore", "Explore", function(state)
    while Settings.Explore do
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.new(math.random(-150, 150), 0, math.random(-150, 150))
        end
        task.wait(1.5)
    end
end)

-- Твои оригинальные функции
CreateToggle("Sticky Aim", "Aimbot")
CreateToggle("Green ESP", "ESP")
CreateToggle("Spec Names", "SpecAlert")

-- [ ЦИКЛЫ ]
RunService.RenderStepped:Connect(function()
    GetSpectators()
    if Settings.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hi = p.Character:FindFirstChild("EzzHighlight") or Instance.new("Highlight", p.Character)
                hi.Name = "EzzHighlight"
                hi.Enabled = true
                hi.FillColor = Settings.Color
            end
        end
    end
end)

-- Перетаскивание
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

MakeDraggable(Main, Title)
MakeDraggable(SpecFrame, SpecTitle)

Notify("Ezz Flick", "Modded v2.9 Ready!")
