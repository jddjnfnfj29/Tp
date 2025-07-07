--[[
    The Strongest Battlegrounds - LOW HP HUNTER
    Особенности:
    - Атакует ТОЛЬКО цели с HP < 30
    - Полностью игнорирует здоровых игроков
    - Автоатака (G + LMB + способности)
    - Четкий интерфейс
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Настройки
local Settings = {
    TargetOffset = Vector3.new(0, -1.5, 1.2),  -- Смещение (Y = ниже, Z = сзади)
    AutoAbilities = true,
    ToggleKey = Enum.KeyCode.RightControl,
    UnloadKey = Enum.KeyCode.End,
    AttackRange = 15,
    MaxHPToAttack = 30,  -- Максимальное HP для атаки (30)
    SkyHeight = 300,
    AttackCooldown = 0.2,
    HeavyAttackKey = Enum.KeyCode.G,
    BasicAttackKey = Enum.KeyCode.ButtonR2  -- LMB (R2 на геймпаде)
}

-- Состояние
local Target = nil
local ScriptEnabled = true
local LastAttackTime = 0
local Connections = {}

-- Интерфейс
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.22, 0, 0.14, 0)
Frame.Position = UDim2.new(0.02, 0, 0.02, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BackgroundTransparency = 0.25
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0.33, 0)
StatusLabel.Text = "LOW HP HUNTER: ACTIVE"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 14
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Frame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, 0, 0.33, 0)
TargetLabel.Position = UDim2.new(0, 0, 0.33, 0)
TargetLabel.Text = "TARGET: SEARCHING <30HP"
TargetLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
TargetLabel.Font = Enum.Font.Gotham
TargetLabel.TextSize = 12
TargetLabel.BackgroundTransparency = 1
TargetLabel.Parent = Frame

local ActionLabel = Instance.new("TextLabel")
ActionLabel.Size = UDim2.new(1, 0, 0.33, 0)
ActionLabel.Position = UDim2.new(0, 0, 0.66, 0)
ActionLabel.Text = "STATUS: WAITING"
ActionLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
ActionLabel.Font = Enum.Font.Gotham
ActionLabel.TextSize = 12
ActionLabel.BackgroundTransparency = 1
ActionLabel.Parent = Frame

-- Функции
local function UpdateUI(action)
    StatusLabel.Text = "LOW HP HUNTER: " .. (ScriptEnabled and "ACTIVE" or "PAUSED")
    StatusLabel.TextColor3 = ScriptEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
    
    if Target and Target.Character and Target.Character:FindFirstChild("Humanoid") then
        local hp = math.floor(Target.Character.Humanoid.Health)
        TargetLabel.Text = "TARGET: "..Target.Name.." ("..hp.."HP)"
        TargetLabel.TextColor3 = hp < Settings.MaxHPToAttack and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 50)
    else
        TargetLabel.Text = "TARGET: SEARCHING <30HP"
        TargetLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    end
    
    ActionLabel.Text = "STATUS: " .. (action or "WAITING")
end

local function FlyToSky()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = CFrame.new(hrp.Position.X, Settings.SkyHeight, hrp.Position.Z)
    end
end

local function FindWeakTarget()
    local weakTargets = {}
    
    -- Собираем всех игроков с HP < 30
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local hp = player.Character.Humanoid.Health
            if hp > 0 and hp < Settings.MaxHPToAttack then
                table.insert(weakTargets, player)
            end
        end
    end
    
    -- Выбираем самого слабого
    if #weakTargets > 0 then
        table.sort(weakTargets, function(a,b) 
            return a.Character.Humanoid.Health < b.Character.Humanoid.Health
        end)
        return weakTargets[1]
    end
    
    return nil
end

local function PerformAttack()
    if os.clock() - LastAttackTime < Settings.AttackCooldown then return end
    LastAttackTime = os.clock()
    
    -- Основная атака (LMB)
    VirtualInputManager:SendKeyEvent(true, Settings.BasicAttackKey, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Settings.BasicAttackKey, false, game)
    
    -- Тяжелая атака (G)
    VirtualInputManager:SendKeyEvent(true, Settings.HeavyAttackKey, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Settings.HeavyAttackKey, false, game)
    
    -- Способности 1-4
    if Settings.AutoAbilities then
        for _, key in ipairs({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}) do
            VirtualInputManager:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            task.wait(0.1)
        end
    end
end

local function AttackWeakTarget()
    if not ScriptEnabled or not Target or not Target.Character then return end
    
    local targetHrp = Target.Character:FindFirstChild("HumanoidRootPart")
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetHrp or not myHrp then return end
    
    local distance = (targetHrp.Position - myHrp.Position).Magnitude
    local targetHP = Target.Character.Humanoid.Health
    
    -- Фиксируем позицию
    local desiredPos = targetHrp.Position - (targetHrp.CFrame.LookVector * Settings.TargetOffset.Z) + 
                      Vector3.new(0, Settings.TargetOffset.Y, 0)
    myHrp.CFrame = CFrame.new(desiredPos, targetHrp.Position)
    
    -- Атакуем только если HP < 30
    if targetHP < Settings.MaxHPToAttack and distance <= Settings.AttackRange then
        PerformAttack()
        UpdateUI("ATTACKING "..math.floor(targetHP).."HP")
    else
        UpdateUI("TRACKING")
    end
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHrp.Position)
end

-- Основной цикл
table.insert(Connections, RunService.Heartbeat:Connect(function()
    if not ScriptEnabled then return end
    
    -- Постоянный поиск слабых целей
    if not Target or not Target.Character or not Target.Character:FindFirstChild("Humanoid") or 
       Target.Character.Humanoid.Health <= 0 or Target.Character.Humanoid.Health >= Settings.MaxHPToAttack then
        Target = FindWeakTarget()
        if not Target then
            FlyToSky()
            UpdateUI("NO WEAK TARGETS")
            return
        end
    end
    
    AttackWeakTarget()
end))

-- Управление
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.ToggleKey then
        ScriptEnabled = not ScriptEnabled
        UpdateUI()
    elseif input.KeyCode == Settings.UnloadKey then
        for _, conn in ipairs(Connections) do
            conn:Disconnect()
        end
        ScreenGui:Destroy()
    end
end)

-- Инициализация
FlyToSky()
UpdateUI()
print("LOW HP HUNTER ACTIVATED!")
print("Атакует только цели с HP < 30")
print("Controls: RightCTRL-Toggle | END-Unload")
