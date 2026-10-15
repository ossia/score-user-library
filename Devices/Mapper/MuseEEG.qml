import QtQuick
import Ossia 1.0 as Ossia

// Muse EEG headband exposed as an ossia device tree, over Bluetooth Low Energy.
//
//   /connected            Int    1 while streaming
//   /battery              Float  battery level (%)
//   /eeg/{tp9,af7,af8,tp10,aux}   Float  µV, ~[-1000,1000)
//   /ppg/{0,1,2}          Float  raw 24-bit photoplethysmography
//   /accelerometer/{x,y,z} Float g  (1 = 9.81 m/s²)
//   /gyroscope/{x,y,z}    Float  °/s
//   /telemetry            String latest control/telemetry JSON
//   /rescan               Int    write anything to restart the scan
//
// Protocol & decoding are a 1:1 port of ../src/lib/MuseDevice.js. Requires a
// libossia with the QtBluetooth factories and the qml_ble_service callbacks
// exposed as meta-properties. See ../qt/MuseVisualizer.qml for a visual UI.
Ossia.Mapper
{
    id: root

    // Target a specific headset by MAC (Linux, e.g. "00:55:DA:B8:12:F5") or by
    // platform device UUID (macOS). Leave empty to connect to the first Muse
    // found. Also settable at runtime via the /address node.
    property string targetAddress: ""

    // ---- Muse GATT service & characteristics ----
    readonly property string svcUuid: "fe8d"
    readonly property string cCtrl:  "273e0001-4c4d-454d-96be-f03bac821358"
    readonly property string cBatt:  "273e000b-4c4d-454d-96be-f03bac821358"
    readonly property string cGyro:  "273e0009-4c4d-454d-96be-f03bac821358"
    readonly property string cAcc:   "273e000a-4c4d-454d-96be-f03bac821358"
    readonly property var cEeg: [
        "273e0003-4c4d-454d-96be-f03bac821358",
        "273e0004-4c4d-454d-96be-f03bac821358",
        "273e0005-4c4d-454d-96be-f03bac821358",
        "273e0006-4c4d-454d-96be-f03bac821358",
        "273e0007-4c4d-454d-96be-f03bac821358"
    ]
    readonly property var cPpg: [
        "273e000f-4c4d-454d-96be-f03bac821358",
        "273e0010-4c4d-454d-96be-f03bac821358",
        "273e0011-4c4d-454d-96be-f03bac821358"
    ]
    readonly property var eegNames: ["tp9", "af7", "af8", "tp10", "aux"]
    readonly property var axisNames: ["x", "y", "z"]

    // ---- BLE handles / state ----
    property var scanner: null
    property var controller: null
    property var museSvc: null
    property var subQueue: []      // characteristics left to subscribe to
    property var cmdQueue: []      // start commands left to send
    property bool busy: false      // locked onto a device (connecting/connected)
    property int retries: 0
    property string infoFrag: ""

    // ---- diagnostics ----
    // Set false once the link is trusted; the tracing is chatty by design.
    property bool verbose: true
    property var  pktCount: ({})    // characteristic uuid -> packets received
    property var  lastVals: ({})    // characteristic uuid -> last decoded value
    property int  subscribed: 0     // CCCD writes actually issued

    function trace(msg) { if (root.verbose) console.log("Muse: " + msg) }

    // Decode QLowEnergyCharacteristic::PropertyType for the characteristic dump
    function propStr(p) {
        var f = []
        if (p & 0x02) f.push("Read")
        if (p & 0x04) f.push("WriteNoResp")
        if (p & 0x08) f.push("Write")
        if (p & 0x10) f.push("Notify")
        if (p & 0x20) f.push("Indicate")
        return f.length ? f.join("|") : "none"
    }

    Component.onCompleted: startScan()
    Component.onDestruction: teardown()

    // =====================================================================
    //  BLE flow  (ported from src/lib/MuseDevice.js)
    // =====================================================================
    function startScan() {
        teardown()
        busy = false
        scanner = Protocols.bluetoothScanner({
            onDeviceDiscovered: function(dev) {
                if (busy) return
                var want = (root.targetAddress || "").toUpperCase()
                var match
                if (want.length > 0) {
                    // explicit target: match the MAC or the platform device UUID
                    match = ((dev.Address || "").toUpperCase() === want)
                         || ((dev.DeviceUuid || "").toUpperCase() === want)
                } else {
                    match = (dev.Name && dev.Name.indexOf("Muse") === 0)
                         || (dev.ServiceUuids && dev.ServiceUuids.some(function(u) {
                                return u.toLowerCase().indexOf("fe8d") !== -1 }))
                }
                if (!match) return
                console.log("Muse: found", dev.Name, dev.Address)
                busy = true               // lock onto this device
                connectDevice(dev)
            },
            onFinished: function() {},
            onError: function(e) { console.log("Muse: scan error", e) }
        })
        scanner.setLowEnergyDiscoveryTimeout(20000)
        scanner.startBLE()
    }

    // Keep the scanner alive across the connect (BlueZ only resolves the device
    // path while discovery is running); stop it once the link is up.
    function connectDevice(dev) {
        var hasUuid = dev.DeviceUuid && dev.DeviceUuid !== "00000000-0000-0000-0000-000000000000"
        controller = Protocols.ble({
            Transport: hasUuid ? { DeviceUuid: dev.DeviceUuid, Name: dev.Name }
                               : { Address: dev.Address, Name: dev.Name },
            onConnected: function(ctrl) {
                console.log("Muse: connected")
                retries = 0
                if (scanner) { try { scanner.stop() } catch (e) {} }
                ctrl.discoverServices()
            },
            onDisconnected: function() { Device.write("/connected", 0) },
            onServiceDiscovered: function(u) { root.trace("service discovered " + u) },
            onDiscoveryFinished: function(ctrl) {
                root.trace("discovery finished; services=" + JSON.stringify(ctrl.services())
                           + " mtu=" + ctrl.mtu() + " name=" + ctrl.remoteName())
                setupService(ctrl)
            },
            onMtuChanged: function(m) { root.trace("mtu changed " + m) },
            onError: function(e) {
                console.log("Muse: controller error", e)
                busy = false
                // BlueZ LE connects are flaky; tear everything down and retry
                // after a delay so the half-open link clears first.
                if (retries < 8) { retries++; teardown(); retryTimer.restart() }
                else Device.write("/connected", 0)
            }
        })
    }

    function setupService(ctrl) {
        museSvc = ctrl.service(svcUuid)
        if (!museSvc) { console.log("Muse: service", svcUuid, "not found"); return }
        trace("service object acquired, uuid=" + museSvc.uuid() + " -> discoverDetails()")
        museSvc.onDetailsDiscovered  = function(chars) {
            root.trace("details discovered, " + chars.length + " characteristics:")
            for (var i = 0; i < chars.length; ++i)
                root.trace("   " + chars[i].uuid + "  [" + root.propStr(chars[i].properties) + "]  "
                           + (chars[i].name || ""))
            onServiceReady()
        }
        museSvc.onCharacteristicChanged = function(uuid, value) { onMuseData(uuid, value) }
        museSvc.onError = function(e) { console.log("Muse: service error", e) }
        museSvc.discoverDetails()
    }

    function onServiceReady() {
        // Subscribe to every stream, then send the start sequence — all paced,
        // since the BLE stack tolerates only one outstanding write at a time.
        subQueue = [cCtrl, cBatt, cGyro, cAcc].concat(cEeg).concat(cPpg)
        cmdQueue = ["h", "p50", "s", "d", "v1"]   // halt, preset p50, status, resume, version
        pktCount = ({}); lastVals = ({}); subscribed = 0
        Device.write("/connected", 1)
        trace("subscribing to " + subQueue.length + " characteristics, then "
              + cmdQueue.length + " control commands")
        subTimer.restart()
        statsTimer.restart()
    }

    // Ossia.Mapper is a non-visual object with no default property, so helper
    // objects must be assigned to named properties rather than declared as children.
    property Timer subTimer: Timer {
        interval: 70; repeat: true
        onTriggered: {
            if (!root.museSvc) { root.subTimer.stop(); return }
            if (root.subQueue.length > 0) {
                var u = root.subQueue.shift()
                root.trace("subscribe " + u)
                root.museSvc.enableNotifications(u)
                root.subscribed++
                return
            }
            if (root.cmdQueue.length > 0) {
                // control characteristic is write-without-response
                var c = root.cmdQueue.shift()
                root.trace("command '" + c + "'")
                root.museSvc.writeCharacteristicNoResponse(root.cCtrl, root.encodeCommand(c))
                return
            }
            root.trace("start sequence complete (" + root.subscribed + " subscriptions issued)")
            root.subTimer.stop()
        }
    }

    // Every 2s: per-stream packet rate, and — the useful part — the list of
    // characteristics that were subscribed but have never delivered a packet.
    property Timer statsTimer: Timer {
        interval: 2000; repeat: true
        property var prev: ({})
        onTriggered: {
            if (!root.verbose || !root.museSvc) return
            var expected = [root.cCtrl, root.cBatt, root.cGyro, root.cAcc]
                             .concat(root.cEeg).concat(root.cPpg)
            var live = [], silent = []
            for (var i = 0; i < expected.length; ++i) {
                var u = expected[i]
                var n = root.pktCount[u] || 0
                if (n === 0) { silent.push(root.shortUuid(u)); continue }
                var rate = ((n - (prev[u] || 0)) / 2).toFixed(1)
                live.push(root.shortUuid(u) + "=" + rate + "/s")
                prev[u] = n
            }
            console.log("Muse: rates  " + (live.length ? live.join("  ") : "(nothing)"))
            if (silent.length > 0)
                console.log("Muse: SILENT " + silent.join(" ")
                            + "   <- subscribed but no notifications")
        }
    }

    // 273e0003-... -> 0003 ; keeps the rate line readable
    function shortUuid(u) { return u.length > 8 ? u.substring(4, 8) : u }

    property Timer retryTimer: Timer { interval: 1800; repeat: false; onTriggered: root.startScan() }

    function teardown() {
        if (subTimer.running) subTimer.stop()
        if (statsTimer.running) statsTimer.stop()
        subQueue = []; cmdQueue = []
        if (scanner)    { try { scanner.stop() }     catch (e) {} scanner = null }
        if (controller) { try { controller.close() } catch (e) {} controller = null }
        museSvc = null
    }

    // "X<cmd>\n" with the first byte overwritten by the payload length (MuseDevice.js)
    function encodeCommand(cmd) {
        var s = cmd + "\n"
        var buf = new Uint8Array(s.length + 1)
        buf[0] = s.length
        for (var i = 0; i < s.length; ++i) buf[i + 1] = s.charCodeAt(i)
        return buf.buffer
    }

    // =====================================================================
    //  Decode incoming notifications → device tree  (QByteArray is an ArrayBuffer)
    // =====================================================================
    function onMuseData(uuid, value) {
        uuid = ("" + uuid).toLowerCase()
        pktCount[uuid] = (pktCount[uuid] || 0) + 1
        if (pktCount[uuid] === 1)
            trace("first packet on " + uuid + " (" + value.byteLength + " bytes)")
        var ei = cEeg.indexOf(uuid)
        if (ei >= 0) { Device.write("/eeg/" + eegNames[ei], lastEeg(value)); return }
        var pi = cPpg.indexOf(uuid)
        if (pi >= 0) { Device.write("/ppg/" + pi, lastPpg(value)); return }
        if (uuid === cAcc)  { writeMotion("/accelerometer/", value, 0.0000610352); return } // 1/2^14
        if (uuid === cGyro) { writeMotion("/gyroscope/",     value, 0.0074768);    return } // 1/2^7
        if (uuid === cBatt) { Device.write("/battery", new DataView(value).getUint16(2) / 512); return }
        if (uuid === cCtrl) { handleControl(value); return }
    }

    // 12-bit unsigned EEG, skip 2-byte packet index; return the latest scaled sample (µV)
    function lastEeg(value) {
        var s = new Uint8Array(value, 2)
        var raw = 0
        for (var i = 0; i < s.length; ++i) {
            if (i % 3 === 0) raw = (s[i] << 4) | (s[i + 1] >> 4)
            else            { raw = ((s[i] & 0xf) << 8) | s[i + 1]; ++i }
        }
        return 0.48828125 * (raw - 0x800)
    }

    // 24-bit unsigned PPG; return the latest sample
    function lastPpg(value) {
        var s = new Uint8Array(value, 2)
        var v = 0
        for (var i = 0; i + 2 < s.length + 1; i += 3)
            v = (s[i] << 16) | (s[i + 1] << 8) | s[i + 2]
        return v
    }

    // 3 samples x 3 axes, big-endian int16; write the latest sample per axis
    function writeMotion(prefix, value, scale) {
        var dv = new DataView(value)
        var ofs = 14   // last of the three samples (offsets 2, 8, 14)
        Device.write(prefix + "x", scale * dv.getInt16(ofs))
        Device.write(prefix + "y", scale * dv.getInt16(ofs + 2))
        Device.write(prefix + "z", scale * dv.getInt16(ofs + 4))
    }

    // control channel: length-prefixed ASCII fragments forming JSON telemetry
    function handleControl(value) {
        var b = new Uint8Array(value)
        var len = b[0], str = ""
        for (var i = 0; i < len; ++i) str += String.fromCharCode(b[1 + i])
        for (var k = 0; k < str.length; ++k) {
            infoFrag += str[k]
            if (str[k] === "}") {
                Device.write("/telemetry", infoFrag)
                infoFrag = ""
            }
        }
    }

    // =====================================================================
    //  Device tree
    // =====================================================================
    function eegNode(n)  { return { name: n, type: Ossia.Type.Float, value: 0 } }
    function axisNode(a) { return { name: a, type: Ossia.Type.Float, value: 0 } }

    function createTree() {
        return [
            { name: "connected", type: Ossia.Type.Int,    value: 0 },
            { name: "battery",   type: Ossia.Type.Float,  value: 0 },
            { name: "eeg", children: [
                eegNode("tp9"), eegNode("af7"), eegNode("af8"), eegNode("tp10"), eegNode("aux")
            ] },
            { name: "ppg", children: [
                { name: "0", type: Ossia.Type.Float, value: 0 },
                { name: "1", type: Ossia.Type.Float, value: 0 },
                { name: "2", type: Ossia.Type.Float, value: 0 }
            ] },
            { name: "accelerometer", children: [ axisNode("x"), axisNode("y"), axisNode("z") ] },
            { name: "gyroscope",     children: [ axisNode("x"), axisNode("y"), axisNode("z") ] },
            { name: "telemetry", type: Ossia.Type.String, value: "" },
            // Write a MAC/UUID here to target a specific headset (empty = first Muse)
            { name: "address", type: Ossia.Type.String, value: root.targetAddress,
              write: function(v) { root.targetAddress = ("" + v.value).trim(); root.retries = 0; root.startScan() } },
            { name: "rescan", type: Ossia.Type.Int, write: function(v) { root.retries = 0; root.startScan() } }
        ]
    }
}
