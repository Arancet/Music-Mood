"""
Ivan Narvaez (2018) Georgetown University
in87@georgetown.edu

This code contains a set of methods to:
Extract/decompress tar.gz files
Extract specific records from an specific dataset in a HDF5 file 
Store them in a MySql database

** Check structure of the destination table

The tar and HDF5 files used in this case where obtained from the "One Millon Songs" 
project - LabROSA (Columbia University) and The Echo Nest

Detailed information related with this project and technical description can be found 
at https://labrosa.ee.columbia.edu/millionsong/

General structure of the tar files:
tarfile = '<path>/<Letter>.tar.gz'

General format of the HDF5 file:
filename = '<path>/<internal sub-directory structure>/<song-id>.h5'

Copyright 2018, Ivan Narvaez

♪┏(°.°)┛┗(°.°)┓┗(°.°)┛┏(°.°)┓ ♪


This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""


import h5py
import numpy as np
import mysql.connector
import os
import tarfile
import shutil
import logging
import sys, getopt

from mysql.connector import errorcode
from fnmatch import fnmatch
from pathlib import Path



def main(argv):    
    #Root folder with all the tarball files (h5 Files)
    input_let = ''
    try:
        opts, args = getopt.getopt(argv,"hf:",["i_let="])
    except getopt.GetoptError:
      print ('addFeatures.py -f <input_letter_tar_File>')
      sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print ('addFeatures.py -f <input_letter_tar_File>')
            sys.exit()
        elif opt in ("-f", "--file"):
            input_let = arg

    root = '/Volumes/Samsung_T5/1M_SONGS'
    log_dir = '/Volumes/Samsung_T5/log.log'
    pattern = input_let + ".tar.gz"
    pattern_h5 = "*.h5"   
    logging.basicConfig(filename=log_dir,level=logging.DEBUG)
    print('Working directory: ' + root)
    logging.info('Working directory: ' + root)
    for path, subdirs, files in os.walk(root):
        for name in files:
            if fnmatch(name, pattern):
                f_data= os.path.join(path, name)
                print('Working tar file: ' + f_data)
                logging.info('Working tar file: ' + f_data)
                t_file = tarfile.open(f_data, "r:gz")
                t_file.extractall(root)
                t_file.close()
                ind_dot = name.index('.')
                if( name[:ind_dot]):
                    n_dir = name[:ind_dot]
                    p_h5= os.path.join(path, n_dir)
                    print('Searching for files in directory: ' + p_h5) 
                    logging.info('Searching for files in directory: ' + p_h5) 
                    for path_h5, subdirs_h5, files_h5 in os.walk(p_h5):
                        result = []
                        for n in files_h5:
                            if fnmatch(n, pattern_h5):
                                f_h5= os.path.join(path_h5, n)
                                print('Encountered H5 file: ' + f_h5)
                                logging.info('Encountered H5 file: ' + f_h5)
                                print('Extracting metadata from the file '+ f_h5)
                                logging.info('Extracting metadata from the file '+ f_h5)
                                result.append(extractMetadata(f_h5))
                                os.remove(f_h5)
                                print('File '+ f_h5 + " was removed")
                                logging.info('File '+ f_h5 + " was removed")
                        if result:
                            storeMySql(result)

                        else:
                            print("The Directory doesn't contain h5 files")
                            logging.warning("The Directory doesn't contain h5 files")
    print("Process Completed")
    logging.info("Process Completed")


def extractMetadata(filename):
    #filename = '/Volumes/Samsung_T5/1M_SONGS/A/E/E/TRAEEGO12903CF7D27.h5'
    f = h5py.File(filename, 'r')

    data_set = f['analysis']
    arrlev = data_set['songs']

    track_id = arrlev['track_id'][0].decode()
    danceability = float(arrlev['danceability'][0])
    duration = float(arrlev['duration'][0])
    end_of_fade_in = float(arrlev['end_of_fade_in'][0])
    energy = float(arrlev['energy'][0])
    key = int(arrlev['key'][0])
    key_confidence = float(arrlev['key_confidence'][0])
    loudness = float(arrlev['loudness'][0])
    mode = int(arrlev['mode'][0])
    mode_confidence = float(arrlev['mode_confidence'][0])
    start_of_fade_out = float(arrlev['start_of_fade_out'][0])
    tempo = float(arrlev['tempo'][0])
    time_signature = int(arrlev['time_signature'][0])
    time_signature_confidence = float(arrlev['time_signature_confidence'][0])

    data_song ={
        'track_id':track_id,
        'danceability':danceability,
        'duration':duration,
        'end_of_fade_in':end_of_fade_in,
        'energy':energy,
        'key_song':key,
        'key_confidence':key_confidence,
        'loudness':loudness,
        'mode':mode,
        'mode_confidence':mode_confidence,
        'start_of_fade_out':start_of_fade_out,
        'tempo':tempo,
        'time_signature':time_signature,
        'time_signature_confidence':time_signature_confidence
    }
    logging.info("Extraction Completed: " + filename)
    return data_song

def storeMySql(data_song):   
    config = {
    'user': 'ivan',
    'password': '12345678',
    'host': 'musicmood-instance.ctjjankvidir.us-east-1.rds.amazonaws.com',
    'database': 'musicmood',
    'raise_on_warnings': True,
    } 

    try:
        cnx = mysql.connector.connect(**config)
        cursor = cnx.cursor()
        sql = """
        INSERT INTO musicmood.songs_new_features
            (
            track_id, 
            danceability, 
            duration, 
            end_of_fade_in, 
            energy, 
            key_song, 
            key_confidence, 
            loudness, 
            mode, 
            mode_confidence, 
            start_of_fade_out, 
            tempo, 
            time_signature, 
            time_signature_confidence
            ) 
        VALUES
            (
            %(track_id)s,
            %(danceability)s,
            %(duration)s,
            %(end_of_fade_in)s,
            %(energy)s,
            %(key_song)s,
            %(key_confidence)s,
            %(loudness)s,
            %(mode)s,
            %(mode_confidence)s,
            %(start_of_fade_out)s,
            %(tempo)s,
            %(time_signature)s,
            %(time_signature_confidence)s
            )"""
        cursor.executemany(sql, data_song)
        cnx.commit()
        cursor.close()
        cnx.close()
        
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            text = "Error: Username or password are incorrect"
            print(text)
            logging.fatal(text)
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            text = 'Error: Incorrect database name'
            print(text)
            logging.fatal(text)
        else:
            print(err)
            logging.fatal(err)
    else:
        cnx.close()

if __name__ == '__main__':
    main(sys.argv[1:])