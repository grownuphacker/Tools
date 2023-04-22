from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
from base64 import b64encode, b64decode
from binascii import unhexlify

iv = "7bde5a0f3f39fd658efc45de143cbc94"
iv = unhexlify(iv)
key = b'3e83b13d99bf0de6c6bde5ac5ca4ae68'
cipher = AES.new(key, AES.MODE_CBC, iv)

# This is where your source code goes for the other bits n pieces. 
your_source_code = """
import getpass

username = getpass.getuser()
# This code has a comment just to mess with things
print(f"{username} is the most powerful security practitioner in the world")
"""

encrypted_source = b64encode(cipher.encrypt(pad(your_source_code.encode('utf-8'), AES.block_size))).decode('utf-8')
print("Encrypted source:\n\t* * *\n", encrypted_source)
print("iv: ",iv)
print("key: ",key)
print("\t* * *\nValidating Source Codei:\n\t* * *")
exec(your_source_code)
