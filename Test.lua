local key = "projectKeyList"
local text = "SecretTextForRoblox"

-- XOR-шифрование в Lua
local encrypted = ""
for i = 1, #text do
    local key_char = key:sub((i-1) % #key + 1, (i-1) % #key + 1)
    encrypted = encrypted .. string.char(bit32.bxor(text:byte(i), key_char:byte(1)))
end

print("Зашифрованный текст:", encrypted)

-- Расшифровка
local decrypted = ""
for i = 1, #encrypted do
    local key_char = key:sub((i-1) % #key + 1, (i-1) % #key + 1)
    decrypted = decrypted .. string.char(bit32.bxor(encrypted:byte(i), key_char:byte(1)))
end

print("Расшифрованный текст:", decrypted)
