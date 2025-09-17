local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Создание розового интерфейса
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GothbreachMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 180) -- Уменьшил размер меню
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 150, 200) -- Розовый цвет
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Закругление углов меню
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Тень для эффекта глубины
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5554236805"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceScale = 0.05
shadow.Parent = mainFrame

-- Убрал заголовок Gothbreach Teleport Menu

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 20) -- Поднял выше
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Статус: Ожидание"
statusLabel.TextColor3 = Color3.new(0, 0, 0) -- Черный текст для контраста
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0.5, -60, 0, 50) -- Поднял выше
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 180) -- Розовый цвет кнопки
toggleButton.BackgroundTransparency = 0.2
toggleButton.Text = "ВКЛЮЧИТЬ"
toggleButton.TextColor3 = Color3.new(0, 0, 0) -- Черный текст
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(0, 8)
cornerBtn.Parent = toggleButton

local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, 0, 0, 20)
credits.Position = UDim2.new(0, 0, 1, -20)
credits.BackgroundTransparency = 1
credits.Text = "By torn | Версия 1.0.0"
credits.TextColor3 = Color3.new(0, 0, 0) -- Черный текст
credits.Font = Enum.Font.Gotham
credits.TextSize = 12
credits.Parent = mainFrame

-- Создание круглой кнопки меню
local menuButton = Instance.new("ImageButton")
menuButton.Size = UDim2.new(0, 50, 0, 50)
menuButton.Position = UDim2.new(0, 10, 0, 10)
menuButton.BackgroundColor3 = Color3.fromRGB(255, 100, 180) -- Розовый цвет
menuButton.BackgroundTransparency = 0.2
menuButton.Image = "rbxassetid://129701358676526"
menuButton.Parent = screenGui

-- Делаем кнопку круглой
local menuButtonCorner = Instance.new("UICorner")
menuButtonCorner.CornerRadius = UDim.new(1, 0)
menuButtonCorner.Parent = menuButton

-- Функционал перемещения меню
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

-- Функционал перемещения кнопки меню
local menuDragging = false
local menuDragInput, menuDragStart, menuStartPos

local function updateMenuPos(input)
    local delta = input.Position - menuDragStart
    menuButton.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
end

menuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuDragging = true
        menuDragStart = input.Position
        menuStartPos = menuButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                menuDragging = false
            end
        end)
    end
end)

menuButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        menuDragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
    if input == menuDragInput and menuDragging then
        updateMenuPos(input)
    end
end)

-- Функция открытия/закрытия меню
menuButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Переменные состояния
local isActive = false
local targetPosition = Vector3.new(-27.22, 125.19, 1763.98)

-- Функция для получения текущего персонажа
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoidRootPart(character)
    return character:WaitForChild("HumanoidRootPart")
end

local function setNoclip(character, enabled)
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end
end

local function updateStatus(text, color)
    statusLabel.Text = "Статус: " .. text
    statusLabel.TextColor3 = color
end

local function teleportToPosition()
    if not isActive then return end
    
    local character = getCharacter()
    local humanoidRootPart = getHumanoidRootPart(character)
    
    updateStatus("Телепортация...", Color3.new(0, 0, 0))
    setNoclip(character, true)
    
    humanoidRootPart.CFrame = CFrame.new(targetPosition)
    
    wait(0.5)
    setNoclip(character, false)
    updateStatus("Готово", Color3.new(0, 0, 0))
end

toggleButton.MouseButton1Click:Connect(function()
    isActive = not isActive
    
    if isActive then
        toggleButton.Text = "ВЫКЛЮЧИТЬ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 150)
        teleportToPosition()
    else
        toggleButton.Text = "ВКЛЮЧИТЬ"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 180)
        updateStatus("Ожидание", Color3.new(0, 0, 0))
    end
end)

-- Обработка смерти и респавна
player.CharacterAdded:Connect(function(newCharacter)
    if isActive then
        wait(1)
        teleportToPosition()
    end
end)

-- Эффекты при наведении
toggleButton.MouseEnter:Connect(function()
    toggleButton.BackgroundTransparency = 0.1
end)

toggleButton.MouseLeave:Connect(function()
    toggleButton.BackgroundTransparency = 0.2
end)

menuButton.MouseEnter:Connect(function()
    menuButton.BackgroundTransparency = 0.1
end)

menuButton.MouseLeave:Connect(function()
    menuButton.BackgroundTransparency = 0.2
end)

updateStatus("Готов к службе", Color3.new(0, 0, 0))
