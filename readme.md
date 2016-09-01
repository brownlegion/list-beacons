Note, this was forked from https://github.com/PunchThrough/list-beacons. My own files and edits are in this repository.

# List Beacons

A simple Node.js utility to list nearby iBeacons.

# Setup

Clone this repo, then `cd` into it and run `npm install` to install its dependencies.
(Done already in the testfleet repository's [starteverything.sh] (https://github.com/brownlegion/testfleet/blob/master/starteverything.sh) script.)

# Javascript Beacon Scanners

Running `node index.js` or `scan_everyting.js` (as `sudo`) will start scanning the area. THe results are placed in text files in the kdawg directory.

```
$ node index.js
'use strict'

const Bleacon = require('bleacon')

const startedAt = new Date().getTime()

function isBean(beacon) {
  return beacon.uuid.match('^fda50693a4e24fb1afcfc6eb07647825$')
}

function pad(str, len) {
  while (str.length < len) {
    str = '0' + str
  }
  return str
}

Bleacon.on('discover', (beacon) => {
  const elapsed = new Date().getTime() - startedAt
  const uuid = beacon.uuid
  const major = pad(beacon.major.toString(16), 4)
  const minor = pad(beacon.minor.toString(16), 4)
  const intmajor = parseInt(beacon.major.toString(16), 16)
  const intminor = parseInt(beacon.minor.toString(16), 16)
  let info = `${elapsed}: ${uuid} | ${intmajor} | ${intminor}`
  if (isBean(beacon)) {
    console.log(info)
  }
})
Bleacon.startScanning()

```

This will scan for all beacons in the area, but will only output any beacons that have the matching uuid of `fda50693a4e24fb1afcfc6eb07647825` to the console. 


```
$ node scan_everything.js
'use strict'

const Bleacon = require('bleacon')

const startedAt = new Date().getTime()

function isBean(beacon) {
  return beacon.uuid.match('^fda50693a4e24fb1afcfc6eb07647825$')
}

function pad(str, len) {
  while (str.length < len) {
    str = '0' + str
  }
  return str
}

Bleacon.on('discover', (beacon) => {
  const elapsed = new Date().getTime() - startedAt
  const uuid = beacon.uuid
  const major = pad(beacon.major.toString(16), 4)
  const minor = pad(beacon.minor.toString(16), 4)
  const intmajor = parseInt(beacon.major.toString(16), 16)
  const intminor = parseInt(beacon.minor.toString(16), 16)
  let info = `${elapsed}: ${uuid} | ${intmajor} | ${intminor}`
  console.log(info)
})
Bleacon.startScanning()
```

Same as `index.js`, however, thre is no uuid check; it will scan everything and output that to the console.

# Updating Influx Database
`beacon_scan.sh` will scan the entire area, determine any old and new beacons, then send that data to Influx (or CURL the data to Filemaker). This works.

If you want to test to make sure everything works, then run the `scan_once.sh` script. This will use `index.js` to scan for 10 seconds and update Influx. 

`clear.sh` is called at the beginning of every script to make sure the result files in the kdawg directory are emtpy, just in case. `package.json` and the `LICENSE` were provided by PunchThrough. Bless those guys.