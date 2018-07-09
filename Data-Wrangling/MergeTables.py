import pymysql
from cryptography.fernet import Fernet
import json
from collections import namedtuple
import pandas as pd
import fuzzymatcher #import link_table, left_join

#Uncode the secret license file
def unencrypt():
    try:
        key = b'IXx5rHfP15FqP4ahx2pwcud-XmcBzU553Ri6p-nVhnc=' #Fernet.generate_key()
        cipher_suite = Fernet(key)
        with open('/usr/local/etc/musicmood_bytes.bin', 'rb') as file_object:
            for line in file_object:
                encryptedpwd = line
        uncipher_text = (cipher_suite.decrypt(encryptedpwd))
        plain_text_encryptedpassword = bytes(uncipher_text).decode("utf-8") #convert to string
        x = json.loads(plain_text_encryptedpassword, object_hook=lambda d: namedtuple('X', d.keys())(*d.values()))
        return x
    except Exception as e:
        print(str(e))
        return "Error"  

#Setup the database connection
def database_conn():
    try:
        credentials = unencrypt()
        user_id = credentials.user
        user_password = credentials.password
        dbname = credentials.dbname
        server = credentials.server
        conn = pymysql.connect(server,user_id,user_password,dbname)
        return conn
    except Exception as e:
        print("Exception occurred \n" +str(e))

#Main Processing Function
def main():
    try:
    	conn = database_conn()
    	df1 = pd.read_sql('SELECT Clave, id FROM artist_song_billboard WHERE id_lyrics IS NULL ORDER BY Clave', con = conn)
    	df2 = pd.read_sql('SELECT A.Clave, A.index FROM lyrics_kaggle A ORDER BY A.Clave', con = conn)
    	# Columns to match on from df_left
    	left_on = ["Clave"]
    	# Columns to match on from df_right
    	right_on = ["Clave"]
    	df3 = fuzzymatcher.fuzzy_left_join(df1,df2,left_on,right_on)
    	print(df3.head(10))
    except Exception as e:
        print("Exception occurred \n" +str(e))
    

if __name__ == '__main__':
	main()