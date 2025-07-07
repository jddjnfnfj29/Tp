# Пример шифрования на Python (можно использовать онлайн-конвертеры)
key = "mysecretkey123"
text = """print("Привет, эксплойты!")
game.Players.LocalPlayer:Kick("Скрипт работает!")"""

# XOR-шифрование
encrypted = "".join([chr(ord(c) ^ ord(key[i % len(key)])) for i, c in enumerate(text)])

# Кодируем в Base64
import base64
final_encrypted = base64.b64encode(encrypted.encode()).decode()

print(final_encrypted)  # Выведет что-то вроде: "X1ZcU1FWRlNTWFZQU1lWUFNWVlBTWQ=="
