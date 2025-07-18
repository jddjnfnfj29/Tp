local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

-- Настройки
local AntiAFK = true
local MoveInterval = 5
local MoveDistance = 10
local MenuOpen = false

-- Создаем главный GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiAFKMenu"
ScreenGui.Parent = PlayerGui

-- Кнопка открытия меню (с вашим изображением)
local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenMenuButton"
OpenButton.Image = "rbxassetid://74871491572834" -- Ваш ID изображения
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0.5, -25)
OpenButton.BackgroundTransparency = 1
OpenButton.Parent = ScreenGui

-- Основное меню (изначально скрыто)
local Frame = Instance.new("Frame")
Frame.Name = "MainMenu"
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Visible = false
Frame.Parent = ScreenGui

-- Заголовок (для перетаскивания)
local Title = Instance.new("TextLabel")
Title.Text = "🌿 Anti-AFK Menu (Drag Me)"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Кнопка включения/выключения Anti-AFK
local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "Anti-AFK: " .. (AntiAFK and "ON ✅" or "OFF ❌")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = Frame

-- Кнопка закрытия меню
local CloseButton = Instance.new("TextButton")
CloseButton.Text = "Закрыть"
CloseButton.Size = UDim2.new(0.8, 0, 0, 30)
CloseButton.Position = UDim2.new(0.1, 0, 0.6, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = Frame

-- Функция случайного движения (Anti-AFK)
local function RandomMove()
    if not AntiAFK or not Player.Character then return end
    
    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")
        if RootPart then
            local RandomDirection = Vector3.new(
                math.random(-MoveDistance, MoveDistance),
                0,
                math.random(-MoveDistance, MoveDistance)
            )
            local NewPosition = RootPart.Position + RandomDirection
            Humanoid:MoveTo(NewPosition)
        end
    end
end

-- Перетаскивание меню
local Dragging, DragInput, DragStart, StartPos
Title.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPos = Frame.Position
        
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
        local Delta = Input.Position - DragStart
        Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end
end)

-- Открытие/закрытие меню
OpenButton.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    Frame.Visible = MenuOpen
end)

-- Включение/выключение Anti-AFK
ToggleButton.MouseButton1Click:Connect(function()
    AntiAFK = not AntiAFK
    ToggleButton.Text = "Anti-AFK: " .. (AntiAFK and "ON ✅" or "OFF ❌")
end)

-- Закрытие меню
CloseButton.MouseButton1Click:Connect(function()
    MenuOpen = false
    Frame.Visible = false
end)

-- Автоматическое движение каждые N секунд
while true do
    if AntiAFK then
        RandomMove()
    end
    wait(MoveInterval)
end
