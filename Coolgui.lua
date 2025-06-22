-- Delta GUI (Optimized)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

-- Cleanup old GUI
if CG:FindFirstChild("DeltaGUI") then CG.DeltaGUI:Destroy() end

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaGUI"
gui.Parent = CG
gui.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 250, 0, 300)
main.Position = UDim2.new(0.5, -125, 0.5, -150)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0.2
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Top Bar
local top = Instance.new("Frame")
top.Name = "Top"
top.Size = UDim2.new(1, 0, 0, 25)
top.Position = UDim2.new(0, 0, 0, 0)
top.BackgroundColor3 = Color3.fromRGB(0, 122, 204)
top.BorderSizePixel = 0
top.Parent = main

local topCorner = Instance.new("UICorner", top)
topCorner.CornerRadius = UDim.new(0, 8, 0, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 180, 1, 0)
title.Position = UDim2.new(0.5, -90, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Delta GUI"
title.Font = Enum.Font.SciFi
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 16
title.Parent = top

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 1, 0)
minBtn.Position = UDim2.new(1, -25, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 158)
minBtn.BorderSizePixel = 0
minBtn.Text = "_"
minBtn.Font = Enum.Font.SciFi
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.TextSize = 16
minBtn.Parent = top

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 1, 0)
closeBtn.Position = UDim2.new(1, -50, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(0, 90, 158)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SciFi
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 16
closeBtn.Parent = top

-- Minimized Frame
local mini = Instance.new("Frame")
mini.Name = "Mini"
mini.Size = UDim2.new(0, 180, 0, 25)
mini.Position = UDim2.new(0.5, -90, 0, 10)
mini.AnchorPoint = Vector2.new(0.5, 0)
mini.BackgroundColor3 = Color3.fromRGB(0, 122, 204)
mini.BorderSizePixel = 0
mini.Visible = false
mini.Parent = gui

Instance.new("UICorner", mini)

local miniTitle = Instance.new("TextLabel")
miniTitle.Size = UDim2.new(1, 0, 1, 0)
miniTitle.Position = UDim2.new(0, 0, 0, 0)
miniTitle.BackgroundTransparency = 1
miniTitle.Text = "Delta GUI"
miniTitle.Font = Enum.Font.SciFi
miniTitle.TextColor3 = Color3.new(1, 1, 1)
miniTitle.TextSize = 16
miniTitle.Parent = mini

-- Scrolling Frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -35)
scroll.Position = UDim2.new(0, 5, 0, 30)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 350)
scroll.Parent = main

-- Buttons
local function createBtn(name, yPos, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.SciFi
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 14
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local flyBtn = createBtn("Fly", 5, "Fly [OFF]")
local noclipBtn = createBtn("Noclip", 40, "Noclip [OFF]")
local espBtn = createBtn("ESP", 75, "ESP Players [OFF]")
local espBotsBtn = createBtn("ESPBots", 110, "ESP Bots [OFF]")

-- Drag Functionality
local drag, dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)

top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

mini.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        startPos = mini.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and drag then
        if main.Visible then updateInput(input)
        else
            local delta = input.Position - dragStart
            mini.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Window Controls
minBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end)

-- Fly Function
local flying, flySpeed = false, 50
local bv, bg

local function fly(state)
    if not char then return end
    
    if state then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        if char:FindFirstChild("HumanoidRootPart") then
            bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.P = 1250
            bv.Parent = char.HumanoidRootPart
            
            bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(4000, 4000, 4000)
            bg.P = 1250
            bg.D = 250
            bg.Parent = char.HumanoidRootPart
        end
        flyBtn.Text = "Fly [ON]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    else
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        flyBtn.Text = "Fly [OFF]"
        flyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    flying = state
end

flyBtn.MouseButton1Click:Connect(function()
    fly(not flying)
end)

-- Fly Controls
local flyControls = {Forward=false, Back=false, Left=false, Right=false, Up=false, Down=false}

UIS.InputBegan:Connect(function(input, processed)
    if not flying or processed then return end
    if input.KeyCode == Enum.KeyCode.W then flyControls.Forward = true
    elseif input.KeyCode == Enum.KeyCode.S then flyControls.Back = true
    elseif input.KeyCode == Enum.KeyCode.A then flyControls.Left = true
    elseif input.KeyCode == Enum.KeyCode.D then flyControls.Right = true
    elseif input.KeyCode == Enum.KeyCode.Space then flyControls.Up = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift then flyControls.Down = true end
end)

UIS.InputEnded:Connect(function(input, processed)
    if not flying or processed then return end
    if input.KeyCode == Enum.KeyCode.W then flyControls.Forward = false
    elseif input.KeyCode == Enum.KeyCode.S then flyControls.Back = false
    elseif input.KeyCode == Enum.KeyCode.A then flyControls.Left = false
    elseif input.KeyCode == Enum.KeyCode.D then flyControls.Right = false
    elseif input.KeyCode == Enum.KeyCode.Space then flyControls.Up = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift then flyControls.Down = false end
end)

-- Noclip Function
local noclip, noclipParts = false, {}

local function noclipLoop()
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
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
    if noclip then
        noclipBtn.Text = "Noclip [ON]"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        noclipLoop()
    else
        noclipBtn.Text = "Noclip [OFF]"
        noclipBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        for part, canCollide in pairs(noclipParts) do
            if part.Parent then part.CanCollide = canCollide end
        end
        noclipParts = {}
    end
end)

-- ESP Function
local espPlayers, espBots, espBoxes = false, false, {}

local function createESP(target)
    if not target.Character then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_"..target.Name
    box.Adornee = target.Character:FindFirstChild("HumanoidRootPart")
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = Vector3.new(2, 3, 1)
    box.Transparency = 0.5
    box.Color3 = target:IsA("Player") and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    box.Parent = target.Character.HumanoidRootPart
    espBoxes[target] = box
end

local function clearESP()
    for _, box in pairs(espBoxes) do box:Destroy() end
    espBoxes = {}
end

local function updateESP()
    clearESP()
    if espPlayers then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= plr and player.Character then createESP(player) end
        end
    end
    if espBots then
        for _, npc in ipairs(workspace:GetChildren()) do
            if npc:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
                createESP(npc)
            end
        end
    end
end

espBtn.MouseButton1Click:Connect(function()
    espPlayers = not espPlayers
    espBtn.Text = espPlayers and "ESP Players [ON]" or "ESP Players [OFF]"
    espBtn.BackgroundColor3 = espPlayers and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
    updateESP()
end)

espBotsBtn.MouseButton1Click:Connect(function()
    espBots = not espBots
    espBotsBtn.Text = espBots and "ESP Bots [ON]" or "ESP Bots [OFF]"
    espBotsBtn.BackgroundColor3 = espBots and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40, 40, 40)
    updateESP()
end)

-- Character Handling
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    if flying then fly(true) end
    if noclip then noclipLoop() end
    updateESP()
end)

-- Main Loop
RS.Stepped:Connect(function()
    if flying and char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local dir = Vector3.new()
        if flyControls.Forward then dir = dir + root.CFrame.LookVector end
        if flyControls.Back then dir = dir - root.CFrame.LookVector end
        if flyControls.Left then dir = dir - root.CFrame.RightVector end
        if flyControls.Right then dir = dir + root.CFrame.RightVector end
        if flyControls.Up then dir = dir + Vector3.new(0, 1, 0) end
        if flyControls.Down then dir = dir - Vector3.new(0, 1, 0) end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new()
        bg.CFrame = root.CFrame
    end
    if noclip then noclipLoop() end
end)

-- Initial ESP
updateESP()
