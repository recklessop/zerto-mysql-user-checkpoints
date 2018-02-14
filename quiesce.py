import MySQLdb
import os
import time
import datetime
dt=datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")
outputf1 = open("/scripts/pre-freeze.log","a+" )
try:
    conn = MySQLdb.connect ('localhost' , 'root' , 'password' )
    cur = conn.cursor()
    cur.execute ("select version()")
    data = cur.fetchone()
    outputf1.write (dt)
    outputf1.write ("````````````````````````````\n")
    outputf1.write ("````````````````````````````\n")
    outputf1.write ("\t MySQL Database version is %s: "%data)
    outputf1.write ("````````````````````````````\n")
    outputf1.write ("````````````````````````````\n")

 

except:
    outputf1.write (dt)
    outputf1.write("\t unable to connect to MySQL server\n")

 

    file2 = open ('/tmp/freeze_snap.lock', 'w')
    file2.close()

 

try:
    cur.execute (" flush tables with read lock ")
    outputf1.write (dt)
    outputf1.write ("\t using unquiesce.py script - un-quiesce of database successful \n")
except:
    outputf1.write(dt)
    outputf1.write( "\n unexpected error from MySQL, unable to do flush tables with read lock, Please check MySQL error logs for more info\n")
    while True:
        check = os.path.exists ("/tmp/freeze_snap.lock")
    if check == True:
        continue
    else:
        break