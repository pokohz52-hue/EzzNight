-- ==========================================
--  E Z Z  F L I C K  v1.6 (HIGHLIGHT ESP)
--  Сделал @MrFixTop
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
    FOV = 300,
    Smoothing = 0.08,
    Color = Color3.fromRGB(0, 255, 0) -- Ярко-зеленый
}

if CoreGui:FindFirstChild("EzzFlick") then CoreGui.EzzFlick:Destroy() end

-- [ ИНТЕРФЕЙС ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EzzFlick"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 260)
Main.Position = UDim2.new(0.5, -110, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Settings.Color
Stroke.Thickness = 1.5

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | HIGHLIGHT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14
Title.AutoButtonColor = false

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -60)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ЛОГИКА ПЕРЕТАСКИВАНИЯ ]
local dragging, dragInput, dragStart, startPos
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

-- [ ФУНКЦИЯ ВХ (HIGHLIGHT) ]
local function ApplyESP(player)
    if player == LocalPlayer then return end
    
    local function addHighlight(char)
        if not char then return end
        local highlight = char:FindFirstChild("EzzHighlight")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "EzzHighlight"
            highlight.Parent = char
            highlight.FillColor = Settings.Color
            highlight.FillTransparency = 0.5 -- Прозрачность заливки
            highlight.OutlineColor = Color3.new(1, 1, 1) -- Белая обводка для четкости
            highlight.OutlineTransparency = 0
            highlight.Adornee = char
            highlight.Enabled = Settings.ESP
        end
    end

    player.CharacterAdded:Connect(addHighlight)
    if player.Character then addHighlight(player.Character) end
end

-- Включаем для всех текущих игроков
for _, p in pairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- [ ЛОГИКА ]
local function IsVisible(part)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude, params)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

RunService.RenderStepped:Connect(function()
    local closestTarget = nil
    local shortestDist = Settings.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Обновление состояния ВХ
            local highlight = player.Character:FindFirstChild("EzzHighlight")
            if highlight then highlight.Enabled = Settings.ESP end

            -- Аимбот
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and IsVisible(head) then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        closestTarget = head; shortestDist = dist
                    end
                end
            end
        end
    end

    if Settings.Aimbot and closestTarget then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestTarget.Position), Settings.Smoothing)
    end
end)

-- [ КНОПКИ ]
local function CreateToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 2)
    
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

CreateToggle("Legit Aim", "Aimbot")
CreateToggle("Green Highlight", "ESP")

-- Сворачивание
local min = false
Title.MouseButton1Click:Connect(function()
    if not dragging then
        min = not min
        Main:TweenSize(min and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 260), "Out", "Quart", 0.3, true)
        List.Visible = not min
    end
end)
