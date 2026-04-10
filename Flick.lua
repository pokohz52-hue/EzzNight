-- ==========================================
--  E Z Z  F L I C K  v1.0
--  Сделал @MrFixTop
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки чита
local Settings = {
    Aimbot = false,
    Triggerbot = false,
    ESP = false,
    TeamCheck = true,
    AimPart = "Head", -- Куда целимся
    Sensitivity = 0.5   -- Плавность аима (чем меньше, тем резче)
}

-- Удаление старого меню
if game:GetService("CoreGui"):FindFirstChild("EzzFlick") then
    game:GetService("CoreGui").EzzFlick:Destroy()
end

-- [ ИНТЕРФЕЙС - ПРЯМОУГОЛЬНЫЙ СТИЛЬ ]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "EzzFlick"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0.5, -110, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.Thickness = 1.5

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "EZZ FLICK | @MrFixTop"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -55)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ЛОГИКА АИМА ]
local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[Settings.AimPart].Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if magnitude < dist then
                    target = player.Character[Settings.AimPart]
                    dist = magnitude
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    -- Аимбот
    if Settings.Aimbot then
        local target = GetClosestPlayer()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Sensitivity)
        end
    end

    -- ВХ (ESP)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local esp = hrp:FindFirstChild("EzzBox")
            
            if Settings.ESP then
                if not esp then
                    local box = Instance.new("BoxHandleAdornment", hrp)
                    box.Name = "EzzBox"
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Size = Vector3.new(4, 6, 1)
                    box.Color3 = Color3.new(1, 0, 0)
                    box.Transparency = 0.7
                    box.Adornee = hrp
                end
            else
                if esp then esp:Destroy() end
            end
        end
    end

    -- Триггербот
    if Settings.Triggerbot then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Target and mouse.Target.Parent:FindFirstChild("Humanoid") then
            local targetPlayer = Players:GetPlayerFromCharacter(mouse.Target.Parent)
            if targetPlayer and targetPlayer.Team ~= LocalPlayer.Team then
                mouse1click() -- Внимание: mouse1click работает только на мощных экзекуторах (Delta должна тянуть)
            end
        end
    end
end)

-- [ СОЗДАНИЕ КНОПОК ]
local function CreateToggle(text, field)
    local btn = Instance.new("TextButton", List)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    
    btn.MouseButton1Click:Connect(function()
        Settings[field] = not Settings[field]
        btn.Text = text .. (Settings[field] and ": ON" or ": OFF")
        btn.BackgroundColor3 = Settings[field] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
    end)
end

CreateToggle("Aimbot", "Aimbot")
CreateToggle("TriggerBot", "Triggerbot")
CreateToggle("ESP (Wallhack)", "ESP")
CreateToggle("Team Check", "TeamCheck")

-- Сворачивание при нажатии на заголовок
local minimized = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        minimized = not minimized
        Main:TweenSize(minimized and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 280), "Out", "Quart", 0.3, true)
        List.Visible = not minimized
    end
end)
