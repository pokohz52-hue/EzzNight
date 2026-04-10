-- ==========================================
--  E Z Z  N I G H T  v2.3 (Minimize Feature)
-- ==========================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Чистка
if CoreGui:FindFirstChild("EzzNight") then CoreGui.EzzNight:Destroy() end

local COLORS = {
    Bg = Color3.fromRGB(240, 235, 230),
    Accent = Color3.fromRGB(200, 190, 185),
    Pink = Color3.fromRGB(255, 182, 193),
    Text = Color3.fromRGB(60, 50, 45),
    Button = Color3.fromRGB(255, 250, 250)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EzzNight"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = COLORS.Bg
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
MainFrame.Size = UDim2.new(0, 220, 0, 320) -- Стандартный размер
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true -- Чтобы скрытые кнопки не вылазили при сворачивании

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = COLORS.Accent
Stroke.Thickness = 1.5
Stroke.Parent = MainFrame

-- ЗАГОЛОВОК (Теперь это кнопка для сворачивания)
local TitleButton = Instance.new("TextButton")
TitleButton.Name = "TitleButton"
TitleButton.Parent = MainFrame
TitleButton.Size = UDim2.new(1, 0, 0, 50)
TitleButton.BackgroundTransparency = 1
TitleButton.Text = "" -- Текст выводим отдельно для красоты

local KittenIcon = Instance.new("ImageLabel")
KittenIcon.Parent = TitleButton
KittenIcon.Position = UDim2.new(0, 10, 0.5, -18)
KittenIcon.Size = UDim2.new(0, 36, 0, 36)
KittenIcon.Image = "rbxassetid://13197116819"
KittenIcon.BackgroundTransparency = 1
Instance.new("UICorner", KittenIcon).CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel")
TitleText.Parent = TitleButton
TitleText.Position = UDim2.new(0, 55, 0, 0)
TitleText.Size = UDim2.new(1, -55, 1, 0)
TitleText.Text = "E Z Z  N I G H T"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextColor3 = COLORS.Text
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

local AuthorLabel = Instance.new("TextLabel")
AuthorLabel.Parent = MainFrame
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.Position = UDim2.new(0, 0, 1, -22)
AuthorLabel.Size = UDim2.new(1, -12, 0, 20)
AuthorLabel.Font = Enum.Font.GothamMedium
AuthorLabel.Text = "Сделал @MrFixTop"
AuthorLabel.TextColor3 = COLORS.Text
AuthorLabel.TextSize = 10
AuthorLabel.TextXAlignment = Enum.TextXAlignment.Right
AuthorLabel.TextTransparency = 0.4

local List = Instance.new("ScrollingFrame")
List.Parent = MainFrame
List.Position = UDim2.new(0, 10, 0, 55)
List.Size = UDim2.new(1, -20, 1, -80)
List.BackgroundTransparency = 1
List.CanvasSize = UDim2.new(0, 0, 1.3, 0)
List.ScrollBarThickness = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 8)

-- ==========================================
-- ЛОГИКА СВОРАЧИВАНИЯ
-- ==========================================
local minimized = false
TitleButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Сворачиваем: меняем только высоту фрейма, скрываем список
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 50), "Out", "Quart", 0.3, true)
        List.Visible = false
        AuthorLabel.Visible = false
    else
        -- Разворачиваем
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 320), "Out", "Quart", 0.3, true)
        task.wait(0.1) -- Небольшая задержка для красоты
        List.Visible = true
        AuthorLabel.Visible = true
    end
end)

-- ФУНКЦИИ (БЕЗ ИЗМЕНЕНИЙ)
local function CreateToggle(text, callback)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = COLORS.Button
    btn.Text = "😿 " .. text .. ": OFF"
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = COLORS.Text
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.BackgroundColor3 = active and COLORS.Pink or COLORS.Button
        btn.Text = active and "😸 " .. text .. ": ON" or "😿 " .. text .. ": OFF"
        callback(active)
    end)
end

local function CreateAction(text, color, callback)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = color
    btn.Text = "🐾 " .. text
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(callback)
end

-- ЛОГИКА ЧИТОВ
local function Collect(name_part)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(name_part) and (obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart)) then
            local p = obj:IsA("BasePart") and obj or obj.PrimaryPart
            if not p.Anchored then p.CFrame = root.CFrame + Vector3.new(0, 5, 0) end
        end
    end
end

local flyVal, flyGyro, flying
local function HandleFly(state)
    flying = state
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if flying and root then
        flyVal = Instance.new("BodyVelocity", root)
        flyVal.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyGyro = Instance.new("BodyGyro", root)
        flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flying do
                flyVal.Velocity = workspace.CurrentCamera.CFrame.LookVector * 50
                flyGyro.CFrame = workspace.CurrentCamera.CFrame
                task.wait()
            end
        end)
    else
        if flyVal then flyVal:Destroy() end
        if flyGyro then flyGyro:Destroy() end
    end
end

-- НАПОЛНЕНИЕ
CreateToggle("Immortal Mode", function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.MaxHealth = state and math.huge or 100 hum.Health = hum.MaxHealth end
end)
CreateToggle("Kitten Fly", HandleFly)
CreateToggle("Fast Nights", function(state)
    _G.EzzNightLoop = state
    task.spawn(function() while _G.EzzNightLoop do Lighting.ClockTime = Lighting.ClockTime + 0.1 task.wait(0.02) end end)
end)
CreateAction("Get Metal/Iron", Color3.fromRGB(130, 130, 140), function()
    Collect("iron") Collect("metal") Collect("scrap")
end)
CreateAction("Get Wood/Log", Color3.fromRGB(150, 120, 100), function()
    Collect("wood") Collect("log")
end)

game.StarterGui:SetCore("SendNotification", {Title = "Ezz Night", Text = "Нажми на заголовок, чтобы свернуть!", Duration = 5})

