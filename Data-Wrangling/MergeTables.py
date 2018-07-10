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

#Fuzzy Match Attempt
def fuzzy_match_attempt():
    try:
    	conn = database_conn()
    	df1 = pd.read_sql('SELECT Clave, id FROM artist_song_billboard WHERE id_lyrics IS NULL ORDER BY Clave', con = conn)
    	df2 = pd.read_sql('SELECT A.Clave, A.index FROM lyrics_kaggle A ORDER BY A.Clave', con = conn)
    	# Columns to match on from df_left
    	left_on = ["Clave"]
    	# Columns to match on from df_right
    	right_on = ["Clave"]
    	#df3 = fuzzymatcher.fuzzy_left_join(df1,df2,left_on,right_on)
    	df3 = fuzzymatcher.link_table(df1, df2, left_on, right_on)
    	print(df3.head(10))
    except Exception as e:
        print("Exception occurred \n" +str(e))

#Update IdLyrics Match Found
def match_found(id_lyrics,id):
    try:
        conn = database_conn()
        c = conn.cursor()
        sql = 'UPDATE artist_song_billboard SET id_lyrics = {id_lyrics} WHERE id = {id}'.\
        format(id_lyrics=id_lyrics, id=id)
        #print(sql)
        c.execute(sql)
        conn.commit()
        conn.close()
    except Exception as e:
        print("[Match Found] Exception occurred :" + str(e))


#Main Function
def main():
    try:
        #Obtaing a connection to the database
        conn = database_conn()
        #Obtain the Distinct Artist from the ranking data
        dfArtists = pd.read_sql('SELECT DISTINCT artist FROM artist_song_billboard WHERE id_lyrics IS NULL order by 1 desc',con = conn)
        #Iterate through each artist
        for Artist in dfArtists.artist:
            #Obtain Songs with rankings from current Artist
            cantante = Artist.translate ({ord(c): " " for c in "'!@#$%^&*()[]{};:,./<>?`~-=_\\+|"}).replace(' ','-').replace('"','').lower()
            print("Artista: " + Artist)
            dfSongs = pd.read_sql('SELECT id, song FROM artist_song_billboard WHERE id_lyrics IS NULL AND artist = "{}"'.format(Artist),con = conn)
            tkn = 10
            for Song in dfSongs.itertuples():
                cancion = Song.song.translate ({ord(c): " " for c in "'!@#$%^&*()[]{};:,./<>?`~-=_\\+|"}).replace(' ','-').replace('"','').lower()
                print("Cancion: " + cancion)
                while (tkn < 25):
                    #Find the id for the specific song and artist approximately
                    sql = 'SELECT A.index id_letra FROM lyrics_kaggle A WHERE artist = "{}" and song LIKE "{}%"'.format(cantante,cancion[:tkn])
                    dfLyric = pd.read_sql(sql,con = conn)
                    if len(dfLyric.id_letra) > 0:
                        print("Lyrics Index: " + str(dfLyric.id_letra[0]))
                        match_found(dfLyric.id_letra[0],Song.id)
                        tkn = 10
                        print("MATCH FOUND: [{song}] by [{artist}] [{id}]".format(song=Song.song,artist=Artist,id=Song.id))
                        break;
                    else:
                        tkn = tkn + 5
        conn.close()
    except Exception as e:
        print("Exception occurred: " +str(e))        
    

if __name__ == '__main__':
	main()