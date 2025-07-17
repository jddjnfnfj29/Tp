-- Конфигурация
local BOT_TOKEN = "8155863469:AAHtA6uSN8p0eT334JB1NmFWi3ec0RLsuMw"
local CHAT_ID = "7841129679"

-- Данные игрока (примерные значения)
local player = {
    name = "Bogdan",
    bank = 1500000,
    level = 42,
    xp = 1850,
    kills = 56,
    deaths = 23,
    paydays = 0,
    last_payday = 0
}

-- Отправка сообщения в Telegram
function send(msg)
    PerformHttpRequest("https://api.telegram.org/bot"..BOT_TOKEN.."/sendMessage", 
    function(err, text, headers) end, 'POST', 
    json.encode({
        chat_id = CHAT_ID,
        text = msg,
        parse_mode = "Markdown"
    }), 
    {['Content-Type'] = 'application/json'})
end

-- Обновление данных (заглушка - замените на реальные методы)
function updateStats()
    -- Здесь должен быть код получения реальных данных
    player.bank = player.bank + math.random(1000, 5000)
    player.xp = player.xp + math.random(10, 100)
    player.kills = player.kills + math.random(0, 3)
    
    -- Автоповышение уровня
    if player.xp >= (player.level+1)*1000 then
        player.level = player.level + 1
        send("🎉 *Новый уровень!* Теперь у вас "..player.level.." lvl")
    end
end

-- Проверка PayDay
function checkPayDay()
    local now = GetGameTimer()
    if now - player.last_payday >= 1800000 then -- 30 минут
        player.paydays = player.paydays + 1
        player.last_payday = now
        local amount = math.random(5000, 20000)
        player.bank = player.bank + amount
        send("💰 *PAYDAY!* +$"..amount.."\n💵 Всего в банке: $"..player.bank)
    end
end

-- Отправка полной статистики
function sendFullStats()
    updateStats()
    local stats = string.format([[
*👤 %s [LVL %d]*
━━━━━━━━━━━━
💵 *Банк:* $%d
📊 *Опыт:* %d/%d XP
⚔️ *K/D:* %d/%d
🎰 *Всего PayDay:* %d
⏳ *Следующий PayDay через:* %d мин
━━━━━━━━━━━━
_Обновлено: %s_
    ]],
    player.name,
    player.level,
    player.bank,
    player.xp, (player.level+1)*1000,
    player.kills, player.deaths,
    player.paydays,
    math.floor((1800000 - (GetGameTimer() - player.last_payday))/60000),
    os.date("%H:%M:%S"))
    
    send(stats)
end

-- Обработчик команды /bogdan
RegisterCommand("bogdan", function()
    sendFullStats()
    send("⚡ *Bogdan Script* успешно работает!")
end, false)

-- Инициализация
Citizen.CreateThread(function()
    -- Ждем загрузки игры
    Citizen.Wait(5000)
    
    -- Первое сообщение
    send([[
🚀 *BOGDAN SCRIPT ЗАПУЩЕН*
━━━━━━━━━━━━
✔️ *Версия:* 2.4.2
✔️ *Статус:* Активен
✔️ *Игрок:* ]]..player.name..[[
✔️ *Время:* ]]..os.date("%H:%M:%S")..[[
━━━━━━━━━━━━
_Для проверки введите_ */bogdan* _в чат игры_
    ]])
    
    -- Основной цикл PayDay
    while true do
        checkPayDay()
        Citizen.Wait(60000) -- Проверка каждую минуту
    end
end)

-- Фоновое обновление статистики
Citizen.CreateThread(function()
    while true do
        updateStats()
        Citizen.Wait(300000) -- Обновление каждые 5 минут
    end
end)
