-- ==========================================
--  E Z Z  F L I C K  v1.5 (DRAG & GREEN)
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
    BoxColor = Color3.fromRGB(0, 255, 0)
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
Stroke.Color = Color3.fromRGB(0, 255, 0)
Stroke.Thickness = 1.5

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Title.Text = "EZZ FLICK | DRAGGABLE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.RobotoMono
Title.TextSize = 14
Title.AutoButtonColor = false

local List = Instance.new("Frame", Main)
List.Position = UDim2.new(0, 10, 0, 45)
List.Size = UDim2.new(1, -20, 1, -60)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- [ ЛОГИКА ПЕРЕТАСКИВАНИЯ (DRAG FIX) ]
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [ ЛОГИКА ЧИТОВ ]
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
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            
            if head and hrp then
                -- ESP
                local box = hrp:FindFirstChild("EzzBox")
                if Settings.ESP then
                    if not box then
                        local b = Instance.new("BoxHandleAdornment", hrp)
                        b.Name = "EzzBox"; b.AlwaysOnTop = true; b.Adornee = hrp
                        b.Color3 = Settings.BoxColor; b.Size = Vector3.new(4, 6, 0.5); b.Transparency = 0.5
                    end
                else
                    if box then box:Destroy() end
                end

                -- AIMBOT
                if Settings.Aimbot then
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
    end

    if Settings.Aimbot and closestTarget then
        local lookAt = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, Settings.Smoothing)
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
CreateToggle("Green ESP", "ESP")

-- Сворачивание (Двойной клик или просто нажатие)
local min = false
Title.MouseButton1Click:Connect(function()
    if not dragging then -- Чтобы не сворачивалось во время перетаскивания
        min = not min
        Main:TweenSize(min and UDim2.new(0, 220, 0, 35) or UDim2.new(0, 220, 0, 260), "Out", "Quart", 0.3, true)
        List.Visible = not min
    end
end)

game.StarterGui:SetCore("SendNotification", {Title = "Ezz Flick", Text = "By @MrFixTop | Drag Enabled", Duration = 3})
