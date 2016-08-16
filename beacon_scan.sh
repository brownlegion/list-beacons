#!/bin/bash
#iBeacon search script
./clear.sh
COUNTER=1
while [ $COUNTER -gt 0 ]; do
echo ""
echo "Scan "$COUNTER
echo ""


cat /home/pi/list-beacons/kdawg/found.txt > /home/pi/list-beacons/kdawg/previous.txt
sudo node /home/pi/list-beacons/index.js > /home/pi/list-beacons/kdawg/allbeacons.txt &

TASK_PID=$!
sleep 10
sudo kill  $TASK_PID

cat /home/pi/list-beacons/kdawg/allbeacons.txt  | cut -d':' -f 2 | sort | uniq > /home/pi/list-beacons/kdawg/found.txt
cat /home/pi/list-beacons/kdawg/found.txt

echo " "
echo "Compare Found : Previous"

diff -y --suppress-common-lines /home/pi/list-beacons/kdawg/found.txt /home/pi/list-beacons/kdawg/previous.txt
echo ""

echo "Coming"
diff  /home/pi/list-beacons/kdawg/previous.txt /home/pi/list-beacons/kdawg/found.txt | grep ">" | cut -d'>' -f 2 > /home/pi/list-beacons/kdawg/coming.txt
cat /home/pi/list-beacons/kdawg/coming.txt
echo ""

echo "Going"
##diff --new-line-format='%L' kdawg/found.txt kdawg/previous.txt #> kdawg/going.txt
diff --suppress-common-lines /home/pi/list-beacons/kdawg/found.txt /home/pi/list-beacons/kdawg/previous.txt | grep ">" | cut -d'>' -f 2 > /home/pi/list-beacons/kdawg/going.txt
cat kdawg/going.txt
echo ""

#Do the stuff with the coming/going texts. 
echo "Influx Ins"
awk -v major="major=" -v minor=",minor=" -v device=",device=\"${HOSTNAME}\"" '{print major""$3""minor""$5""device}' /home/pi/list-beacons/kdawg/coming.txt |while read beacondata; do 
#curl -X GET "http://159.203.15.175/filemaker/beaconStatus.php?"${beacondata}
#echo "influx -execute \"insert beacon,state=In "${beacondata}"\" -database=beaconDatabase" > kdawg/intemp.txt
#bash kdawg/intemp.txt
#echo "http://159.203.15.175/filemaker/beaconStatusTest.php?${beacondata}"
echo "beacon,state=In "${beacondata}"" > kdawg/intemp.txt
curl -i -XPOST 'http://localhost:8086/write?db=beaconDatabase' --data-binary @kdawg/intemp.txt
done

echo ""
echo "Influx Outs"
awk -v major="major=" -v minor=",minor=" -v device=",device=\"${HOSTNAME}\"" '{print major""$3""minor""$5""device}' /home/pi/list-beacons/kdawg/going.txt |while read beacondata; do
#curl -X GET "http://159.203.15.175/filemaker/beaconStatus.php?"${beacondata}
#echo "influx -execute \"insert beacon,state=Out "${beacondata}"\" -database=beaconDatabase" > kdawg/outtemp.txt
#bash kdawg/outtemp.txt
#echo "http://159.203.15.175/filemaker/beaconStatusTest.php?${beacondata}"
echo "beacon,state=Out "${beacondata}"" > kdawg/outtemp.txt
curl -i -XPOST 'http://localhost:8086/write?db=beaconDatabase' --data-binary @kdawg/outtemp.txt
done
let COUNTER=COUNTER+1
done
