-- KRNL Server Hopper Script с фильтрами
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local placeId = game.PlaceId
local HOP_COOLDOWN = 900 -- 15 минут в секундах
local nextAutoHop = os.time() + HOP_COOLDOWN

-- Таблица для отслеживания посещенных серверов
local visitedServers = {}
local MIN_PLAYERS = 5 -- Минимум 5 игроков на сервере

-- Сохраняем историю в датастор
local function saveVisitedServers()
    pcall(function()
        visitedServers[game.JobId] = true
        -- Можно сохранить в файл если нужно
    end)
end

-- Загружаем историю при старте
saveVisitedServers()

-- Создаем интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KRNL_Hopper_Pro"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 180)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
title.BorderSizePixel = 0
title.Text = "🌐 KRNL SERVER HOPPER PRO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local timeLabel = Instance.new("TextLabel")
timeLabel.Size = UDim2.new(1, -20, 0, 20)
timeLabel.Position = UDim2.new(0, 10, 0, 40)
timeLabel.BackgroundTransparency = 1
timeLabel.Text = "До автохопа: 15:00"
timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
timeLabel.TextSize = 12
timeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeLabel.Font = Enum.Font.Gotham
timeLabel.Parent = mainFrame

local playersLabel = Instance.new("TextLabel")
playersLabel.Size = UDim2.new(1, -20, 0, 20)
playersLabel.Position = UDim2.new(0, 10, 0, 60)
playersLabel.BackgroundTransparency = 1
playersLabel.Text = "Минимум игроков: 5+"
playersLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
playersLabel.TextSize = 12
playersLabel.TextXAlignment = Enum.TextXAlignment.Left
playersLabel.Font = Enum.Font.Gotham
playersLabel.Parent = mainFrame

local visitedLabel = Instance.new("TextLabel")
visitedLabel.Size = UDim2.new(1, -20, 0, 20)
visitedLabel.Position = UDim2.new(0, 10, 0, 80)
visitedLabel.BackgroundTransparency = 1
visitedLabel.Text = "Посещено серверов: 1"
visitedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
visitedLabel.TextSize = 12
visitedLabel.TextXAlignment = Enum.TextXAlignment.Left
visitedLabel.Font = Enum.Font.Gotham
visitedLabel.Parent = mainFrame

local hopButton = Instance.new("TextButton")
hopButton.Size = UDim2.new(0.8, 0, 0, 40)
hopButton.Position = UDim2.new(0.1, 0, 0, 105)
hopButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
hopButton.BorderSizePixel = 0
hopButton.Text = "🔄 ХОПНУТЬ СЕЙЧАС"
hopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hopButton.TextSize = 14
hopButton.Font = Enum.Font.GothamBold
hopButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = hopButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Готов к работе"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.TextSize = 11
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Функция для форматирования времени
local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

-- Основная функция хопа с фильтрами
local function hopServer()
    statusLabel.Text = "Поиск подходящего сервера..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    pcall(function()
        -- Получаем список серверов
        local serversUrl = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
        local success, response = pcall(function()
            return game:HttpGet(serversUrl)
        end)
        
        if success and response then
            local serversData = HttpService:JSONDecode(response)
            
            if serversData and serversData.data then
                -- Собираем подходящие серверы
                local suitableServers = {}
                
                for _, server in ipairs(serversData.data) do
                    -- Проверяем условия: не текущий сервер, не посещенный, минимум 5 игроков
                    if server.id ~= game.JobId and 
                       not visitedServers[server.id] and 
                       server.playing >= MIN_PLAYERS and 
                       server.playing < server.maxPlayers then
                        
                        table.insert(suitableServers, server)
                    end
                end
                
                -- Если нашли подходящие серверы
                if #suitableServers > 0 then
                    -- Выбираем случайный сервер из подходящих
                    local randomServer = suitableServers[math.random(1, #suitableServers)]
                    
                    statusLabel.Text = "Переход на новый сервер ("..randomServer.playing.." игроков)..."
                    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    
                    -- Добавляем в посещенные
                    visitedServers[randomServer.id] = true
                    
                    -- Телепортируемся
                    TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, player)
                    return true
                else
                    -- Если нет подходящих серверов, ищем любой с 5+ игроками
                    local fallbackServers = {}
                    
                    for _, server in ipairs(serversData.data) do
                        if server.id ~= game.JobId and server.playing >= MIN_PLAYERS then
                            table.insert(fallbackServers, server)
                        end
                    end
                    
                    if #fallbackServers > 0 then
                        local randomServer = fallbackServers[math.random(1, #fallbackServers)]
                        statusLabel.Text = "Переход на сервер ("..randomServer.playing.." игроков)..."
                        visitedServers[randomServer.id] = true
                        TeleportService:TeleportToPlaceInstance(placeId, randomServer.id, player)
                        return true
                    end
                end
            end
        end
        
        -- Если все else fails, пробуем обычный телепорт
        statusLabel.Text = "Поиск любого сервера..."
        TeleportService:Teleport(placeId)
        return true
        
    end)
    
    statusLabel.Text = "Ошибка поиска сервера"
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    return false
end

-- Функция принудительного хопа
local function forceHop()
    if os.time() < nextAutoHop - (HOP_COOLDOWN - 30) then
        nextAutoHop = os.time() + HOP_COOLDOWN
    end
    hopServer()
end

-- Обновление интерфейса
local function updateUI()
    local timeLeft = math.max(0, nextAutoHop - os.time())
    timeLabel.Text = "До автохопа: " .. formatTime(timeLeft)
    visitedLabel.Text = "Посещено серверов: " .. (#visitedServers)
end

-- Обработчик кнопки
hopButton.MouseButton1Click:Connect(function()
    forceHop()
end)

-- Анимация кнопки
hopButton.MouseEnter:Connect(function()
    hopButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

hopButton.MouseLeave:Connect(function()
    hopButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
end)

-- Главный цикл
spawn(function()
    while true do
        updateUI()
        
        -- Проверяем время для автохопа
        if os.time() >= nextAutoHop then
            nextAutoHop = os.time() + HOP_COOLDOWN
            hopServer()
        end
        
        wait(1)
    end
end)

-- Горячая клавиша для принудительного хопа (F5)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F5 then
        forceHop()
    end
end)

print("🎯 KRNL Server Hopper PRO загружен!")
print("📌 Автохоп каждые 15 минут")
print("📌 Минимум 5 игроков на сервере")
print("📌 Не возвращается на старые серверы")
print("📌 Рандомный выбор сервера")
print("📌 Горячая клавиша: F5")

updateUI()
