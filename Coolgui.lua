-- COOLGUI by 007n7 (Fixed Fly)
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
buttonsFrame.Size = UDim2.new(1, 0, 0, 160)
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
local flyBtn = CreateButton("FlyButton", 5, "Fly [OFF]")
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
    mainFrame.Size = buttonsFrame.Visible and UDim2.new(0, 250, 0, 200) or UDim2.new(0, 250, 0, 40)
    expandBtn.Text = buttonsFrame.Visible and "-" or "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ИСПРАВЛЕННЫЙ Fly функционал
local flying = false
local flySpeed = 50
local bodyVelocity, bodyGyro

local function ToggleFly()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    flying = not flying
    
    if flying then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        -- Создаем физические элементы
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0.1, 0) -- Небольшой начальный импульс
        bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
        bodyVelocity.P = 10000
        bodyVelocity.Parent = character.HumanoidRootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
        bodyGyro.P = 10000
        bodyGyro.CFrame = character.HumanoidRootPart.CFrame
        bodyGyro.Parent = character.HumanoidRootPart
        
        flyBtn.Text = "Fly [ON]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
    else
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        flyBtn.Text = "Fly [OFF]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end
end

flyBtn.MouseButton1Click:Connect(ToggleFly)

-- Управление полетом
local flyControls = {
    Forward = false,
    Back = false,
    Left = false,
    Right = false,
    Up = false,
    Down = false
}

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not flying or gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then flyControls.Forward = true
    elseif input.KeyCode == Enum.KeyCode.S then flyControls.Back = true
    elseif input.KeyCode == Enum.KeyCode.A then flyControls.Left = true
    elseif input.KeyCode == Enum.KeyCode.D then flyControls.Right = true
    elseif input.KeyCode == Enum.KeyCode.Space then flyControls.Up = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then flyControls.Down = true end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if not flying or gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.W then flyControls.Forward = false
    elseif input.KeyCode == Enum.KeyCode.S then flyControls.Back = false
    elseif input.KeyCode == Enum.KeyCode.A then flyControls.Left = false
    elseif input.KeyCode == Enum.KeyCode.D then flyControls.Right = false
    elseif input.KeyCode == Enum.KeyCode.Space then flyControls.Up = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then flyControls.Down = false end
end)

-- Остальные функции (Noclip и ESP)
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

local espPlayers = false
local espBots = false
local espBoxes = {}

local function CreateESP(target)
    if not target.Character then return end
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Name = "ESP_"..target.Name
    espBox.Adornee = target.Character:FindFirstChild("HumanoidRootPart")
    espBox.AlwaysOnTop = true
    espBox.ZIndex = 10
    espBox.Size = Vector3.new(2, 3, 1)
    espBox.Transparency = 0.5
    espBox.Color3 = target:IsA("Player") and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    espBox.Parent = target.Character.HumanoidRootPart
    espBoxes[target] = espBox
end

local function ClearESP()
    for _, box in pairs(espBoxes) do box:Destroy() end
    espBoxes = {}
end

local function UpdateESP()
    ClearESP()
    if espPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= player and player.Character then
                CreateESP(player)
            end
        end
    end
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
RS.Heartbeat:Connect(function()
    -- Управление полетом
    if flying and character and character:FindFirstChild("HumanoidRootPart") then
        local root = character.HumanoidRootPart
        local flyDirection = Vector3.new()
        
        if flyControls.Forward then flyDirection = flyDirection + root.CFrame.LookVector end
        if flyControls.Back then flyDirection = flyDirection - root.CFrame.LookVector end
        if flyControls.Left then flyDirection = flyDirection - root.CFrame.RightVector end
        if flyControls.Right then flyDirection = flyDirection + root.CFrame.RightVector end
        if flyControls.Up then flyDirection = flyDirection + Vector3.new(0, 1, 0) end
        if flyControls.Down then flyDirection = flyDirection - Vector3.new(0, 1, 0) end
        
        bodyVelocity.Velocity = flyDirection.Magnitude > 0 and flyDirection.Unit * flySpeed or Vector3.new(0, 0.1, 0)
        bodyGyro.CFrame = root.CFrame
    end
    
    -- Noclip
    if noclip then NoclipLoop() end
end)

-- Обработка изменений персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    if flying then
        flying = false
        ToggleFly()
    end
    if noclip then NoclipLoop() end
    UpdateESP()
end)

-- Инициализация
UpdateESP()
