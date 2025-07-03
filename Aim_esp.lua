--[[
    Минималистичный AimBot для Roblox (KRNL)
    by Torn
    Версия: 1.6 (Только самое необходимое)
]]

-- Настройки
local Settings = {
    TeamCheck = false,          -- Проверять команду
    FOV = 250,                 -- Угол обзора аимбота
    Smoothness = 1,            -- 1 = мгновенный аим
    ESPEnabled = true,         -- Включить ESP
    AutoShoot = true,          -- Автоматическая стрельба
    AimAt = "Head",            -- "Head" или "Torso"
    VisibleCheck = true,       -- Проверка видимости
    ESPColor = Color3.fromRGB(255, 50, 50) -- Цвет ESP
}

-- Не изменяйте эти переменные
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Центр экрана
local CenterScreen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

-- Статус
local Status = "Активен"
local StatusColor = Color3.fromRGB(0, 255, 0)

-- ESP система (быстрая)
local ESP = {
    Boxes = {},
    Texts = {}
}

-- Быстрое создание ESP
function ESP:Create(player)
    if self.Boxes[player] then return end
    
    local Box = Drawing.new("Quad")
    Box.Visible = false
    Box.Color = Settings.ESPColor
    Box.Thickness = 1
    Box.Filled = false
    
    local Text = Drawing.new("Text")
    Text.Visible = false
    Text.Color = Settings.ESPColor
    Text.Size = 14
    Text.Center = true
    Text.Outline = true
    
    self.Boxes[player] = Box
    self.Texts[player] = Text
end

-- Мгновенное обновление ESP
function ESP:Update(player)
    if not Settings.ESPEnabled then
        if self.Boxes[player] then self.Boxes[player].Visible = false end
        if self.Texts[player] then self.Texts[player].Visible = false end
        return
    end
    
    local character = player.Character
    if not character then
        if self.Boxes[player] then self.Boxes[player].Visible = false end
        if self.Texts[player] then self.Texts[player].Visible = false end
        return
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not rootPart or not head then
        if self.Boxes[player] then self.Boxes[player].Visible = false end
        if self.Texts[player] then self.Texts[player].Visible = false end
        return
    end
    
    local rootPos, rootVis = Camera:WorldToViewportPoint(rootPart.Position)
    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    
    if rootVis then
        local size = Vector2.new(math.abs(headPos.X - rootPos.X) * 2, math.abs(headPos.Y - rootPos.Y) * 3)
        local position = Vector2.new(rootPos.X - size.X/2, rootPos.Y - size.Y/2)
        
        -- Мгновенное обновление
        self.Boxes[player].PointA = position
        self.Boxes[player].PointB = position + Vector2.new(size.X, 0)
        self.Boxes[player].PointC = position + size
        self.Boxes[player].PointD = position + Vector2.new(0, size.Y)
        self.Boxes[player].Visible = true
        
        self.Texts[player].Position = position + Vector2.new(size.X/2, -20)
        self.Texts[player].Text = player.Name.." ("..math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude).."m)"
        self.Texts[player].Visible = true
    else
        self.Boxes[player].Visible = false
        self.Texts[player].Visible = false
    end
end

-- Мгновенное удаление ESP
function ESP:Remove(player)
    if self.Boxes[player] then
        self.Boxes[player]:Remove()
        self.Boxes[player] = nil
    end
    if self.Texts[player] then
        self.Texts[player]:Remove()
        self.Texts[player] = nil
    end
end

-- Проверка видимости (оптимизированная)
function IsVisible(part)
    if not Settings.VisibleCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000
    local ray = Ray.new(origin, direction)
    
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    
    return hit and hit:IsDescendantOf(part.Parent)
end

-- Поиск ближайшего видимого игрока
function GetClosestPlayer()
    local closestPlayer, closestDistance = nil, Settings.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Settings.AimAt)
            
            if humanoid and humanoid.Health > 0 and targetPart then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local screenPos = Camera:WorldToViewportPoint(targetPart.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - CenterScreen).Magnitude
                
                if distance < closestDistance and IsVisible(targetPart) then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end
    end
    
    return closestPlayer
end

-- Автоматическая стрельба
function AutoShoot(target)
    if not Settings.AutoShoot then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local tool = humanoid:FindFirstChildOfClass("Tool")
    if tool then
        local remote = tool:FindFirstChildOfClass("RemoteEvent") or tool:FindFirstChildOfClass("RemoteFunction")
        if remote then
            remote:FireServer(target)
        end
    end
end

-- Создаем минималистичный статус UI
local StatusUI = Instance.new("ScreenGui")
StatusUI.Name = "TornAimBotStatus"
StatusUI.Parent = game.CoreGui
StatusUI.ResetOnSpawn = false

local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 200, 0, 40)
StatusFrame.Position = UDim2.new(0.5, -100, 0.02, 0)
StatusFrame.AnchorPoint = Vector2.new(0.5, 0)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
StatusFrame.BackgroundTransparency = 0.5
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = StatusUI

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "AimBot by Torn"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = StatusFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = Status
StatusLabel.TextColor3 = StatusColor
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = StatusFrame

-- Основной цикл
RunService.RenderStepped:Connect(function()
    -- Обновляем ESP для всех игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESP.Boxes[player] then
                ESP:Create(player)
            end
            ESP:Update(player)
        end
    end
    
    -- Ищем и аимеем ближайшего видимого игрока
    local targetPlayer = GetClosestPlayer()
    if targetPlayer and targetPlayer.Character then
        local targetPart = targetPlayer.Character:FindFirstChild(Settings.AimAt)
        if targetPart then
            -- Мгновенное наведение
            local camPos = Camera.CFrame.Position
            local direction = (targetPart.Position - camPos).Unit
            Camera.CFrame = CFrame.new(camPos, camPos + direction)
            
            -- Автострельба
            AutoShoot(targetPart)
            
            Status = "Цель: "..targetPlayer.Name
            StatusColor = Color3.fromRGB(0, 255, 0)
        end
    else
        Status = "Активен"
        StatusColor = Color3.fromRGB(0, 255, 0)
    end
    
    -- Обновление статуса
    StatusLabel.Text = Status
    StatusLabel.TextColor3 = StatusColor
end)

-- Очистка при выходе игроков
Players.PlayerRemoving:Connect(function(player)
    ESP:Remove(player)
end)

print("Минималистичный AimBot by Torn загружен!")
