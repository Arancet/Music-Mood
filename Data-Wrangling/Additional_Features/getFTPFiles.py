"""
Ivan Narvaez (2018) Georgetown University
in87@georgetown.edu

This code contains a set of methods to:
Connect to an FTP Server
List the content of the current directory
Download the MusicBrainz virtual machine disk (VirtualBox or VMware Workstation)

** Check structure of the destination table
The virtual machine disk is an .OVA file
The repository is a FTP Server (Not SFTP)

Detailed information related with this project and technical description can be found 
at https://musicbrainz.org/doc/MusicBrainz_Server/Setup

Check the detailed technical information to set up the Virtual machine

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

from ftplib import FTP
url_ftp = 'ftp.eu.metabrainz.org'

try:
    ftp = FTP(url_ftp)
    ftp.login()

    ftp.cwd('pub')
    ftp.cwd('musicbrainz-vm')
    ftp.retrlines('LIST')

    ftp.retrbinary('RETR musicbrainz-server-2018-08-14.ova.md5', open('musicbrainz-server-2018-08-14.ova.md5', 'wb').write)

    #ftp.quit()
except ftplib.all_errors as ERROR:
    print(ERROR)