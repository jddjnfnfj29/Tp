local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Dragging, DragInput, DragStart, StartPos

-- Создание красивого меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaTP_Menu"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.28, 0, 0.32, 0)
MainFrame.Position = UDim2.new(0.7, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Закругление углов
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Тень
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.Parent = MainFrame

-- Заголовок с эффектом
local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0.18, 0)
TitleFrame.BackgroundTransparency = 1
TitleFrame.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "DELTA TP"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.Size = UDim2.new(1, 0, 0.7, 0)
Title.BackgroundTransparency = 1
Title.Parent = TitleFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Text = "by bogdan"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Size = UDim2.new(1, 0, 0.3, 0)
SubTitle.Position = UDim2.new(0, 0, 0.7, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Parent = TitleFrame

-- Разделитель
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0.9, 0, 0.002, 0)
Divider.Position = UDim2.new(0.05, 0, 0.18, 0)
Divider.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- Поле ввода с иконкой
local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(0.9, 0, 0.18, 0)
InputFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
InputFrame.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = InputFrame

local PlayerInput = Instance.new("TextBox")
PlayerInput.PlaceholderText = "Введите ник игрока"
PlayerInput.Text = ""
PlayerInput.ClearTextOnFocus = false
PlayerInput.Size = UDim2.new(0.85, 0, 0.8, 0)
PlayerInput.Position = UDim2.new(0.1, 0, 0.1, 0)
PlayerInput.BackgroundTransparency = 1
PlayerInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerInput.Font = Enum.Font.Gotham
PlayerInput.TextSize = 14
PlayerInput.TextXAlignment = Enum.TextXAlignment.Left
PlayerInput.Parent = InputFrame

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Image = "rbxassetid://3926305904"
SearchIcon.ImageRectOffset = Vector2.new(964, 324)
SearchIcon.ImageRectSize = Vector2.new(36, 36)
SearchIcon.Size = UDim2.new(0, 20, 0, 20)
SearchIcon.Position = UDim2.new(0.02, 0, 0.25, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Parent = InputFrame

-- Кнопка телепорта с градиентом
local TPButton = Instance.new("TextButton")
TPButton.Text = "ТЕЛЕПОРТ"
TPButton.Font = Enum.Font.GothamBold
TPButton.TextSize = 16
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.Size = UDim2.new(0.9, 0, 0.15, 0)
TPButton.Position = UDim2.new(0.05, 0, 0.5, 0)
TPButton.AutoButtonColor = false
TPButton.Parent = MainFrame

local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 235))
})
ButtonGradient.Rotation = 90
ButtonGradient.Parent = TPButton

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = TPButton

-- Статус бар
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(0.9, 0, 0.1, 0)
StatusBar.Position = UDim2.new(0.05, 0, 0.7, 0)
StatusBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
StatusBar.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Ожидание ввода..."
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = StatusBar

-- Анимации
TPButton.MouseEnter:Connect(function()
    TweenService:Create(TPButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0.92, 0, 0.155, 0),
        Position = UDim2.new(0.04, 0, 0.497, 0)
    }):Play()
    TweenService:Create(ButtonGradient, TweenInfo.new(0.2), {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 170, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 190, 245))
        })
    }):Play()
end)

TPButton.MouseLeave:Connect(function()
    TweenService:Create(TPButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0.9, 0, 0.15, 0),
        Position = UDim2.new(0.05, 0, 0.5, 0)
    }):Play()
    TweenService:Create(ButtonGradient, TweenInfo.new(0.2), {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 180, 235))
        })
    }):Play()
end)

-- Функция телепорта
local function TeleportToPlayer()
    local targetName = PlayerInput.Text
    if #targetName < 2 then
        StatusLabel.Text = "Ошибка: введите ник!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        task.delay(2, function()
            StatusLabel.Text = "Ожидание ввода..."
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end)
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) and player ~= LocalPlayer then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                StatusLabel.Text = "Телепорт к "..player.Name
                StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                local tween = TweenService:Create(
                    LocalPlayer.Character.HumanoidRootPart,
                    TweenInfo.new(0.5),
                    {CFrame = player.Character.HumanoidRootPart.CFrame}
                )
                tween:Play()
                
                task.delay(2, function()
                    StatusLabel.Text = "Ожидание ввода..."
                    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                end)
                return
            end
        end
    end
    
    StatusLabel.Text = "Игрок не найден!"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    task.delay(2, function()
        StatusLabel.Text = "Ожидание ввода..."
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
end

TPButton.MouseButton1Click:Connect(TeleportToPlayer)

-- Перемещение меню
local function UpdateInput(input)
    local delta = input.Position - DragStart
    MainFrame.Position = UDim2.new(
        StartPos.X.Scale,
        StartPos.X.Offset + delta.X,
        StartPos.Y.Scale,
        StartPos.Y.Offset + delta.Y
    )
end

TitleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

TitleFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        UpdateInput(input)
    end
end)

print("Delta TP Menu by bogdan | Loaded successfully!")
