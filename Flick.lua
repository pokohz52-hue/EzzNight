-- ==========================================
--  E Z Z  F L I C K  v1.3 (Smooth & Box ESP)
--  Сделал @MrFixTop
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 250,        -- Увеличенная зона захвата
    Smoothing = 0.15  -- Плавность (чем меньше, тем медленнее доводка)
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
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 2)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(200, 0, 0)

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "EZZ FLICK | SMOOTH"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -60)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ФУНКЦИЯ ПРОВЕРКИ ВИДИМОСТИ ]
local function IsVisible(part)
    local character = LocalPlayer.Character
    if not character then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude, params)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

-- [ ЛОГИКА ESP И AIM ]
RunService.RenderStepped:Connect(function()
    local closestTarget = nil
    local shortestDist = Settings.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hrp and hum and hum.Health > 0 then
                -- BOX ESP (Прямоугольники)
                local box = hrp:FindFirstChild("EzzBox")
                if Settings.ESP then
                    if not box then
                        local b = Instance.new("BoxHandleAdornment", hrp)
                        b.Name = "EzzBox"
                        b.AlwaysOnTop = true
                        b.Adornee = hrp
                        b.Color3 = Color3.new(1, 0, 0)
                        b.Size = Vector3.new(4, 5.5, 0.5) -- Размер рамки
                        b.Transparency = 0.6
                        b.ZIndex = 10
                    end
                else
                    if box then box:Destroy() end
                end

                -- AIMBOT
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and IsVisible(head) then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        closestTarget = head
                        shortestDist = dist
                    end
                end
            end
        end
    end

    -- Плавная наводка через LERP
    if Settings.Aimbot and closestTarget then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothing)
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
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 2)
    
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

CreateToggle("Smooth Aim", "Aimbot")
CreateToggle("Box ESP", "ESP")

-- Сворачивание
local min = false
Title.MouseButton1Click:Connect(function()
    min = not min
    Main:TweenSize(min and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 260), "Out", "Quart", 0.3, true)
    List.Visible = not min
end)

game.StarterGui:SetCore("SendNotification", {Title = "Ezz Flick", Text = "Smooth v1.3 by @MrFixTop", Duration = 3})
