#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 \"yyy-mm-dd HH:MM:SS\""
  exit 1
fi

#set -v   # Print every executed line

float_scale=2
LAT="40.323527"
LON="-3.717840"
PAD="                    "
inputDate=$1
secondsRunning=1800
numIntervals=$(( $secondsRunning / 10 ))

tcxHeader () {
cat <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<TrainingCenterDatabase xmlns:ns5="http://www.garmin.com/xmlschemas/ActivityGoals/v1" xmlns:ns3="http://www.garmin.com/xmlschemas/ActivityExtension/v2" xmlns:ns2="http://www.garmin.com/xmlschemas/UserProfile/v2" xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns4="http://www.garmin.com/xmlschemas/ProfileExtension/v1" xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2 http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd">
    <Activities>
        <Activity Sport="Running">
            <Id>${inputDateFormatted}</Id>
            <Lap StartTime="${inputDateFormatted}">
                <TotalTimeSeconds>1800.000000</TotalTimeSeconds>
                <DistanceMeters>5000.000000</DistanceMeters>
                <MaximumSpeed>6.000000</MaximumSpeed>
                <Calories>500</Calories>
                <Intensity>Active</Intensity>
                <TriggerMethod>Manual</TriggerMethod>
                <Track>
EOF
}

tcxTrailer () {
  cat <<EOF
                </Track>
                <Extensions>
                    <LX xmlns="http://www.garmin.com/xmlschemas/ActivityExtension/v2">
                        <AvgSpeed>6</AvgSpeed>
                    </LX>
                </Extensions>
            </Lap>
        </Activity>
    </Activities>
</TrainingCenterDatabase>
EOF
}

function float_eval()
{
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}

# http://www.unix.com/tips-tutorials/31944-simple-date-time-calulation-bash.html
date2stamp () {
  date -u -j -f "%Y-%m-%d %H:%M:%S" "$1" "+%s"
}

stamp2date (){
  date -u -r $1 +'%Y-%m-%d %H:%M:%S'
}

#
# Main Program starts here.
#
set -e   # Exit if a command exits with non-zero
set -f   # Avoid filename expansion

# Sets the date for the Treadmin exercise based on the argument
baseStamp=$(date2stamp "${inputDate}")
inputDateFormatted=`echo $inputDate|tr '[ ]' '[T]'`"Z"
tcxHeader

# Generate a new Trackpoint every 10 seconds.
# A total of $numIntervals must be generated.
for t in $(seq 1 ${numIntervals})
do
  echo "${PAD}<Trackpoint>"
  newStamp=$(( $baseStamp + (10 * $t) ))
  newDate=$(stamp2date $newStamp)
  newDateFormatted=`echo $newDate|tr '[ ]' '[T]'`"Z"
  echo "${PAD}    <Time>${newDateFormatted}</Time>"
  echo "${PAD}    <Position>"
  echo "${PAD}        <LatitudeDegrees>${LAT}</LatitudeDegrees>"
  echo "${PAD}        <LongitudeDegrees>${LON}</LongitudeDegrees>"
  echo "${PAD}    </Position>"
  echo "${PAD}    <AltitudeMeters>0.000000</AltitudeMeters>"
  echo -n "${PAD}    <DistanceMeters>"
  distance="$t * 27.777778"
  echo -n $(float_eval "$distance")
  echo "</DistanceMeters>"
  echo "${PAD}</Trackpoint>"
done

tcxTrailer
exit 0
