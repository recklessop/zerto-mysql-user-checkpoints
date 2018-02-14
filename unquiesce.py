import MySQLdb
import os
import time
import datetime
dt=datetime.datetime.now().strftime("%I:%M%p on %B %d, %Y")
outputf1 = open("/scripts/post-thaw.log","a+" )
try:
    os.remove('/tmp/freeze_snap.lock')
    time.sleep(2)
except Exception, e:
    print e
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

 

try:
    outputf1.write (dt)
    outputf1.write ("\t executing query to unquiescethe database \n")
    cur.execute ("unlock tables")
    outputf1.write (dt)
    outputf1.write ("\t Database is in unquiescemode now \n")
except:
    outputf1.write(dt)
    outputf1.write( "\n unexpected error from MySQL, unable to unlock tables. Please check MySql error logs for more info \n")

 

cur.close()
conn.close()