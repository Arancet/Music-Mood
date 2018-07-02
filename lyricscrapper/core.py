# -*- encoding: utf-8 -*-
import re
import urllib.request
from bs4 import BeautifulSoup
from user_agent import generate_user_agent
from cryptography.fernet import Fernet
import pymysql
import random
import time
import json
from collections import namedtuple
#from selenium import webdriver

#Every record in the file has and ID, the main query 
#search for unprocessed songs within a range from Min to Max limits
#MIN_LIMIT = 386686
#MAX_LIMIT = 515580
MIN_LIMIT = 1
MAX_LIMIT = 515580

#It is defined to make a pause every 150 songs tried 
PAUSE_THRESHOLD = 150
#It is going to pause for ten seconds
PAUSE_LENGHT = 20

#Allow to scrape the lyrics from azlyrics.com [My IP is blocked from this one :(]
def get_song_lyrics_az(artist, song_title):
    """Made artist and song title lower"""
    artist =  artist.lower()
    song_title = song_title.lower()
    artist = replace_accent(artist)
    song_title = replace_accent(song_title)
    #remove every special caracter except alphanumeric from artist and song title
    artist = re.sub('[^A-Za-z0-9]+', "", artist)
    song_title = re.sub('[^A-Za-z0-9]+', "", song_title)
    if artist.startswith("the"):    # remove starting 'the' from artist e.g. the who -> who
        artist = artist[3:]
    #Making URLS    
    azurl = "http://azlyrics.com/lyrics/"+artist+"/"+song_title+".html"
    print(azurl)
    lyrics = "NA"
    try:
    	#AZLYRICS PROCESSING
        soup = URL_Processing(azurl,False)
        lyrics = str(soup)
        if(lyrics!="NA"):
            if(len(lyrics)==0 or lyrics == None):
                return "NA"
            # lyrics lies between up_partition and down_partition
            up_partition = '<!-- Usage of azlyrics.com content by any third-party lyrics provider is prohibited by our licensing agreement. Sorry about that. -->'
            down_partition = '<!-- MxM banner -->'
            lyrics = lyrics.split(up_partition)[1]
            lyrics = lyrics.split(down_partition)[0]
            lyrics = lyrics.replace('<br>','').replace('<br/>','').replace('</div>','').strip()
            lyrics = lyrics.replace('"','').replace("'","")
            lyrics = lyrics.encode('latin1').decode('utf8')
            lyrics = replace_accent(lyrics)
        return lyrics
    except Exception as e:
        print("[Exception]: " + str(e))
        return "NA"
        #TODO: store error in database for lesson learned, return NA
        #return "Exception occurred \n" +str(e)

#Allow to scrape the lyrics from metrolyrics.com
def get_song_lyrics_metro(artist, song_title):
    """Made artist and song title lower"""
    artist =  artist.lower()
    artist2 = artist.replace(' ', '-') #dash separated
    song_title = song_title.lower()
    song_title2 = song_title.replace(' ', '-').replace('í','i')
    artist2 = replace_accent(artist2)
    song_title2 = replace_accent(song_title2)
    if artist2.startswith("the_"):    # remove starting 'the' from artist e.g. the who -> who
        artist2 = artist2[4:]
    #Making URLS    
    
    metrourl = "http://metrolyrics.com/"+song_title2+"-lyrics-"+artist2+".html"
    print(metrourl)
    lyrics = "NA"
    try:

        #METROLYRICS PROCESSING
        soup = URL_Processing(metrourl,True)
        lyrics = str(soup)
        if(lyrics!="NA"):
            if(len(lyrics)==0 or lyrics == None):
                return "NA"
            # lyrics lies divided in three sections 
            first_section = '<!-- First Section -->'
            widget_related = '<!--WIDGET - RELATED-->'
            second_section = '<!-- Second Section -->'
            widget_photos = '<!--WIDGET - PHOTOS-->'
            third_section = '<!-- Third Section -->'
            bottom_mpu = '<!--BOTTOM MPU-->'
            lyrics = lyrics.split(first_section)[1]
            first_section = lyrics.split(widget_related)[0]
            lyrics = lyrics.split(widget_related)[1]
            lyrics = lyrics.split(second_section)[1]
            second_section = lyrics.split(widget_photos)[0]
            lyrics = lyrics.split(widget_photos)[1]
            lyrics = lyrics.split(third_section)[1]
            third_section = lyrics.split(bottom_mpu)[0]
            lyrics = first_section+"\t"+ second_section +"\t"+third_section
            lyrics = lyrics.replace('<p class="verse">','').replace('<br/>','').replace('</p>','').strip()
            lyrics = lyrics.replace('<div style="height:69px; background-color: transparent;"></div>','').strip()
            lyrics = lyrics.replace('"','').replace("'","")
            lyrics = replace_accent(lyrics)
            lyrics = lyrics.encode('latin1').decode('utf8')
        return lyrics
    except Exception as e:
        print("[Exception]: " + str(e))
        return "NA"
        #TODO: store error in database for lesson learned, return NA
        #return "Exception occurred \n" +str(e)
           
#Allow to scrape the lyrics from songlyrics.com
def get_song_lyrics_song(artist, song_title):
    """Made artist and song title lower"""
    artist =  artist.lower()
    artist2 = artist.replace(' ', '-')
    song_title = song_title.lower()
    artist2 = replace_accent(artist2)
    song_title = replace_accent(song_title)
    song_title2 = song_title.replace(' ', '-')
    #remove every special caracter except alphanumeric from artist and song title
    artist = re.sub('[^A-Za-z0-9]+', "", artist)
    song_title = re.sub('[^A-Za-z0-9]+', "", song_title)
    if artist2.startswith("the_"):    # remove starting 'the' from artist e.g. the who -> who
        artist2 = artist2[4:]
    #SONGLYRICS PROCESSING   
    songurl = "http://songlyrics.com/"+artist2+"/"+song_title2+"-lyrics/"
    print(songurl)
    lyrics = "NA"
    try:
        #SONGSLYRICS PROCESSING
        soup = URL_Processing(songurl,False)
        if(soup!="NA"):
            # lyrics lies within the p tag with id = songLyricsDiv
            letra = soup.find_all("p", {"id":"songLyricsDiv"})
            if(len(letra)==0 or letra == None):
                return "NA"
            lyrics= str(letra[0])
            if(lyrics.find("We do not have the lyrics for")!= -1):
                return  "NA"
            if(lyrics.find("<div style=height:250px; background-color: transparent;></div>")!= -1):
                return  "NA"    
            lyrics = lyrics.replace('<p class="songLyricsV14 iComment-text" id="songLyricsDiv">','').replace('<br/>','').replace('</p>','').strip()
            lyrics = lyrics.encode('latin1').decode('utf8')
            lyrics = lyrics.replace('"','').replace("'","")
            lyrics = replace_accent(lyrics)
        return lyrics
    except Exception as e:
        print("[Exception]: " + str(e))
        return "NA"
        #TODO: store error in database for lesson learned, return NA
        #return "Exception occurred \n" +str(e)    

#Allow to scrape the lyrics from lyricsmode.com
def get_song_lyrics_mode(artist, song_title):
    """Made artist and song title lower"""
    artist =  artist.lower()
    artist3 = artist.replace(' ','_')
    song_title = song_title.lower()
    artist3 = replace_accent(artist3)
    song_title = replace_accent(song_title)
    #Making URLS    
    modeurl = "http://www.lyricsmode.com/lyrics/"+artist[:1]+"/"+artist3+"/"+song_title+".html"
    print(modeurl)
    lyrics = "NA"
    try:
        #LYRICSMODE PROCESSING
        soup = URL_Processing(modeurl,True)
        lyrics = str(soup)
        if(lyrics!="NA"):
            if(len(lyrics)==0 or lyrics == None):
                return "NA"
            # lyrics lies within the p tag with id = songLyricsDiv
            letra = soup.find_all("p", {"id":"lyrics_text"})
            lyrics= str(letra[0])
            lyrics = lyrics.replace('<p class="ui-annotatable" id="lyrics_text">','').replace('<br/>','').replace('</p>','').strip()
            lyrics = lyrics.replace('"','').replace("'","")
            lyrics = lyrics.encode('latin1').decode('utf8')
            lyrics = replace_accent(lyrics)
        return lyrics
    except Exception as e:
        print("[Exception]: " + str(e))
        return "NA"
        #TODO: store error in database for lesson learned, return NA
        #return "Exception occurred \n" +str(e)

#Allow to scrape the lyrics from lyric.wikia.com using firefox and geckodriver to call a browser and obtain lyrics from there
def get_song_lyrics_wikia(artist, song_title):
    """Made artist and song title lower"""
    artist =  artist.lower()
    artist3 = artist.replace(' ','_')
    song_title = song_title.lower()
    artist3 = replace_accent(artist3)
    song_title = replace_accent(song_title)
    song_title = song_title.replace(' ','_')
    #Making URLS    
    wikiaurl = "http://lyrics.wikia.com/wiki/"+artist3+":"+song_title
    print(wikiaurl)
    lyrics = "NA"
    try:
        #WIKIA PROCESSING
        driver = webdriver.Firefox()
        driver.get(wikiaurl)
        html = driver.page_source
        soup = BeautifulSoup(html, "lxml")
        #soup = URL_Processing(wikiaurl,True)
        lyrics = str(soup)
        if(lyrics!="NA"):
            if(len(lyrics)==0 or lyrics == None):
                return "NA"
            # lyrics lies within the div tag with class = lyricbox
            letra = soup.find_all("div", {"class":"lyricbox"}) 
            lyrics= str(letra[0])
            lyrics = lyrics.replace('<br/>',' ').replace('</p>',' ').strip()
            lyrics = lyrics.replace('"','').replace("'","")
            lyrics = lyrics.encode('latin1').decode('utf8')
            lyrics = replace_accent(lyrics)
            lyrics = lyrics.replace('<div class=lyricbox>',' ').replace('<div class=lyricsbreak>',' ').replace('</div>',' ')
        return lyrics
    except Exception as e:
        print("[Exception]: " + str(e))
        return "NA"

#Allow to replace special characters in vowels
def replace_accent(name):
    name = name.replace('å','a').replace('á','a').replace('é','e').replace('ë','e')
    name = name.replace('í','i').replace('ï','i').replace('ó','o').replace('ô','o')
    name = name.replace('ú','u').replace('ú','u').replace('ê','e').replace('ç','c')
    name = name.replace('ä','a')
    name = name.encode('utf-8', 'ignore').decode('utf-8')
    name = name.encode('ascii', 'ignore').decode('ascii')
    return name

#Setup the connection with the headers, the current proxy (is changing via cron)
#You can tell if you need it to use proxy or not.        
def URL_Processing(URL, useproxy):
        try:
            #Create the object, assign it to a variable
            if(useproxy):
                proxy = urllib.request.ProxyHandler({'http': 'localhost:8118'})
            proxy = urllib.request.ProxyHandler({})    
            #Construct a new opener using your proxy settings
            opener = urllib.request.build_opener(proxy)
            #Install the openen on the module-level
            urllib.request.install_opener(opener)
            #Setup Headers to simulate browser 
            headers = {'User-Agent': generate_user_agent(device_type="desktop", os=('mac', 'linux'))}
            #print(headers)
            req = urllib.request.Request(URL,None,headers)
            #print(str(req.__class__))
            content = urllib.request.urlopen(req, timeout=10).read()
            soup = BeautifulSoup(content, 'html.parser')
            return soup
        except Exception as e:
            print("[Exception Processing]: " + str(e))
            return "NA"          

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

#Default None values
def ifnull(var, val):
  if var is None:
    return val
  return var

#Choose the initial site randomly and then check in every other one.
#Store the lyrics in the database
def choosepath(row):
    #param row contains: rowid, trackid, song, artist, year  in that order
    #1 azlyrics, 2 metro lyrics, 3 song lyrics, 4 lyrics mode
    path = random.randint(1,4)
    print(time.strftime("%a, %d %b %Y %H:%M:%S +0000", time.gmtime()) + " Path: "+str(path))
    lyric = "NA"
    if(path==1):
        lyric = get_song_lyrics_az(row[3],row[2])
        if(lyric=="NA"):
            lyric = get_song_lyrics_metro(row[3],row[2])
            if(lyric=="NA"):
                lyric = get_song_lyrics_song(row[3],row[2])
                if(lyric=="NA"):
                    lyric = get_song_lyrics_mode(row[3],row[2])
                    set_lyric(int(row[0]),lyric,4)
                else:
                    set_lyric(int(row[0]),lyric,3)
            else:
                set_lyric(int(row[0]),lyric,2)
        else:
            set_lyric(int(row[0]),lyric,1)        
    elif(path==2):
        lyric = get_song_lyrics_metro(row[3],row[2])
        if(lyric=="NA"):
            lyric = get_song_lyrics_az(row[3],row[2])
            if(lyric=="NA"):
                lyric = get_song_lyrics_song(row[3],row[2])
                if(lyric=="NA"):
                    lyric = get_song_lyrics_mode(row[3],row[2])
                    set_lyric(int(row[0]),lyric,4)
                else:
                    set_lyric(int(row[0]),lyric,3)
            else:
                set_lyric(int(row[0]),lyric,1)
        else:
            set_lyric(int(row[0]),lyric,2)       
    elif(path==3):
        lyric = get_song_lyrics_song(row[3],row[2])
        if(lyric=="NA"):
            lyric = get_song_lyrics_az(row[3],row[2])
            if(lyric=="NA"):
                lyric = get_song_lyrics_metro(row[3],row[2])
                if(lyric=="NA"):
                    lyric = get_song_lyrics_mode(row[3],row[2])
                    set_lyric(int(row[0]),lyric,4)
                else:
                    set_lyric(int(row[0]),lyric,2)
            else:
                set_lyric(int(row[0]),lyric,1)
        else:
            set_lyric(int(row[0]),lyric,3)        
    elif(path==4):
        lyric = get_song_lyrics_mode(row[3],row[2])
        if(lyric=="NA"):
            lyric = get_song_lyrics_az(row[3],row[2])
            if(lyric=="NA"):
                lyric = get_song_lyrics_metro(row[3],row[2])
                if(lyric=="NA"):
                    lyric = get_song_lyrics_song(row[3],row[2])
                    set_lyric(int(row[0]),lyric,3)
                else:
                    set_lyric(int(row[0]),lyric,2)
            else:
                set_lyric(int(row[0]),lyric,1)
        else:
            set_lyric(int(row[0]),lyric,4)        
    #else:
        #return "0|NA"         

#Retrieve the Songs from the database
def get_songs():
    #Load song names and artists from  SQLite
    try:
        db = database_conn()
        c = db.cursor()
        sql = 'SELECT id, trackid, song, artist, year from songs_dataset where id between {min_limit} and {max_limit} and lyrics IS NULL order by year desc LIMIT 10'.\
        format(min_limit=MIN_LIMIT, max_limit=MAX_LIMIT)
        #sql = 'SELECT id, trackid, song, artist, year from songs_dataset where id between {min_limit} and {max_limit} and lyrics like "We do not have%" order by year desc LIMIT 10'.\
        #format(min_limit=MIN_LIMIT, max_limit=MAX_LIMIT)
        #print(sql)
        c.execute(sql)
        db.close()
        return c.fetchall()
    except Exception as e:
        print("[DB Exception]: " + str(e))    

#Convert the lyrics in one line of text
def format_lyric(lyric):
    lyric = lyric.replace("\r", "\t")
    lyric = lyric.replace("'"," ")
    lyric = lyric.replace("\n", "\t")
    lyric = lyric.strip()
    return lyric

#Store the lyrics in the database
def set_lyric(id, lyric, source):
    try:
        lyric = format_lyric(lyric)
        db = database_conn()
        c = db.cursor()
        sql = 'UPDATE songs_dataset SET lyrics = "{lyrics}", source = {source} WHERE id = {id}' .\
        format(lyrics=lyric, source = source, id=id) 
        #print(sql)
        c.execute(sql)
        db.commit()
        print("["+str(id)+"]-[Db OK]")
    except Exception as e:
        # Rollback in case there is any error
        print("[DB Exception]: " + str(e))
        db.rollback()
    db.close()

#Main Processing Function
def main():
    try:
        cont = MIN_LIMIT;
        k =0;
        print("Welcome to the Version 1.0.1!")
        rows = get_songs()
        while (True):
            if(k==10):
                rows = get_songs()
                k=0
            print("Tracks: " + str(len(rows)))
            #Iterate through all the songs getting the lyrics
            for row in rows:
                print("["+str(row[0])+"]:"+row[2]+" by "+row[3])
                #choosepath method returns a string of the form path|lyric
                choosepath(row)
                #lyric = get_song_lyrics_wikia(row[3],row[2])
                #set_lyric(int(row[0]),lyric,5)
                if(cont % PAUSE_THRESHOLD == 0):
                    print("Time to Rest...")
                    time.sleep(random.randint(5,PAUSE_LENGHT))
                cont = cont + 1
                print(str(cont))
                k = k + 1
            #TEST
            #print(get_song_lyrics_az("Van Halen", "Jump"))
    except Exception as e:
        print("Exception occurred \n" +str(e))
    

if __name__ == '__main__':
	main()

