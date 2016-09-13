#!/bin/bash
#iBeacon search script
/usr/src/app/list-beacons/clear.sh
COUNTER=1
while [ $COUNTER -gt 0 ]; do
echo ""
echo ""
date
echo "Scan "$COUNTER
echo ""


cat /usr/src/app/list-beacons/kdawg/found.txt > /usr/src/app/list-beacons/kdawg/previous.txt
sudo node /usr/src/app/list-beacons/scan_everything.js > /usr/src/app/list-beacons/kdawg/allbeacons.txt &

TASK_PID=$!
sleep 10
sudo kill  $TASK_PID

cat /usr/src/app/list-beacons/kdawg/allbeacons.txt  | cut -d':' -f 2 | sort | uniq > /usr/src/app/list-beacons/kdawg/found.txt
cat /usr/src/app/list-beacons/kdawg/found.txt

echo " "
echo "Compare Found : Previous"

diff -y --suppress-common-lines /usr/src/app/list-beacons/kdawg/found.txt /usr/src/app/list-beacons/kdawg/previous.txt
echo ""

echo "Coming"
diff  /usr/src/app/list-beacons/kdawg/previous.txt /usr/src/app/list-beacons/kdawg/found.txt | grep ">" | cut -d'>' -f 2 > /usr/src/app/list-beacons/kdawg/coming.txt
cat /usr/src/app/list-beacons/kdawg/coming.txt
echo ""

echo "Going"
##diff --new-line-format='%L' kdawg/found.txt kdawg/previous.txt #> kdawg/going.txt
diff --suppress-common-lines /usr/src/app/list-beacons/kdawg/found.txt /usr/src/app/list-beacons/kdawg/previous.txt | grep ">" | cut -d'>' -f 2 > /usr/src/app/list-beacons/kdawg/going.txt
cat /usr/src/app/list-beacons/kdawg/going.txt
echo ""

#Do the stuff with the coming/going texts. 
echo "Influx Ins"
awk -v major="major=" -v minor=",minor=" -v device=",device=\"${HOSTNAME}\"" '{print major""$3""minor""$5""device}' /usr/src/app/list-beacons/kdawg/coming.txt |while read beacondata; do 
#This is used for CURLing to a Filemaker database.
#curl -X GET "http://159.203.15.175/filemaker/beaconStatus.php?"${beacondata}
#echo "http://159.203.15.175/filemaker/beaconStatusTest.php?${beacondata}"
#This is used for CURLing to an Influx database.
echo "beacon,state=In "${beacondata}"" > /usr/src/app/list-beacons/kdawg/intemp.txt
curl -i -XPOST 'http://localhost:80/write?db=beaconDatabase' --data-binary @/usr/src/app/list-beacons/kdawg/intemp.txt
done

echo ""
echo "Influx Outs"
awk -v major="major=" -v minor=",minor=" -v device=",device=\"${HOSTNAME}\"" '{print major""$3""minor""$5""device}' /usr/src/app/list-beacons/kdawg/going.txt |while read beacondata; do
#This is used for CURLing to a Filemaker database.
#curl -X GET "http://159.203.15.175/filemaker/beaconStatus.php?"${beacondata}
#echo "http://159.203.15.175/filemaker/beaconStatusTest.php?${beacondata}"
#This is used for CURLing to an Influx database.
echo "beacon,state=Out "${beacondata}"" > /usr/src/app/list-beacons/kdawg/outtemp.txt
curl -i -XPOST 'http://localhost:80/write?db=beaconDatabase' --data-binary @/usr/src/app/list-beacons/kdawg/outtemp.txt
done
let COUNTER=COUNTER+1
done
