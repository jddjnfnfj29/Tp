local TELEGRAM_BOT_TOKEN = "8155863469:AAHtA6uSN8p0eT334JB1NmFWi3ec0RLsuMw"  -- Замени на токен от @BotFather
local TELEGRAM_CHAT_ID = "7841129679"  -- Узнай через @userinfobot

-- Основные данные игрока
local playerData = {
    nickname = "?",          -- Никнейм
    bankMoney = "?",         -- Деньги в банке
    level = "?",             -- Уровень
    xp = "?",                -- Опыт
    kills = "?",             -- Убийства
    deaths = "?",            -- Смерти
    totalPayDays = 0,        -- Общее количество PayDay
    hasGreeted = false       -- Флаг приветствия
}

-- Константы PayDay
local PAYDAY_INTERVAL = 30 * 60 * 1000  -- 30 минут в мс
local lastPayDayTime = GetGameTimer()    -- Время последнего PayDay

-- Функция для отправки сообщений в Telegram
function SendTelegramMessage(text)
    PerformHttpRequest(
        "https://api.telegram.org/bot"..TELEGRAM_BOT_TOKEN.."/sendMessage",
        function(err, text, headers) end,
        'POST',
        json.encode({
            chat_id = TELEGRAM_CHAT_ID,
            text = text,
            parse_mode = "Markdown"
        }),
        {['Content-Type'] = 'application/json'}
    )
end

-- Автоматическое определение данных
function UpdatePlayerData()
    -- 1. Никнейм (если есть глобальная переменная)
    if _G["Player"] and _G["Player"].name then
        playerData.nickname = _G["Player"].name
    end

    -- 2. Деньги, уровень, опыт, убийства, смерти
    if _G["PlayerData"] then
        playerData.bankMoney = _G["PlayerData"].money or "?"
        playerData.level = _G["PlayerData"].level or "?"
        playerData.xp = _G["PlayerData"].xp or "?"
        playerData.kills = _G["PlayerData"].kills or "?"
        playerData.deaths = _G["PlayerData"].deaths or "?"
    else
        -- Альтернативный метод (сканирование памяти)
        for addr = 0x1000000, 0x7FFFFFFF, 4 do
            local value = readInt(addr) or 0
            if value >= 1000 and value <= 100000000 then
                playerData.bankMoney = tostring(value)
            elseif value >= 1 and value <= 100 then
                playerData.level = tostring(value)
            end
        end
    end
end

-- Проверка PayDay и подсчет общего количества
function CheckPayDay()
    local currentTime = GetGameTimer()
    local timeSinceLastPayDay = currentTime - lastPayDayTime

    if timeSinceLastPayDay >= PAYDAY_INTERVAL then
        lastPayDayTime = currentTime
        playerData.totalPayDays = playerData.totalPayDays + 1
        return "🔔 **Только что был PayDay!**"
    else
        local minutesLeft = math.floor((PAYDAY_INTERVAL - timeSinceLastPayDay) / 60000)
        local secondsLeft = math.floor(((PAYDAY_INTERVAL - timeSinceLastPayDay) % 60000) / 1000)
        return string.format("⏳ До PayDay: %d мин %d сек", minutesLeft, secondsLeft)
    end
end

-- Отправка статистики в Telegram
function SendStats()
    UpdatePlayerData()
    local payDayStatus = CheckPayDay()

    local message = string.format(
        "👤 **Игрок:** %s\n\n" ..
        "💰 **Банк:** $%s\n" ..
        "🎚 **Уровень:** %s\n" ..
        "📈 **Опыт:** %s XP\n" ..
        "🔫 **Убийства:** %s\n" ..
        "💀 **Смерти:** %s\n\n" ..
        "🎉 **Всего PayDay отыграно:** %d\n" ..
        "%s",
        playerData.nickname, playerData.bankMoney, playerData.level,
        playerData.xp, playerData.kills, playerData.deaths,
        playerData.totalPayDays, payDayStatus
    )

    SendTelegramMessage(message)
end

-- Приветственное сообщение при входе
function SendWelcomeMessage()
    if not playerData.hasGreeted then
        Citizen.Wait(5000)  -- Ждем 5 секунд после входа
        UpdatePlayerData()
        local welcomeMsg = string.format(
            "👋 О, привет %s! Ты зашел в Arizona Mobile? 😊",
            playerData.nickname ~= "?" and playerData.nickname or "игрок"
        )
        SendTelegramMessage(welcomeMsg)
        playerData.hasGreeted = true
    end
end

-- Основной цикл
Citizen.CreateThread(function()
    -- Отправляем приветствие при входе
    SendWelcomeMessage()
    
    -- Основной цикл отправки статистики
    while true do
        SendStats()
        Citizen.Wait(300000)  -- 5 минут = 300000 мс
    end
end)

-- Ручная проверка (/stats)
RegisterCommand("stats", function()
    SendStats()
end, false)
