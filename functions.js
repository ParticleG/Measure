var startDegree, endDegree

function calculateDegree() {
    //console.log("Mag:", compassMagnetometer.reading.x, ",", compassMagnetometer.reading.y, ",", compassMagnetometer.reading.z)
    //console.log("Accel:", compassAccelerometer.reading.x, ",", compassAccelerometer.reading.y, ",", compassAccelerometer.reading.z)
    var accelVec = [compassAccelerometer.reading.x, compassAccelerometer.reading.y, compassAccelerometer.reading.z]
    var magEast = crossProduct(
                [compassMagnetometer.reading.x, compassMagnetometer.reading.y, compassMagnetometer.reading.z],
                accelVec)
    var magNorth = crossProduct(accelVec, magEast)

    magEast = normVec(magEast)
    magNorth = normVec(magNorth)

    var deviceHeading = [0., 1., -1.] //This is for portrait orientation on android
    deviceHeading = normVec(deviceHeading)

    var dotWithEast = dotProduct(deviceHeading, magEast)
    var dotWithNorth = dotProduct(deviceHeading, magNorth)
    var bearingRad = Math.atan2(dotWithEast, dotWithNorth)
    //var bearingDeg = bearingRad * 180. / Math.PI
    compass_label.text = bearingRad.toFixed(6)
}

function crossProduct(a, b) {
    // Check lengths
    if (a.length !== 3 || b.length !== 3) {
        return
    }
    return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]
}

function normVec(a) {
    var compSq = 0.
    for (var i = 0; i < a.length; i++)
        compSq += Math.pow(a[i], 2)
    var compass_sum = Math.pow(compSq, 0.5)
    if (compass_sum === 0.)
        return
    var out = []
    for (var j = 0; j < a.length; j++)
        out.push(a[j] / compass_sum)
    return out
}

function dotProduct(a, b) {
    if (a.length !== b.length)
        return
    var comp = 0.
    for (var i = 0; i < a.length; i++)
        comp += a[i] * b[i]
    return comp
}

function calculateSweetness() {
    var compassDegree = Math.abs(endDegree - startDegree)
    var refractivity = 1.0 / Math.sin(Math.PI / 2.0 - compassDegree)
    toastDisplayer.show("Degree: " + compassDegree.toFixed(
                            5) + "\nRefractivity: " + refractivity)
}
