-- DRAGONTHI GUI by 007n7
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Удаляем старый GUI если есть
if CG:FindFirstChild("DRAGONTHI_GUI") then CG.DRAGONTHI_GUI:Destroy() end

-- Создаем GUI в стиле из файла
local gui = Instance.new("ScreenGui")
gui.Name = "DRAGONTHI_GUI"
gui.Parent = CG
gui.ResetOnSpawn = false

-- Главный фрейм
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 40) -- Минимальный размер
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -20)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 90)
mainFrame.Parent = gui

-- Углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

-- Верхняя панель
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 6, 0, 0)
topCorner.Parent = topBar

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0.5, -100, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DRAGONTHI | 17"
title.Font = Enum.Font.SciFi
title.TextColor3 = Color3.fromRGB(150, 200, 255)
title.TextSize = 18
title.Parent = topBar

-- Кнопка разворачивания
local expandBtn = Instance.new("TextButton")
expandBtn.Name = "ExpandButton"
expandBtn.Size = UDim2.new(0, 30, 1, 0)
expandBtn.Position = UDim2.new(1, -30, 0, 0)
expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
expandBtn.BorderSizePixel = 0
expandBtn.Text = "+"
expandBtn.Font = Enum.Font.SciFi
expandBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
expandBtn.TextSize = 20
expandBtn.Parent = topBar

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -60, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SciFi
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
closeBtn.TextSize = 18
closeBtn.Parent = topBar

-- Фрейм для кнопок (изначально скрыт)
local buttonsFrame = Instance.new("ScrollingFrame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, 0, 0, 250)
buttonsFrame.Position = UDim2.new(0, 0, 0, 30)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Visible = false
buttonsFrame.ScrollBarThickness = 5
buttonsFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
buttonsFrame.Parent = mainFrame

-- Создаем кнопки в стиле таблицы
local function CreateButton(name, text, xPos, yPos, width)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(width, -10, 0, 30)
    button.Position = UDim2.new(xPos, 5, 0, yPos)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    button.BorderColor3 = Color3.fromRGB(80, 80, 90)
    button.BorderSizePixel = 1
    button.Text = text
    button.Font = Enum.Font.SciFi
    button.TextColor3 = Color3.fromRGB(180, 200, 255)
    button.TextSize = 14
    button.Parent = buttonsFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = button
    
    return button
end

-- Создаем заголовки столбцов
local headers = {"Drage", "Dual Blades", "Custom Gear", "Stamper Tools"}
for i, header in ipairs(headers) do
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(0.25, -10, 0, 25)
    headerLabel.Position = UDim2.new((i-1)*0.25, 5, 0, 5)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = header
    headerLabel.Font = Enum.Font.SciFi
    headerLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    headerLabel.TextSize = 16
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.Parent = buttonsFrame
end

-- Создаем кнопки как в таблице
CreateButton("EyeLaserBtn", "Eyelaser", 0, 35, 0.25)
CreateButton("KnifeBtn", "Knife", 0.25, 35, 0.25)
CreateButton("ToolStealerBtn", "Tool Stealer", 0.5, 35, 0.25)
CreateButton("Empty1Btn", "Empty", 0.75, 35, 0.25)

CreateButton("LanceBtn", "Lance", 0, 70, 0.25)
CreateButton("LightsaberBtn", "Lightsaber", 0.25, 70, 0.25)
CreateButton("DevUziBtn", "Dev Uzi", 0.5, 70, 0.25)
CreateButton("GodLaserBtn", "God Laser", 0.75, 70, 0.25)

CreateButton("MasterHandBtn", "Master Hand", 0, 105, 0.25)
CreateButton("PlaneBtn", "Plane", 0.25, 105, 0.25)
CreateButton("DrawToolBtn", "Draw Tool", 0.5, 105, 0.25)
CreateButton("Empty2Btn", "Empty", 0.75, 105, 0.25)

CreateButton("SnowballBtn", "Snowball", 0, 140, 0.25)
CreateButton("StaffBtn", "Staff", 0.25, 140, 0.25)
CreateButton("Empty3Btn", "Empty", 0.5, 140, 0.25)
CreateButton("Empty4Btn", "Empty", 0.75, 140, 0.25)

CreateButton("Empty5Btn", "Empty", 0, 175, 0.25)
CreateButton("TechnoGauntletBtn", "Techno Gauntlet", 0.25, 175, 0.25)
CreateButton("Empty6Btn", "Empty", 0.5, 175, 0.25)
CreateButton("Empty7Btn", "Empty", 0.75, 175, 0.25)

CreateButton("WandBtn", "Wand", 0, 210, 0.25)
CreateButton("xBowBtn", "xBow", 0.25, 210, 0.25)

-- Добавляем кнопку Fly отдельно
local flyBtn = CreateButton("FlyBtn", "Fly [OFF]", 0, 245, 1)
flyBtn.Size = UDim2.new(1, -10, 0, 30)

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

-- Функционал кнопок
local expanded = false
expandBtn.MouseButton1Click:Connect(function()
    expanded = not expanded
    if expanded then
        buttonsFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 300, 0, 280)
        expandBtn.Text = "-"
    else
        buttonsFrame.Visible = false
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
        expandBtn.Text = "+"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Исправленный Fly функционал
local flying = false
local flySpeed = 50
local bodyVelocity, bodyGyro

local function ToggleFly()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    flying = not flying
    
    if flying then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        -- Создаем BodyVelocity и BodyGyro
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.P = 10000
        bodyVelocity.Parent = character.HumanoidRootPart
        
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 10000
        bodyGyro.CFrame = character.HumanoidRootPart.CFrame
        bodyGyro.Parent = character.HumanoidRootPart
        
        flyBtn.Text = "Fly [ON]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
    else
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        flyBtn.Text = "Fly [OFF]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
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

-- Главный цикл
RS.Heartbeat:Connect(function()
    if flying and character and character:FindFirstChild("HumanoidRootPart") and bodyVelocity and bodyGyro then
        local root = character.HumanoidRootPart
        local flyDirection = Vector3.new()
        
        if flyControls.Forward then flyDirection = flyDirection + root.CFrame.LookVector end
        if flyControls.Back then flyDirection = flyDirection - root.CFrame.LookVector end
        if flyControls.Left then flyDirection = flyDirection - root.CFrame.RightVector end
        if flyControls.Right then flyDirection = flyDirection + root.CFrame.RightVector end
        if flyControls.Up then flyDirection = flyDirection + Vector3.new(0, 1, 0) end
        if flyControls.Down then flyDirection = flyDirection - Vector3.new(0, 1, 0) end
        
        if flyDirection.Magnitude > 0 then
            flyDirection = flyDirection.Unit * flySpeed
        end
        
        bodyVelocity.Velocity = flyDirection
        bodyGyro.CFrame = root.CFrame
    end
end)

-- Обработка изменений персонажа
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    
    if flying then
        flying = false
        ToggleFly() -- Перезапускаем fly при смене персонажа
    end
end)
