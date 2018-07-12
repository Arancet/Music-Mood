import pymysql
from cryptography.fernet import Fernet
import json
from collections import namedtuple
import pandas as pd
import fuzzymatcher #import link_table, left_join
import time
from pprint import pprint
from sqlalchemy import create_engine 


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

#Setup the database connection
def sqlalchemy_engine():
    try:
        credentials = unencrypt()
        user_id = credentials.user
        user_password = credentials.password
        dbname = credentials.dbname
        server = credentials.server
        connstring = "mysql+mysqldb://{user}:{password}@{server}/{dbname}".format(server=server,user=user_id,password=user_password,dbname=dbname)
        engine = create_engine(connstring)
        return engine
    except Exception as e:
        print("Exception occurred \n" +str(e))        

#Fuzzy Match Attempt
def fuzzy_match_attempt_one():
    try:
    	conn = database_conn()
    	df1 = pd.read_sql('SELECT Clave, id FROM artist_song_billboard WHERE id_lyrics IS NULL ORDER BY Clave', con = conn)
    	df2 = pd.read_sql('SELECT A.Clave, A.index id_letra FROM lyrics_kaggle A ORDER BY A.Clave', con = conn)
    	# Columns to match on from df_left
    	left_on = ["Clave"]
    	# Columns to match on from df_right
    	right_on = ["Clave"]
    	#df3 = fuzzymatcher.fuzzy_left_join(df1,df2,left_on,right_on)
    	df3 = fuzzymatcher.link_table(df1, df2, left_on, right_on)
    	df3.head(10)
    except Exception as e:
        print("Exception occurred \n" +str(e))

#Fuzzy Match Attempt
def fuzzy_match_attempt_two():
    try:
        conn = database_conn()
        year = 1957
        while(year < 2019):
            df1 = pd.read_sql('SELECT id, artist_kaggle, song_kaggle, year_kaggle FROM song_artist_universe WHERE id_lyrics_kaggle IS NULL and year_kaggle = {year} ORDER BY artist_kaggle'.format(year=year), con = conn)
            df2 = pd.read_sql('SELECT id, artist, song, year FROM lyrics_kaggle WHERE year = {year} ORDER BY artist'.format(year=year), con = conn)
            # Columns to match on from df_left
            left_on = ["artist_kaggle","song_kaggle","year_kaggle"]
            # Columns to match on from df_right
            right_on = ["artist","song","year"]
            #df3 = fuzzymatcher.fuzzy_left_join(df1,df2,left_on,right_on)
            start_time = time.time()
            try:
                df = fuzzymatcher.link_table(df1, df2, left_on, right_on)
                print("--- %s seconds ---" % (time.time() - start_time))
                mtch = df.loc[df['match_score']>= 0.38]
                mtch.to_sql(con = sqlalchemy_engine(), name='fuzzy_matches', if_exists='append')
                print("Year: {yr} - DB [OK]".format(yr=year))
            except Exception as e:
                print("Problem with year [{yr}] - [{e}]".format(yr=year,e=str(e)))    
            year = year + 1
    except Exception as e:
        print("Exception occurred \n" +str(e))

#Fuzzy Match Attempt
def fuzzy_match_songs_dataset():
    try:
        conn = database_conn()
        year = 1922
        while(year < 2019):
            df1 = pd.read_sql('SELECT artist_kaggle, song_kaggle, year FROM songs_dataset WHERE id_lyrics_kaggle IS NULL and year = {year} ORDER BY artist_kaggle'.format(year=year), con = conn)
            df2 = pd.read_sql('SELECT artist, song, year FROM lyrics_kaggle WHERE year = {year} ORDER BY artist'.format(year=year), con = conn)
            # Columns to match on from df_left
            left_on = ["artist_kaggle","song_kaggle","year"]
            # Columns to match on from df_right
            right_on = ["artist","song","year"]
            #df3 = fuzzymatcher.fuzzy_left_join(df1,df2,left_on,right_on)
            start_time = time.time()
            try:
                df = fuzzymatcher.link_table(df1, df2, left_on, right_on)
                print("--- %s seconds ---" % (time.time() - start_time))
                mtch = df.loc[df['match_rank'] == 1]
                mtch.to_sql(con = sqlalchemy_engine(), name='fuzzy_match_songs_dataset', if_exists='append')
                print("Year: {yr} - DB [OK]".format(yr=year))
            except Exception as e:
                print("Problem with year [{yr}] - [{e}]".format(yr=year,e=str(e)))    
            year = year + 1
    except Exception as e:
        print("Exception occurred \n" +str(e))

#Update IdLyrics Match Found
def match_found(id_lyrics,id):
    try:
        conn = database_conn()
        c = conn.cursor()
        sql = 'UPDATE song_artist_universe SET id_lyrics_kaggle = {id_lyrics} WHERE id = {id}'.\
        format(id_lyrics=id_lyrics, id=id)
        #print(sql)
        c.execute(sql)
        conn.commit()
        conn.close()
    except Exception as e:
        print("[Match Found] Exception occurred :" + str(e))

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

#Approximate Song Algorithm: Artist -> Song
def approximate_song_match():
    try:
        #Obtaing a connection to the database
        conn = database_conn()
        #Obtain the Distinct Artist from the ranking data
        sql1 = 'SELECT DISTINCT artist_kaggle FROM song_artist_universe WHERE id_lyrics_kaggle IS NULL AND \
            year_kaggle IN (1969,1978,1993,1997,1998,2002,2009.2010,2011,2012,2013,2014,2015,2017,2018)  order by 1'
        #print(sql1)
        dfArtists = pd.read_sql(sql1,con = conn)
        #Iterate through each artist
        for Artist in dfArtists.artist_kaggle:
            #Obtain Songs with rankings from current Artist
            cantante = Artist.translate ({ord(c): " " for c in "'!@#$%^&*()[]{};:,./<>?`~-=_\\+|"}).replace(' ','-').replace('"','').lower()
            print("Artista: " + Artist)
            dfSongs = pd.read_sql('SELECT id, song_kaggle FROM song_artist_universe WHERE id_lyrics_kaggle IS NULL AND \
                year_kaggle IN (1969,1978,1993,1997,1998,2002,2009.2010,2011,2012,2013,2014,2015,2017,2018) AND artist_kaggle = "{}"'.format(Artist),con = conn)
            tkn = 10
            for Song in dfSongs.itertuples():
                cancion = Song.song_kaggle.translate ({ord(c): " " for c in "'!@#$%^&*()[]{};:,./<>?`~-=_\\+|"}).replace(' ','-').replace('"','').lower()
                print("Cancion: " + cancion)
                while (tkn < 25):
                    #Find the id for the specific song and artist approximately
                    sql = 'SELECT id FROM lyrics_kaggle  WHERE year IN (1969,1978,1993,1997,1998,2002,2009.2010,2011,2012,2013,2014,2015,2017,2018) \
                     AND artist = "{}" and song LIKE "{}%"'.format(cantante,cancion[:tkn])
                    dfLyric = pd.read_sql(sql,con = conn)
                    if len(dfLyric.id) > 0:
                        print("Lyrics ID: " + str(dfLyric.id[0]))
                        match_found(dfLyric.id[0],Song.id)
                        tkn = 10
                        print("MATCH FOUND: [{song}] by [{artist}] [{id}]".format(song=Song.song_kaggle,artist=Artist,id=Song.id))
                        break;
                    else:
                        tkn = tkn + 5
        conn.close()
    except Exception as e:
        print("Exception occurred: " +str(e))

#Approximate Song Algorithm: Artist -> Song
def approximate_song_match_no_year():
    try:
        #Obtaing a connection to the database
        conn = database_conn()
        #Obtain the Distinct Artist from the ranking data
        sql1 = 'SELECT DISTINCT artist_kaggle FROM song_artist_universe WHERE id_lyrics_kaggle IS NULL order by 1'
        #print(sql1)
        dfArtists = pd.read_sql(sql1,con = conn)
        #Iterate through each artist
        for Artist in dfArtists.artist_kaggle:
            #Obtain Songs with rankings from current Artist
            cantante = Artist.translate ({ord(c): " " for c in "'!@#$%^&*()[]{};:,./<>?`~-=_\\+|"}).replace(' ','-').replace('"','').lower()
            print("Artista: " + Artist)
            dfSongs = pd.read_sql('SELECT id, song_kaggle FROM song_artist_universe WHERE id_lyrics_kaggle IS NULL AND artist_kaggle = "{}"'.format(Artist),con = conn)
            tkn = 10
            for Song in dfSongs.itertuples():
                cancion = Song.song_kaggle.translate ({ord(c): " " for c in "'!@#$%^&*()[]{};:,./<>?`~-=_\\+|"}).replace(' ','-').replace('"','').lower()
                print("Cancion: " + cancion)
                while (tkn < 25):
                    #Find the id for the specific song and artist approximately
                    sql = 'SELECT id FROM lyrics_kaggle  WHERE artist = "{}" and song LIKE "%{}%"'.format(cantante,cancion[:tkn])
                    dfLyric = pd.read_sql(sql,con = conn)
                    if len(dfLyric.id) > 0:
                        print("Lyrics ID: " + str(dfLyric.id[0]))
                        match_found(dfLyric.id[0],Song.id)
                        tkn = 10
                        print("MATCH FOUND: [{song}] by [{artist}] [{id}]".format(song=Song.song_kaggle,artist=Artist,id=Song.id))
                        break;
                    else:
                        tkn = tkn + 5
        conn.close()
    except Exception as e:
        print("Exception occurred: " +str(e))        

#Main Function
def main():
    try:
        print("Version 0.0.3 \n Welcome!")
        #fuzzy_match_attempt_two();
        #approximate_song_match();
        #approximate_song_match_no_year();
        fuzzy_match_songs_dataset();
    except Exception as e:
        print("Exception occurred: " +str(e))   


if __name__ == '__main__':
	main()