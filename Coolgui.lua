-- COOLGUI by 007n7 (Inf Jump + Fixed ESP)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Удаляем старый GUI если есть
if CG:FindFirstChild("COOLGUI") then CG.COOLGUI:Destroy() end

-- Создаем GUI
local gui = Instance.new("ScreenGui")
gui.Name = "COOLGUI"
gui.Parent = CG
gui.ResetOnSpawn = false

-- Главный фрейм (черный с красной обводкой)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 40)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -20)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)

-- Верхняя панель
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 25)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 6, 0, 0)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 180, 1, 0)
title.Position = UDim2.new(0.5, -90, 0, 0)
title.BackgroundTransparency = 1
title.Text = "COOLGUI"
title.Font = Enum.Font.SciFi
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.TextSize = 18
title.Parent = topBar

-- Кнопки управления (с красной обводкой)
local expandBtn = Instance.new("TextButton")
expandBtn.Name = "ExpandButton"
expandBtn.Size = UDim2.new(0, 25, 1, 0)
expandBtn.Position = UDim2.new(1, -25, 0, 0)
expandBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
expandBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
expandBtn.BorderSizePixel = 1
expandBtn.Text = "+"
expandBtn.Font = Enum.Font.SciFi
expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
expandBtn.TextSize = 18
expandBtn.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 25, 1, 0)
closeBtn.Position = UDim2.new(1, -50, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
closeBtn.BorderColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.BorderSizePixel = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SciFi
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Parent = topBar

-- Фрейм для кнопок
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, 0, 0, 130)
buttonsFrame.Position = UDim2.new(0, 0, 0, 25)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Visible = false
buttonsFrame.Parent = mainFrame

-- Функция создания кнопок (с красной обводкой)
local function CreateButton(name, yPos, text)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderColor3 = Color3.fromRGB(255, 0, 0)
    button.BorderSizePixel = 1
    button.Text = text
    button.Font = Enum.Font.SciFi
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Parent = buttonsFrame
    
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    return button
end

-- Создаем кнопки
local infJumpBtn = CreateButton("InfJumpButton", 5, "Inf Jump [OFF]")
local noclipBtn = CreateButton("NoclipButton", 40, "Noclip [OFF]")
local espBtn = CreateButton("ESPButton", 75, "ESP Players [OFF]")
local espBotsBtn = CreateButton("ESPBotsButton", 110, "ESP Bots [OFF]")

-- Функционал перетаскивания
local dragging, dragInput, dragStart, startPos

local function UpdateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        UpdateInput(input)
    end
end)

-- Управление окном
expandBtn.MouseButton1Click:Connect(function()
    buttonsFrame.Visible = not buttonsFrame.Visible
    mainFrame.Size = buttonsFrame.Visible and UDim2.new(0, 250, 0, 170) or UDim2.new(0, 250, 0, 40)
    expandBtn.Text = buttonsFrame.Visible and "-" or "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Inf Jump функция
local infJumpEnabled = false
local jumpConnection

local function ToggleInfJump()
    infJumpEnabled = not infJumpEnabled
    
    if infJumpEnabled then
        infJumpBtn.Text = "Inf Jump [ON]"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
        
        jumpConnection = UIS.JumpRequest:Connect(function()
            if character and humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        infJumpBtn.Text = "Inf Jump [OFF]"
        infJumpBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
    end
end

infJumpBtn.MouseButton1Click:Connect(ToggleInfJump)

-- Noclip функция
local noclip = false
local noclipParts = {}

local function NoclipLoop()
    if not character then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.CanCollide and not noclipParts[part] then
                noclipParts[part] = part.CanCollide
            end
            part.CanCollide = not noclip
        end
    end
end

noclipBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipBtn.Text = noclip and "Noclip [ON]" or "Noclip [OFF]"
    noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(0, 50, 0) or Color3.fromRGB(0, 0, 0)
    NoclipLoop()
end)

-- Исправленный ESP функционал
local espPlayers = false
local espBots = false
local espBoxes = {}

local function CreateESP(target)
    if not target.Character then return end
    
    local humanoidRootPart = target.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Удаляем старый ESP если есть
    if espBoxes[target] then
        espBoxes[target]:Destroy()
        espBoxes[target] = nil
    end
    
    -- Создаем новый ESP
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Name = "ESP_"..target.Name
    espBox.Adornee = humanoidRootPart
    espBox.AlwaysOnTop = true
    espBox.ZIndex = 10
    espBox.Size = Vector3.new(2, 3, 1)
    espBox.Transparency = 0.5
    espBox.Color3 = target:IsA("Player") and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    espBox.Parent = humanoidRootPart
    
    espBoxes[target] = espBox
    
    -- Обработка изменения персонажа
    target.CharacterAdded:Connect(function(newChar)
        task.wait(1) -- Ждем загрузки персонажа
        if espPlayers and target:IsA("Player") or espBots and not target:IsA("Player") then
            CreateESP(target)
        end
    end)
end

local function ClearESP()
    for target, espBox in pairs(espBoxes) do
        if espBox then
            espBox:Destroy()
        end
    end
    espBoxes = {}
end

local function UpdateESP()
    ClearESP()
    
    -- ESP для игроков
    if espPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                CreateESP(player)
            end
        end
    end
    
    -- ESP для ботов
    if espBots then
        for _, npc in ipairs(workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
                CreateESP(npc)
            end
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    espPlayers = not espPlayers
    espBtn.Text = espPlayers and "ESP Players [ON]" or "ESP Players [OFF]"
    espBtn.BackgroundColor3 = espPlayers and Color3.fromRGB(0, 50, 0) or Color3.fromRGB(0, 0, 0)
    UpdateESP()
end)

espBotsBtn.MouseButton1Click:Connect(function()
    espBots = not espBots
    espBotsBtn.Text = espBots and "ESP Bots [ON]" or "ESP Bots [OFF]"
    espBotsBtn.BackgroundColor3 = espBots and Color3.fromRGB(0, 50, 0) or Color3.fromRGB(0, 0, 0)
    UpdateESP()
end)

-- Главный цикл
RS.Stepped:Connect(function()
    -- Noclip
    if noclip then NoclipLoop() end
end)

-- Обработка изменений персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    
    -- Восстанавливаем Inf Jump
    if infJumpEnabled and jumpConnection then
        jumpConnection:Disconnect()
        ToggleInfJump()
    end
    
    -- Восстанавливаем Noclip
    if noclip then NoclipLoop() end
    
    -- Восстанавливаем ESP
    UpdateESP()
end)

-- Инициализация
UpdateESP()
