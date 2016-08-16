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
