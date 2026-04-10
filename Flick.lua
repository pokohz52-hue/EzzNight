-- ==========================================
--  E Z Z  F L I C K  v1.2 (Wall Check)
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
    FOV = 150
}

if CoreGui:FindFirstChild("EzzFlick") then CoreGui.EzzFlick:Destroy() end

-- [ ИНТЕРФЕЙС ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EzzFlick"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 250)
Main.Position = UDim2.new(0.5, -110, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 0, 0)

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "EZZ FLICK | WALL CHECK"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 13

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 50)
List.Size = UDim2.new(1, -20, 1, -60)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ФУНКЦИЯ ПРОВЕРКИ ВИДИМОСТИ ]
local function IsVisible(part)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    -- Игнорируем себя при проверке луча
    params.FilterDescendantsInstances = {character, Camera}
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local result = workspace:Raycast(origin, direction, params)
    
    -- Если луч ни обо что не ударился или ударился в самого противника — он видим
    if not result or result.Instance:IsDescendantOf(part.Parent) then
        return true
    end
    return false
end

-- [ ЛОГИКА ]
RunService.RenderStepped:Connect(function()
    local closestTarget = nil
    local shortestDist = Settings.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if head and hum and hum.Health > 0 then
                -- ESP (оставляем, чтобы видеть за стенами)
                local esp = head:FindFirstChild("EzzESP")
                if Settings.ESP then
                    if not esp then
                        local b = Instance.new("BillboardGui", head)
                        b.Name = "EzzESP"
                        b.AlwaysOnTop = true
                        b.Size = UDim2.new(0, 100, 0, 30)
                        local l = Instance.new("TextLabel", b)
                        l.Size = UDim2.new(1, 0, 1, 0)
                        l.Text = player.Name
                        l.TextColor3 = Color3.new(1, 0, 0)
                        l.BackgroundTransparency = 1
                    end
                else
                    if esp then esp:Destroy() end
                end

                -- Аимбот с проверкой видимости
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

    if Settings.Aimbot and closestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
    end
end)

-- [ КНОПКИ ]
local function CreateToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(35, 35, 35)
    end)
end

CreateToggle("Aimbot (Visible Only)", "Aimbot")
CreateToggle("ESP (Wallhack)", "ESP")

-- Сворачивание
local min = false
Title.MouseButton1Click:Connect(function()
    min = not min
    Main:TweenSize(min and UDim2.new(0, 220, 0, 40) or UDim2.new(0, 220, 0, 250), "Out", "Quart", 0.3, true)
    List.Visible = not min
end)
