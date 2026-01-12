--[[
  XenUI - Продвинутая UI-библиотека для Roblox
  Вдохновлено Rayfield и Luna UI
  Поддержка ПК и мобильных устройств
]]

local XenUI = {}
XenUI.__index = XenUI

-- Сервисы
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Глобальные переменные
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Проверка среды выполнения
local isSynapse = syn and syn.protect_gui
local isKrnl = KRNL_LOADED or getexecutorname and getexecutorname():lower():find("krnl")
local isScriptWare = SW_LOADED

-- Конфигурация
XenUI.Settings = {
    Theme = {
        Primary = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(0, 170, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        Background = Color3.fromRGB(15, 15, 15, 0.9)
    },
    Font = {
        Primary = Enum.Font.GothamSemibold,
        Secondary = Enum.Font.Gotham
    },
    AnimationSpeed = 0.25,
    MobileFloatingButtonSize = UDim2.new(0, 60, 0, 60),
    ConfigFolder = "XenUI_Configs"
}

-- Утилиты
local function Create(class, properties)
    local obj = Instance.new(class)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            if pcall(function() return obj[prop] end) then
                obj[prop] = value
            end
        end
    end
    if properties.Parent then
        obj.Parent = properties.Parent
    end
    return obj
end

local function Tween(Object, Properties, Duration)
    local TweenInfo = TweenInfo.new(Duration or XenUI.Settings.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local Tween = TweenService:Create(Object, TweenInfo, Properties)
    Tween:Play()
    return Tween
end

-- Система конфигов
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new()
    local self = setmetatable({}, ConfigSystem)
    self.Configs = {}
    self.CurrentConfig = "default"
    self.AutoSave = true
    return self
end

function ConfigSystem:SaveConfig(name)
    name = name or self.CurrentConfig
    local data = {}
    
    for elementId, value in pairs(self.Configs) do
        data[elementId] = value
    end
    
    local json = HttpService:JSONEncode(data)
    
    -- Проверка на наличие функций файловой системы
    if writefile then
        local success, err = pcall(function()
            if not isfolder then
                error("No isfolder function")
            end
            if not isfolder(XenUI.Settings.ConfigFolder) then
                makefolder(XenUI.Settings.ConfigFolder)
            end
            writefile(XenUI.Settings.ConfigFolder .. "/" .. name .. ".json", json)
        end)
        
        if not success then
            warn("[XenUI] Config save failed:", err)
            -- Сохраняем в DataStore как fallback
            if pcall(function() return game:GetService("DataStoreService") end) then
                local ds = game:GetService("DataStoreService"):GetDataStore("XenUI_Configs")
                pcall(function() ds:SetAsync(tostring(Player.UserId) .. "_" .. name, data) end)
            end
        end
    end
    
    return true
end

function ConfigSystem:LoadConfig(name)
    name = name or self.CurrentConfig
    
    -- Пробуем загрузить из файла
    if readfile then
        local path = XenUI.Settings.ConfigFolder .. "/" .. name .. ".json"
        if isfile and isfile(path) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(path))
            end)
            
            if success and data then
                self.Configs = data
                return true
            end
        end
    end
    
    -- Fallback на DataStore
    if pcall(function() return game:GetService("DataStoreService") end) then
        local ds = game:GetService("DataStoreService"):GetDataStore("XenUI_Configs")
        local success, data = pcall(function() 
            return ds:GetAsync(tostring(Player.UserId) .. "_" .. name)
        end)
        
        if success and data then
            self.Configs = data
            return true
        end
    end
    
    return false
end

function ConfigSystem:DeleteConfig(name)
    if delfile then
        local path = XenUI.Settings.ConfigFolder .. "/" .. name .. ".json"
        if isfile and isfile(path) then
            delfile(path)
            return true
        end
    end
    return false
end

function ConfigSystem:SetValue(elementId, value)
    self.Configs[elementId] = value
    if self.AutoSave then
        self:SaveConfig()
    end
end

function ConfigSystem:GetValue(elementId, defaultValue)
    return self.Configs[elementId] or defaultValue
end

-- Основной UI контейнер
local UILibrary = {}
UILibrary.__index = UILibrary

function XenUI:CreateLibrary(config)
    local self = setmetatable({}, UILibrary)
    
    self.Config = config or {}
    self.Windows = {}
    self.Elements = {}
    self.ConfigSystem = ConfigSystem.new()
    self.IsOpen = false
    
    -- Защита GUI для Synapse/Krnl
    self.ScreenGui = Create("ScreenGui", {
        Name = "XenUILibrary_" .. tostring(math.random(1, 99999)),
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    
    -- Применяем защиту если доступна
    if isSynapse then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    elseif isKrnl then
        if protectgui then
            protectgui(self.ScreenGui)
        end
        self.ScreenGui.Parent = CoreGui
    else
        self.ScreenGui.Parent = CoreGui
    end
    
    -- Floating button для мобильных устройств
    if UserInputService.TouchEnabled then
        self.FloatingButton = Create("ImageButton", {
            Name = "FloatingButton",
            BackgroundColor3 = XenUI.Settings.Theme.Accent,
            Position = UDim2.new(1, -70, 1, -70),
            Size = XenUI.Settings.MobileFloatingButtonSize,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Image = "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(524, 204),
            ImageRectSize = Vector2.new(36, 36),
            Parent = self.ScreenGui
        })
        
        local Corner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = self.FloatingButton
        })
        
        self.FloatingButton.MouseButton1Click:Connect(function()
            self:ToggleMainWindow()
        end)
        
        -- Делаем кнопку перетаскиваемой
        self:MakeDraggable(self.FloatingButton)
    end
    
    -- Hotkey для открытия/закрытия (только на ПК)
    if UserInputService.KeyboardEnabled then
        self.Hotkey = Enum.KeyCode.RightControl
        
        local hotkeyConnection
        hotkeyConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == self.Hotkey then
                self:ToggleMainWindow()
            end
        end)
        
        self.Connections = self.Connections or {}
        table.insert(self.Connections, hotkeyConnection)
    end
    
    -- Загружаем конфиг по умолчанию
    self.ConfigSystem:LoadConfig()
    
    return self
end

function UILibrary:MakeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function UILibrary:CreateWindow(options)
    local window = {}
    window.Name = options.Name or "Window"
    window.Size = options.Size or UDim2.new(0, 500, 0, 400)
    window.Position = options.Position or UDim2.new(0.5, -250, 0.5, -200)
    window.IsOpen = false
    
    -- Основной контейнер окна
    window.MainFrame = Create("Frame", {
        Name = window.Name,
        BackgroundColor3 = XenUI.Settings.Theme.Primary,
        Position = window.Position,
        Size = UDim2.new(0, 0, 0, 0), -- Начинаем с размера 0 для анимации
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        Parent = self.ScreenGui
    })
    
    -- Скругление углов
    local Corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = window.MainFrame
    })
    
    -- Stroke
    local Stroke = Create("UIStroke", {
        Color = XenUI.Settings.Theme.Accent,
        Thickness = 1,
        Parent = window.MainFrame
    })
    
    -- Тень
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Image = "rbxassetid://5554236805",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23,23,277,277),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Parent = window.MainFrame
    })
    
    -- Заголовок
    window.TitleBar = Create("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = XenUI.Settings.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = window.MainFrame
    })
    
    local TitleCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = window.TitleBar
    })
    
    window.Title = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = XenUI.Settings.Font.Primary,
        Text = window.Name,
        TextColor3 = XenUI.Settings.Theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.TitleBar
    })
    
    -- Кнопка закрытия
    window.CloseButton = Create("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 5),
        Size = UDim2.new(0, 30, 0, 30),
        Font = XenUI.Settings.Font.Primary,
        Text = "×",
        TextColor3 = XenUI.Settings.Theme.Text,
        TextSize = 24,
        Parent = window.TitleBar
    })
    
    window.CloseButton.MouseButton1Click:Connect(function()
        self:ToggleWindow(window)
    end)
    
    -- Контейнер для контента
    window.Content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 45),
        Size = UDim2.new(1, 0, 1, -45),
        Parent = window.MainFrame
    })
    
    -- Список вкладок
    window.TabsContainer = Create("Frame", {
        Name = "TabsContainer",
        BackgroundColor3 = XenUI.Settings.Theme.Secondary,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(0, 150, 1, -20),
        Parent = window.Content
    })
    
    local TabsCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = window.TabsContainer
    })
    
    window.TabsList = Create("ScrollingFrame", {
        Name = "TabsList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = XenUI.Settings.Theme.Accent,
        Parent = window.TabsContainer
    })
    
    local UIListLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = window.TabsList
    })
    
    local Padding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = window.TabsList
    })
    
    -- Контейнер для содержимого вкладок
    window.TabsContent = Create("Frame", {
        Name = "TabsContent",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 170, 0, 0),
        Size = UDim2.new(1, -180, 1, 0),
        Parent = window.Content
    })
    
    window.Tabs = {}
    window.ActiveTab = nil
    
    -- Делаем окно перетаскиваемым
    self:MakeDraggable(window.TitleBar)
    
    -- Методы окна
    function window:CreateTab(name)
        local tab = {}
        tab.Name = name
        tab.Sections = {}
        
        -- Кнопка вкладки
        tab.Button = Create("TextButton", {
            Name = name .. "Tab",
            BackgroundColor3 = XenUI.Settings.Theme.Primary,
            Size = UDim2.new(1, 0, 0, 40),
            Font = XenUI.Settings.Font.Primary,
            Text = name,
            TextColor3 = XenUI.Settings.Theme.SubText,
            TextSize = 14,
            LayoutOrder = #window.Tabs,
            Parent = window.TabsList
        })
        
        local ButtonCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = tab.Button
        })
        
        -- Контент вкладки
        tab.Content = Create("ScrollingFrame", {
            Name = name .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = XenUI.Settings.Theme.Accent,
            Visible = false,
            Parent = window.TabsContent
        })
        
        local TabListLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = tab.Content
        })
        
        local TabPadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            Parent = tab.Content
        })
        
        -- Обработчик клика по вкладке
        tab.Button.MouseButton1Click:Connect(function()
            window:SwitchTab(tab)
        end)
        
        -- Анимация при наведении на кнопку вкладки
        tab.Button.MouseEnter:Connect(function()
            if window.ActiveTab ~= tab then
                Tween(tab.Button, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)})
            end
        end)
        
        tab.Button.MouseLeave:Connect(function()
            if window.ActiveTab ~= tab then
                Tween(tab.Button, {BackgroundColor3 = XenUI.Settings.Theme.Primary})
            end
        end)
        
        -- Методы вкладки
        function tab:CreateSection(name)
            local section = {}
            section.Name = name
            section.Elements = {}
            
            -- Контейнер секции
            section.Container = Create("Frame", {
                Name = name .. "Section",
                BackgroundColor3 = XenUI.Settings.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 0),
                LayoutOrder = #tab.Sections,
                Parent = tab.Content
            })
            
            local SectionCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = section.Container
            })
            
            -- Stroke для секции
            local SectionStroke = Create("UIStroke", {
                Color = XenUI.Settings.Theme.Accent,
                Thickness = 1,
                Transparency = 0.5,
                Parent = section.Container
            })
            
            -- Заголовок секции
            section.Title = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                Font = XenUI.Settings.Font.Primary,
                Text = name,
                TextColor3 = XenUI.Settings.Theme.Text,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section.Container
            })
            
            -- Контейнер элементов
            section.Content = Create("Frame", {
                Name = "Content",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 0),
                Parent = section.Container
            })
            
            local ElementsList = Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                Parent = section.Content
            })
            
            local ElementsPadding = Create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                Parent = section.Content
            })
            
            -- Методы секции
            function section:UpdateSize()
                local totalHeight = 35
                for _, element in pairs(self.Elements) do
                    totalHeight += element.Height + 10
                end
                self.Container.Size = UDim2.new(1, 0, 0, totalHeight)
                
                -- Обновляем размер контента вкладки
                local tabHeight = 0
                for _, sec in pairs(tab.Sections) do
                    tabHeight += sec.Container.Size.Y.Offset + 10
                end
                tab.Content.CanvasSize = UDim2.new(0, 0, 0, tabHeight + 20)
            end
            
            function section:CreateButton(options)
                local element = {}
                element.Name = options.Name
                element.Height = 40
                element.Id = options.Name .. "_" .. HttpService:GenerateGUID(false)
                
                -- Контейнер кнопки
                element.Container = Create("Frame", {
                    Name = options.Name .. "Button",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, element.Height),
                    LayoutOrder = #section.Elements,
                    Parent = section.Content
                })
                
                -- Кнопка
                element.Button = Create("TextButton", {
                    Name = "Button",
                    BackgroundColor3 = XenUI.Settings.Theme.Primary,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = XenUI.Settings.Font.Primary,
                    Text = options.Name,
                    TextColor3 = XenUI.Settings.Theme.Text,
                    TextSize = 14,
                    Parent = element.Container
                })
                
                local ButtonCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = element.Button
                })
                
                -- Анимация при наведении
                element.Button.MouseEnter:Connect(function()
                    Tween(element.Button, {Backgroun
