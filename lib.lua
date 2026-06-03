--[[
╔══════════════════════════════════════════════════════╗
║  UILib — Roblox UI Library                          ║
║  Стиль: iOS 26 · Боковая панель с иконками          ║
╚══════════════════════════════════════════════════════╝

  БЫСТРЫЙ СТАРТ:
  ──────────────
    local UILib = loadstring(game:HttpGet("URL"))()

    local win = UILib.new("My Script")

    local tabMain     = win:AddTab("Главная",   "rbxassetid://...", "home")
    local tabPlayer   = win:AddTab("Игрок",     "rbxassetid://...", "person")
    local tabVisual   = win:AddTab("Визуал",    "rbxassetid://...", "eye")
    local tabWorld    = win:AddTab("Мир",       "rbxassetid://...", "world")
    local tabSettings = win:AddTab("Настройки", "rbxassetid://...", "settings")

    win:AddToggle(tabMain, "Включить", false, function(val)
        print("toggle:", val)
    end)

    win:AddSlider(tabPlayer, "Скорость", 16, 200, 50, function(val)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end)

    win:AddButton(tabMain, "Телепорт к спавну", function()
        -- телепорт
    end)

    win:AddDropdown(tabSettings, "Язык", {"RU","EN","UA"}, "RU", function(val)
        print("язык:", val)
    end)

    win:AddKeybind(tabWorld, "Открыть меню", Enum.KeyCode.RightControl, function()
        win:Toggle()
    end)

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  МЕТОДЫ ОКНА:
    UILib.new(title)              -- создать окно
    win:AddTab(name, icon, id)    -- вкладка; icon = Enum.KeyCode иконки (строка для ImageLabel)
    win:Toggle()                  -- показать/скрыть окно
    win:Destroy()                 -- удалить UI
    win:Notify(text, duration)    -- тост-уведомление снизу

  МЕТОДЫ ВКЛАДКИ:
    win:AddToggle(tab, label, default, callback)
    win:AddSlider(tab, label, min, max, default, callback)
    win:AddButton(tab, label, callback)
    win:AddDangerButton(tab, label, callback)
    win:AddLabel(tab, text)
    win:AddSectionLabel(tab, text)
    win:AddSeparator(tab)
    win:AddDropdown(tab, label, options, default, callback)
    win:AddKeybind(tab, label, defaultKey, callback)
    win:AddColorPicker(tab, label, defaultColor, callback)   -- возвращает Color3

  ВОЗВРАЩАЕМЫЕ ОБЪЕКТЫ (для программного управления):
    local tog = win:AddToggle(...)
      tog.Set(true/false)   -- задать значение
      tog.Get()             -- получить текущее значение

    local sl = win:AddSlider(...)
      sl.Set(number)
      sl.Get()

    local dd = win:AddDropdown(...)
      dd.Set("EN")
      dd.Get()

    local kb = win:AddKeybind(...)
      kb.SetKey(Enum.KeyCode.F)
      kb.GetKey()

  ПРИМЕР — настройки языка:
  ──────────────────────────
    local dd = win:AddDropdown(tabSettings, "Язык", {"RU","EN","UA"}, "RU", function(lang)
        if lang == "RU" then
            -- переключить все тексты на русский
        elseif lang == "EN" then
            -- английский
        end
    end)

  ПРИМЕР — хоткей для toggle окна:
  ──────────────────────────────────
    win:AddKeybind(tabWorld, "Открыть меню", Enum.KeyCode.RightControl, function()
        win:Toggle()
    end)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]

local UILib = {}
UILib.__index = UILib

-- ─────────────────────────────────────────
-- ЦВЕТА (iOS 26 dark)
-- ─────────────────────────────────────────
local C = {
    bg          = Color3.fromRGB(10,  10,  18),
    sidebar     = Color3.fromRGB(8,   8,   14),
    surface     = Color3.fromRGB(20,  20,  34),
    surfaceHigh = Color3.fromRGB(30,  30,  50),
    accent      = Color3.fromRGB(94,  92,  230),
    accentHover = Color3.fromRGB(110, 108, 245),
    text        = Color3.fromRGB(232, 232, 245),
    textMuted   = Color3.fromRGB(130, 130, 160),
    separator   = Color3.fromRGB(40,  40,  60),
    toggleOn    = Color3.fromRGB(48,  209, 88),
    toggleOff   = Color3.fromRGB(60,  60,  85),
    danger      = Color3.fromRGB(255, 69,  58),
    white       = Color3.fromRGB(255, 255, 255),
}

-- ─────────────────────────────────────────
-- УТИЛИТЫ
-- ─────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local function tween(obj, props, t, style)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.15, style or Enum.EasingStyle.Quad),
        props
    ):Play()
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 12)
    c.Parent = parent
    return c
end

local function pad(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.Parent = parent
    return p
end

local function lbl(parent, text, size, color, xalign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or C.text
    l.Font = Enum.Font.GothamMedium
    l.TextSize = size or 13
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(80, 80, 110)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.7
    s.Parent = parent
    return s
end

-- Обновить высоту скролла вкладки
local function refreshScroll(scroll)
    local layout = scroll:FindFirstChildOfClass("UIListLayout")
    if layout then
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end
end

-- Создать карточку-строку
local function makeCard(parent, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, h or 44)
    f.BackgroundColor3 = C.surface
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 13)
    stroke(f, Color3.fromRGB(60, 60, 90), 1, 0.75)
    return f
end

-- ─────────────────────────────────────────
-- СОЗДАНИЕ ОКНА
-- ─────────────────────────────────────────
function UILib.new(title)
    local self = setmetatable({}, UILib)
    self._tabs       = {}
    self._visible    = true
    self._activeTab  = nil

    -- ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "UILib"
    self.Gui.ResetOnSpawn = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.DisplayOrder = 999
    self.Gui.Parent = game:GetService("CoreGui")

    -- Главный фрейм
    self.Win = Instance.new("Frame")
    self.Win.Size = UDim2.new(0, 360, 0, 460)
    self.Win.Position = UDim2.new(0.5, -180, 0.5, -230)
    self.Win.BackgroundColor3 = C.bg
    self.Win.BorderSizePixel = 0
    self.Win.Active = true
    self.Win.Draggable = true
    self.Win.ClipsDescendants = true
    self.Win.Parent = self.Gui
    corner(self.Win, 22)
    stroke(self.Win, Color3.fromRGB(90, 90, 130), 1, 0.55)

    -- ── БОКОВАЯ ПАНЕЛЬ ───────────────────
    self.Sidebar = Instance.new("Frame")
    self.Sidebar.Size = UDim2.new(0, 52, 1, 0)
    self.Sidebar.BackgroundColor3 = C.sidebar
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.Parent = self.Win

    -- Скруглить только левые углы боковой панели
    corner(self.Sidebar, 22)
    local sidebarFix = Instance.new("Frame")
    sidebarFix.Size = UDim2.new(1, 0, 0.5, 0)
    sidebarFix.Position = UDim2.new(0, 0, 0.5, 0)
    sidebarFix.Position = UDim2.new(1, -11, 0, 0)
    sidebarFix.Size = UDim2.new(0, 11, 1, 0)
    sidebarFix.BackgroundColor3 = C.sidebar
    sidebarFix.BorderSizePixel = 0
    sidebarFix.Parent = self.Sidebar

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.Padding = UDim.new(0, 2)
    sideLayout.Parent = self.Sidebar
    pad(self.Sidebar, 14, 0, 14, 0)

    -- Тонкая линия-разделитель между sidebar и контентом
    local sideDiv = Instance.new("Frame")
    sideDiv.Size = UDim2.new(0, 1, 1, 0)
    sideDiv.Position = UDim2.new(0, 51, 0, 0)
    sideDiv.BackgroundColor3 = C.separator
    sideDiv.BorderSizePixel = 0
    sideDiv.Parent = self.Win

    -- ── КОНТЕНТНАЯ ОБЛАСТЬ ───────────────
    self.ContentWrap = Instance.new("Frame")
    self.ContentWrap.Size = UDim2.new(1, -52, 1, 0)
    self.ContentWrap.Position = UDim2.new(0, 52, 0, 0)
    self.ContentWrap.BackgroundTransparency = 1
    self.ContentWrap.BorderSizePixel = 0
    self.ContentWrap.ClipsDescendants = true
    self.ContentWrap.Parent = self.Win

    -- Топбар
    self.Topbar = Instance.new("Frame")
    self.Topbar.Size = UDim2.new(1, 0, 0, 48)
    self.Topbar.BackgroundColor3 = C.bg
    self.Topbar.BorderSizePixel = 0
    self.Topbar.ZIndex = 2
    self.Topbar.Parent = self.ContentWrap

    local topDiv = Instance.new("Frame")
    topDiv.Size = UDim2.new(1, 0, 0, 1)
    topDiv.Position = UDim2.new(0, 0, 1, -1)
    topDiv.BackgroundColor3 = C.separator
    topDiv.BorderSizePixel = 0
    topDiv.Parent = self.Topbar

    self.TitleLabel = lbl(self.Topbar, title, 13, C.text)
    self.TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    self.TitleLabel.Font = Enum.Font.GothamBold

    -- Кнопка закрыть
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 12, 0, 12)
    closeBtn.Position = UDim2.new(1, -22, 0.5, -6)
    closeBtn.BackgroundColor3 = C.danger
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = ""
    closeBtn.ZIndex = 3
    closeBtn.Parent = self.Topbar
    corner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    -- Скролл для контента
    self.Scroll = Instance.new("ScrollingFrame")
    self.Scroll.Size = UDim2.new(1, 0, 1, -48)
    self.Scroll.Position = UDim2.new(0, 0, 0, 48)
    self.Scroll.BackgroundTransparency = 1
    self.Scroll.BorderSizePixel = 0
    self.Scroll.ScrollBarThickness = 2
    self.Scroll.ScrollBarImageColor3 = C.accent
    self.Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Scroll.Parent = self.ContentWrap

    -- Уведомления (тосты)
    self.NotifyFrame = Instance.new("Frame")
    self.NotifyFrame.Size = UDim2.new(0, 220, 0, 0)
    self.NotifyFrame.Position = UDim2.new(0.5, -110, 1, -60)
    self.NotifyFrame.BackgroundTransparency = 1
    self.NotifyFrame.Parent = self.Gui

    return self
end

-- ─────────────────────────────────────────
-- ДОБАВИТЬ ВКЛАДКУ
-- iconId: "" = без иконки, иначе rbxassetid://...
-- iconType: "home" | "person" | "eye" | "world" | "settings" и т.д.
--   (используется как заглушка если iconId пустой — показывает первую букву)
-- ─────────────────────────────────────────
function UILib:AddTab(name, iconId, iconType)
    local tab = {}
    local lib  = self

    -- Иконка/кнопка в сайдбаре
    tab.SideBtn = Instance.new("TextButton")
    tab.SideBtn.Size = UDim2.new(0, 38, 0, 38)
    tab.SideBtn.BackgroundColor3 = C.surfaceHigh
    tab.SideBtn.BackgroundTransparency = 1
    tab.SideBtn.BorderSizePixel = 0
    tab.SideBtn.Text = ""
    tab.SideBtn.AutoButtonColor = false
    tab.SideBtn.Parent = self.Sidebar
    corner(tab.SideBtn, 11)

    -- Полоска-активатор слева
    tab.ActiveBar = Instance.new("Frame")
    tab.ActiveBar.Size = UDim2.new(0, 3, 0, 0)  -- высота = 0 когда неактивна
    tab.ActiveBar.Position = UDim2.new(0, 0, 0.5, 0)
    tab.ActiveBar.AnchorPoint = Vector2.new(0, 0.5)
    tab.ActiveBar.BackgroundColor3 = C.accent
    tab.ActiveBar.BorderSizePixel = 0
    tab.ActiveBar.Parent = tab.SideBtn
    corner(tab.ActiveBar, 2)

    -- Иконка внутри кнопки
    if iconId and iconId ~= "" then
        -- Настоящая картинка
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0, 20, 0, 20)
        img.Position = UDim2.new(0.5, -10, 0.5, -10)
        img.BackgroundTransparency = 1
        img.Image = iconId
        img.ImageColor3 = C.textMuted
        img.Parent = tab.SideBtn
        tab._icon = img
    else
        -- Текстовая заглушка (первая буква или ключевое слово)
        local icons = {
            home     = "⌂", person = "◎", eye    = "◉",
            world    = "◈", settings = "⚙", star  = "★",
            lock     = "⊠", bell  = "⌘", list   = "≡",
        }
        local iconChar = icons[iconType or ""] or string.upper(string.sub(name, 1, 1))
        local iconLbl = lbl(tab.SideBtn, iconChar, 15, C.textMuted, Enum.TextXAlignment.Center)
        iconLbl.Size = UDim2.new(1, 0, 1, 0)
        iconLbl.Font = Enum.Font.GothamBold
        tab._icon = iconLbl
    end

    -- Тултип с названием при наведении
    tab.Tooltip = Instance.new("TextLabel")
    tab.Tooltip.Size = UDim2.new(0, 80, 0, 24)
    tab.Tooltip.Position = UDim2.new(0, 56, 0.5, -12)
    tab.Tooltip.BackgroundColor3 = C.surfaceHigh
    tab.Tooltip.BorderSizePixel = 0
    tab.Tooltip.Text = name
    tab.Tooltip.TextColor3 = C.text
    tab.Tooltip.Font = Enum.Font.GothamMedium
    tab.Tooltip.TextSize = 11
    tab.Tooltip.BackgroundTransparency = 1  -- скрыт по умолчанию
    tab.Tooltip.TextTransparency = 1
    tab.Tooltip.ZIndex = 10
    tab.Tooltip.Parent = tab.SideBtn
    corner(tab.Tooltip, 6)

    tab.SideBtn.MouseEnter:Connect(function()
        tween(tab.Tooltip, {BackgroundTransparency = 0, TextTransparency = 0}, 0.1)
    end)
    tab.SideBtn.MouseLeave:Connect(function()
        tween(tab.Tooltip, {BackgroundTransparency = 1, TextTransparency = 1}, 0.1)
    end)

    -- Фрейм контента вкладки
    tab.Frame = Instance.new("Frame")
    tab.Frame.Size = UDim2.new(1, 0, 1, 0)
    tab.Frame.BackgroundTransparency = 1
    tab.Frame.Visible = false
    tab.Frame.Parent = self.Scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = tab.Frame
    pad(tab.Frame, 10, 12, 10, 12)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        refreshScroll(self.Scroll)
    end)

    tab.SideBtn.MouseButton1Click:Connect(function()
        lib:_selectTab(tab)
    end)

    table.insert(self._tabs, tab)
    if #self._tabs == 1 then
        self:_selectTab(tab)
    end

    return tab
end

function UILib:_selectTab(selected)
    for _, t in ipairs(self._tabs) do
        t.Frame.Visible = false
        t.SideBtn.BackgroundTransparency = 1
        if t._icon then
            t._icon.TextColor3 = C.textMuted
            if t._icon:IsA("ImageLabel") then
                t._icon.ImageColor3 = C.textMuted
            end
        end
        tween(t.ActiveBar, {Size = UDim2.new(0, 3, 0, 0)}, 0.15)
    end
    selected.Frame.Visible = true
    selected.SideBtn.BackgroundTransparency = 0
    selected.SideBtn.BackgroundColor3 = Color3.fromRGB(94, 92, 230, 0.15)
    tween(selected.SideBtn, {BackgroundColor3 = Color3.fromRGB(28, 26, 65)}, 0.15)
    if selected._icon then
        if selected._icon:IsA("ImageLabel") then
            tween(selected._icon, {ImageColor3 = C.accent}, 0.15)
        else
            tween(selected._icon, {TextColor3 = C.accent}, 0.15)
        end
    end
    tween(selected.ActiveBar, {Size = UDim2.new(0, 3, 0, 18)}, 0.2, Enum.EasingStyle.Back)
    -- Обновить заголовок
    refreshScroll(self.Scroll)
    self._activeTab = selected
end

-- ─────────────────────────────────────────
-- СЕКЦИЯ-ЗАГОЛОВОК
-- ─────────────────────────────────────────
function UILib:AddSectionLabel(tab, text)
    local l = lbl(tab.Frame, string.upper(text), 10, C.textMuted)
    l.Size = UDim2.new(1, 0, 0, 22)
    l.Font = Enum.Font.GothamBold
    pad(l, 0, 0, 0, 2)
end

-- ─────────────────────────────────────────
-- МЕТКА
-- ─────────────────────────────────────────
function UILib:AddLabel(tab, text)
    local l = lbl(tab.Frame, text, 12, C.textMuted)
    l.Size = UDim2.new(1, 0, 0, 22)
    pad(l, 0, 0, 0, 4)
end

-- ─────────────────────────────────────────
-- РАЗДЕЛИТЕЛЬ
-- ─────────────────────────────────────────
function UILib:AddSeparator(tab)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 1)
    f.BackgroundColor3 = C.separator
    f.BorderSizePixel = 0
    f.Parent = tab.Frame
end

-- ─────────────────────────────────────────
-- ТОГГЛ
-- default: true/false
-- callback(bool)
-- ─────────────────────────────────────────
function UILib:AddToggle(tab, label, default, callback)
    local card = makeCard(tab.Frame, 44)
    local state = default == true

    local l = lbl(card, label, 13, C.text)
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 42, 0, 25)
    track.Position = UDim2.new(1, -52, 0.5, -12)
    track.BackgroundColor3 = state and C.toggleOn or C.toggleOff
    track.BorderSizePixel = 0
    track.Parent = card
    corner(track, 13)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 21, 0, 21)
    knob.Position = state and UDim2.new(0, 19, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 11)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = card

    btn.MouseButton1Click:Connect(function()
        state = not state
        tween(track, {BackgroundColor3 = state and C.toggleOn or C.toggleOff}, 0.18)
        tween(knob,  {Position = state and UDim2.new(0,19,0.5,-10) or UDim2.new(0,2,0.5,-10)}, 0.18)
        if callback then callback(state) end
    end)

    if callback and state then callback(state) end

    return {
        Set = function(val)
            state = val
            track.BackgroundColor3 = state and C.toggleOn or C.toggleOff
            knob.Position = state and UDim2.new(0,19,0.5,-10) or UDim2.new(0,2,0.5,-10)
            if callback then callback(state) end
        end,
        Get = function() return state end,
    }
end

-- ─────────────────────────────────────────
-- СЛАЙДЕР
-- callback(number)
-- ─────────────────────────────────────────
function UILib:AddSlider(tab, label, min, max, default, callback)
    local card = makeCard(tab.Frame, 54)

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, -28, 0, 18)
    topRow.Position = UDim2.new(0, 14, 0, 9)
    topRow.BackgroundTransparency = 1
    topRow.Parent = card

    local l = lbl(topRow, label, 12, C.text)
    l.Size = UDim2.new(0.65, 0, 1, 0)

    local valLbl = lbl(topRow, tostring(default or min), 12, C.accent, Enum.TextXAlignment.Right)
    valLbl.Size = UDim2.new(0.35, 0, 1, 0)
    valLbl.Position = UDim2.new(0.65, 0, 0, 0)
    valLbl.Font = Enum.Font.GothamBold

    local trackBg = Instance.new("Frame")
    trackBg.Size = UDim2.new(1, -28, 0, 4)
    trackBg.Position = UDim2.new(0, 14, 0, 36)
    trackBg.BackgroundColor3 = C.surfaceHigh
    trackBg.BorderSizePixel = 0
    trackBg.Parent = card
    corner(trackBg, 2)

    local value = math.clamp(default or min, min, max)
    local pct = (value - min) / (max - min)

    local trackFill = Instance.new("Frame")
    trackFill.Size = UDim2.new(pct, 0, 1, 0)
    trackFill.BackgroundColor3 = C.accent
    trackFill.BorderSizePixel = 0
    trackFill.Parent = trackBg
    corner(trackFill, 2)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(pct, -8, 0.5, -8)
    thumb.BackgroundColor3 = C.white
    thumb.BorderSizePixel = 0
    thumb.Parent = trackBg
    corner(thumb, 8)

    local dragging = false

    thumb.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    local function applyInput(inputPos)
        local abs = trackBg.AbsolutePosition
        local sz  = trackBg.AbsoluteSize
        local relX = math.clamp(inputPos.X - abs.X, 0, sz.X)
        local p = relX / sz.X
        value = math.floor(min + (max - min) * p + 0.5)
        local cp = (value - min) / (max - min)
        trackFill.Size = UDim2.new(cp, 0, 1, 0)
        thumb.Position = UDim2.new(cp, -8, 0.5, -8)
        valLbl.Text = tostring(value)
        if callback then callback(value) end
    end

    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            applyInput(inp.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    if callback then callback(value) end

    return {
        Set = function(val)
            value = math.clamp(val, min, max)
            local p = (value - min) / (max - min)
            trackFill.Size = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, -8, 0.5, -8)
            valLbl.Text = tostring(value)
            if callback then callback(value) end
        end,
        Get = function() return value end,
    }
end

-- ─────────────────────────────────────────
-- КНОПКА (акцентная)
-- callback()
-- ─────────────────────────────────────────
function UILib:AddButton(tab, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = C.accent
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = C.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = tab.Frame
    corner(btn, 13)

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = C.accentHover}, 0.1)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = C.accent}, 0.1)
    end)
    btn.MouseButton1Down:Connect(function()
        tween(btn, {BackgroundColor3 = Color3.fromRGB(80, 78, 200)}, 0.05)
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, {BackgroundColor3 = C.accentHover}, 0.08)
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- ─────────────────────────────────────────
-- КНОПКА DANGER (красная)
-- callback()
-- ─────────────────────────────────────────
function UILib:AddDangerButton(tab, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 14, 12)
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(255, 90, 78)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.Parent = tab.Frame
    corner(btn, 13)
    stroke(btn, Color3.fromRGB(200, 60, 50), 1, 0.6)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

-- ─────────────────────────────────────────
-- ДРОПДАУН
-- options: {"RU","EN","UA"}
-- callback(selectedOption)
-- ─────────────────────────────────────────
function UILib:AddDropdown(tab, label, options, default, callback)
    local card = makeCard(tab.Frame, 44)
    local selected = default or options[1]

    local l = lbl(card, label, 13, C.text)
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)

    -- Контейнер чипов
    local chipRow = Instance.new("Frame")
    chipRow.Size = UDim2.new(0.5, -14, 1, 0)
    chipRow.Position = UDim2.new(0.5, 0, 0, 0)
    chipRow.BackgroundTransparency = 1
    chipRow.Parent = card

    local chipLayout = Instance.new("UIListLayout")
    chipLayout.FillDirection = Enum.FillDirection.Horizontal
    chipLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    chipLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    chipLayout.Padding = UDim.new(0, 4)
    chipLayout.Parent = chipRow

    local chips = {}
    for _, opt in ipairs(options) do
        local chip = Instance.new("TextButton")
        chip.Size = UDim2.new(0, math.max(34, #opt * 8 + 16), 0, 24)
        chip.BackgroundColor3 = opt == selected
            and Color3.fromRGB(40, 38, 100)
            or  C.surfaceHigh
        chip.BorderSizePixel = 0
        chip.Text = opt
        chip.TextColor3 = opt == selected and C.accent or C.textMuted
        chip.Font = Enum.Font.GothamMedium
        chip.TextSize = 11
        chip.AutoButtonColor = false
        chip.Parent = chipRow
        corner(chip, 8)
        if opt == selected then
            stroke(chip, C.accent, 1, 0.55)
        end
        chips[opt] = chip

        chip.MouseButton1Click:Connect(function()
            -- Снять выделение со всех
            for _, c in pairs(chips) do
                tween(c, {BackgroundColor3 = C.surfaceHigh, TextColor3 = C.textMuted}, 0.1)
                local s = c:FindFirstChildOfClass("UIStroke")
                if s then s:Destroy() end
            end
            -- Выделить нажатый
            tween(chip, {BackgroundColor3 = Color3.fromRGB(40,38,100), TextColor3 = C.accent}, 0.1)
            stroke(chip, C.accent, 1, 0.55)
            selected = opt
            if callback then callback(selected) end
        end)
    end

    if callback and selected then callback(selected) end

    return {
        Set = function(val)
            for _, c in pairs(chips) do
                c.BackgroundColor3 = C.surfaceHigh
                c.TextColor3 = C.textMuted
                local s = c:FindFirstChildOfClass("UIStroke")
                if s then s:Destroy() end
            end
            if chips[val] then
                chips[val].BackgroundColor3 = Color3.fromRGB(40,38,100)
                chips[val].TextColor3 = C.accent
                stroke(chips[val], C.accent, 1, 0.55)
            end
            selected = val
            if callback then callback(selected) end
        end,
        Get = function() return selected end,
    }
end

-- ─────────────────────────────────────────
-- ХОТКЕЙ
-- defaultKey: Enum.KeyCode.RightControl
-- callback() — вызывается при нажатии клавиши
-- ─────────────────────────────────────────
function UILib:AddKeybind(tab, label, defaultKey, callback)
    local card = makeCard(tab.Frame, 44)
    local currentKey = defaultKey
    local listening = false

    local l = lbl(card, label, 13, C.text)
    l.Size = UDim2.new(1, -110, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 90, 0, 28)
    keyBtn.Position = UDim2.new(1, -100, 0.5, -14)
    keyBtn.BackgroundColor3 = C.surfaceHigh
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = currentKey and currentKey.Name or "—"
    keyBtn.TextColor3 = C.accent
    keyBtn.Font = Enum.Font.GothamMedium
    keyBtn.TextSize = 11
    keyBtn.AutoButtonColor = false
    keyBtn.Parent = card
    corner(keyBtn, 9)
    stroke(keyBtn, C.accent, 1, 0.65)

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = C.textMuted
    end)

    UserInputService.InputBegan:Connect(function(inp, processed)
        if processed then return end
        if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
            currentKey = inp.KeyCode
            keyBtn.Text = currentKey.Name
            keyBtn.TextColor3 = C.accent
            listening = false
        elseif not listening and inp.KeyCode == currentKey then
            if callback then callback() end
        end
    end)

    return {
        SetKey = function(key)
            currentKey = key
            keyBtn.Text = key.Name
        end,
        GetKey = function() return currentKey end,
    }
end

-- ─────────────────────────────────────────
-- ПОКАЗАТЬ / СКРЫТЬ ОКНО
-- ─────────────────────────────────────────
function UILib:Toggle()
    self._visible = not self._visible
    self.Win.Visible = self._visible
end

-- ─────────────────────────────────────────
-- ТОСТ-УВЕДОМЛЕНИЕ
-- win:Notify("Скрипт включён", 3)
-- ─────────────────────────────────────────
function UILib:Notify(text, duration)
    duration = duration or 3

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 220, 0, 36)
    toast.BackgroundColor3 = C.surface
    toast.BorderSizePixel = 0
    toast.Position = UDim2.new(0.5, -110, 1, 10)  -- начинает снизу
    toast.Parent = self.Gui
    corner(toast, 12)
    stroke(toast, C.accent, 1, 0.6)

    local t = lbl(toast, text, 12, C.text, Enum.TextXAlignment.Center)
    t.Size = UDim2.new(1, -20, 1, 0)
    t.Position = UDim2.new(0, 10, 0, 0)

    -- Анимация появления
    tween(toast, {Position = UDim2.new(0.5, -110, 1, -50)}, 0.25, Enum.EasingStyle.Back)

    task.delay(duration, function()
        tween(toast, {Position = UDim2.new(0.5, -110, 1, 10)}, 0.2)
        task.wait(0.3)
        toast:Destroy()
    end)
end

-- ─────────────────────────────────────────
-- УНИЧТОЖИТЬ
-- ─────────────────────────────────────────
function UILib:Destroy()
    self.Gui:Destroy()
end

return UILib
