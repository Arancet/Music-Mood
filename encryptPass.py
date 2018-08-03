from cryptography.fernet import Fernet
key = b'IXx5rHfP15FqP4ahx2pwcud-XmcBzU553Ri6p-nVhnc=' #Fernet.generate_key()
#print(key)
cipher_suite = Fernet(key)
ciphered_text = cipher_suite.encrypt(b'{"server": "musicmood-instance.ctjjankvidir.us-east-1.rds.amazonaws.com","user": "ivan","password": "12345678","dbname": "musicmood"}')   #required to be bytes
#print(ciphered_text)
#unciphered_text = (cipher_suite.decrypt(ciphered_text))
#print(unciphered_text)
with open('/usr/local/etc/musicmood_bytes.bin','wb') as file_object: file_object.write(ciphered_text)
print('Secure File Generated Sucessfully!')

