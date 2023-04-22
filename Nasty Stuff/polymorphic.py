import os
import random
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
from base64 import b64encode, b64decode
from binascii import unhexlify, hexlify
import secrets

def mutate_source(decrypted_source):
    filename = os.path.abspath(__file__)

    new_iv_readable = secrets.token_hex(16)
    new_iv = unhexlify(new_iv_readable)

    new_key_readable = secrets.token_hex(16)
    new_key = bytes(new_key_readable, 'utf-8')

    encrypt_cipher = AES.new(new_key, AES.MODE_CBC, new_iv)
    encrypted_data = pad(decrypted_source.encode('utf-8'), AES.block_size)
    new_source_encrypted = b64encode(encrypt_cipher.encrypt(encrypted_data)).decode('utf-8')
    #    cipher = AES.new(new_key, AES.MODE_CBC, new_iv)

    with open(filename, 'r') as file:
        lines = file.readlines()

    for i, line in enumerate(lines):
        if line.startswith("source_encrypted"):
            lines[i] = f"source_encrypted = \'{new_source_encrypted}\'\n"
        elif line.startswith("iv = \'"):
            lines[i] = f"iv = \'{new_iv_readable}\'\n"
        elif line.startswith("key = \'"):
            lines[i] = f"key = \'{new_key_readable}\'\n"

    with open(filename, 'w') as file:
        file.writelines(lines)

iv = '7bde5a0f3f39fd658efc45de143cbc94'
iv = unhexlify(iv)

key = '3e83b13d99bf0de6c6bde5ac5ca4ae68'
key = bytes(key, 'utf-8')

source_encrypted = 'rlwnC4udhkX1FNcI6SQVfML37bL+pHQyeu3Bc7Ou3Yfu4AC4F/WQ5OeaLtAVWlMgBOyqd9Alp38I6xIscHZ/OBi5P6s2uPyROROsKJISZKntAsZBztj37LuEqSYyBnchmn/FEzFvr31OkgXgP4G5qz2qgxxO9CpeenvwdgiMb7K6oNyD4X7GO9oR0+xCUStepeQQQsN/sYKUsSeTOh60MNwWNT5rqdXeFWvpAsgjKD0='

cipher = AES.new(key, AES.MODE_CBC, iv)
decrypted_source = unpad(cipher.decrypt(b64decode(source_encrypted)), AES.block_size).decode('utf-8')
exec(decrypted_source)

mutate_source(decrypted_source)
