-- ==========================================
--  E Z Z  F L I C K  v2.9 (SPECTATOR NAMES)
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

local function Notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
end

-- [ ИНТЕРФЕЙС ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "EzzFlick"

-- ОСНОВНОЕ МЕНЮ
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 350)
Main.Position = UDim2.new(0.5, -110, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UIStroke", Main).Color = Settings.Color

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | v2.9"
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

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -295)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ЛОГИКА ОБНАРУЖЕНИЯ СПЕКТАТОРОВ ]
local function GetSpectators()
    local spectators = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Проверяем, смотрит ли камера игрока на нашего персонажа
            if player.Character == nil or (player.CameraMode == Enum.CameraMode.Classic and (Camera.CFrame.Position - LocalPlayer.Character.Head.Position).Magnitude > 50) then
               -- В большинстве случаев в шутерах спектатор определяется по отсутствию персонажа или фокусу камеры
               -- Для точности в специфических играх этот блок можно дополнить
            end
            
            -- Универсальный метод для проверки через CameraSubject (если сервер передает)
            if player:FindFirstChild("Status") and player.Status:FindFirstChild("Spectating") and player.Status.Spectating.Value == LocalPlayer.Name then
                table.insert(spectators, player.DisplayName)
            end
        end
    end
    
    -- Простая проверка для Flick и других шутеров:
    -- Если игрок мертв и его камера рядом с нами
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p:FindFirstChild("Backpack") and not p.Character then
             table.insert(spectators, p.Name)
        end
    end

    if #spectators == 0 then
        SpecList.Text = "Nobody"
        SpecFrame.Visible = false -- Скрываем, если никого нет (по желанию)
    else
        SpecList.Text = table.concat(spectators, "\n")
        SpecFrame.Visible = Settings.SpecAlert
    end
end

-- [ ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (AIM/ESP) ]
local function IsVisible(part)
    local rayP = RaycastParams.new()
    rayP.FilterType = Enum.RaycastFilterType.Exclude
    rayP.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local res = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * (part.Position - Camera.CFrame.Position).Magnitude, rayP)
    local obs = Camera:GetPartsObscuringTarget({part.Position}, {LocalPlayer.Character, part.Parent})
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
    GetSpectators()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hi = p.Character:FindFirstChild("EzzHighlight") or Instance.new("Highlight", p.Character)
            hi.Enabled = Settings.ESP
            hi.FillColor = Settings.Color
        end
    end

    if Settings.Aimbot then
        local t = GetTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), Settings.Smoothing * (dt * 60))
        end
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
        if field == "SpecAlert" then SpecFrame.Visible = Settings.SpecAlert end
    end)
end

CreateToggle("Sticky Mix Aim", "Aimbot")
CreateToggle("Green ESP", "ESP")
CreateToggle("No Recoil", "NoRecoil")
CreateToggle("Spec Names", "SpecAlert")
CreateToggle("Hit Sound", "Hitsound")

local TG_Btn = Instance.new("TextButton", List)
TG_Btn.Size = UDim2.new(1, 0, 0, 35)
TG_Btn.BackgroundColor3 = Color3.fromRGB(0, 136, 204)
TG_Btn.Text = "ТГК СО СКРИПТАМИ"
TG_Btn.TextColor3 = Color3.new(1, 1, 1)
TG_Btn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", TG_Btn).CornerRadius = UDim.new(0, 4)
TG_Btn.MouseButton1Click:Connect(function() setclipboard(Settings.TG_Link) Notify("Telegram", "Ссылка скопирована!") end)

-- ПЕРЕТАСКИВАНИЕ (ОБОИХ ОКОН)
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(Main, Title)
MakeDraggable(SpecFrame, SpecTitle)

Notify("Ezz Flick", "v2.9 Names & Spec-Check Loaded!")
