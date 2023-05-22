import Cephei
import CryptoKit
import Network

class Preferences : ObservableObject {

    @Published var startTime = "tweak not detected"
    @Published var rerouteEnabled: Bool

    private let preferences = HBPreferences(identifier: "net.rec0de.ios.watchwitch")
    private let dateFormatter = ISO8601DateFormatter()
    private(set) var spoofTrigger: Int = Int.random(in: 0..<10000)

    private var publicClassA: NSData? = nil
    private var publicClassC: NSData? = nil
    private var publicClassD: NSData? = nil
    private var privateClassA: NSData? = nil
    private var privateClassC: NSData? = nil
    private var privateClassD: NSData? = nil

    var hostUDP: NWEndpoint.Host = "192.168.133.29"

    
    init() {

        preferences.register(defaults: [
            "tweakStarted": 0.0
        ])

        rerouteEnabled = preferences.bool(forKey: "reroute")

        preferences.registerPreferenceChangeBlock(forKey: "tweakStarted", block: { (_: String, _: NSCopying?) -> Void in
            NSLog("WWitchC: " + self.tweakStartTime())
            self.startTime = self.tweakStartTime()
        })

        // if this key is changed, we expect all keys to be updated
        preferences.registerPreferenceChangeBlock(forKey: "publicClassA", block: { (_: String, _: NSCopying?) -> Void in
            NSLog("WWitchC: extracted keys updated")
            self.loadKeys()
        })

        triggerKeyExtract()
    }

    func loadKeys() {
        publicClassA = preferences.object(forKey: "publicClassA") as? NSData
        publicClassC = preferences.object(forKey: "publicClassC") as? NSData
        publicClassD = preferences.object(forKey: "publicClassD") as? NSData
        privateClassA = preferences.object(forKey: "privateClassA") as? NSData
        privateClassC = preferences.object(forKey: "privateClassC") as? NSData
        privateClassD = preferences.object(forKey: "privateClassD") as? NSData
        //NSLog("WWitchC: '\(publicClassA!)' of type '\(type(of: publicClassA!))'")
    }

    func sendKeys() {
        let al = privateClassA!.base64EncodedString()
        let cl = privateClassC!.base64EncodedString()
        let dl = privateClassD!.base64EncodedString()
        let ar = publicClassA!.base64EncodedString()
        let cr = publicClassC!.base64EncodedString()
        let dr = publicClassD!.base64EncodedString()

        let json = "{\"al\": \"\(al)\",\"cl\": \"\(cl)\",\"dl\": \"\(dl)\",\"ar\": \"\(ar)\",\"cr\": \"\(cr)\",\"dr\": \"\(dr)\"}"
        let jsonData = json.data(using: String.Encoding.utf8)!
        //NSLog("WWitchC: \(json)")

        // this is at least a little better than sending unencrypted keys over the network
        let key = SymmetricKey(data: "witchinthewatch-'#s[MZu!Xv*UZjbt".data(using: String.Encoding.utf8)!)
        let encryptedData = try! ChaChaPoly.seal(jsonData, using: key).combined
        //NSLog("WWitchC: \(encryptedData)")

        let connection = NWConnection(host: hostUDP, port: 0x7777, using: .udp)

        connection.stateUpdateHandler = { (newState) in
            switch (newState) {
                case .ready:
                    print("State: Ready\n")
                    connection.send(content: encryptedData, completion: NWConnection.SendCompletion.idempotent)
                default:
                    print("ERROR! State not defined!\n")
            }
        }

        connection.start(queue: .global())
    }

    func tweakStartTime() -> String {
        let timestamp = preferences.double(forKey: "tweakStarted")

        if(timestamp == 0.0) {
            return "tweak not detected"
        }

        let date = Date(timeIntervalSince1970: timestamp)

        var calendar = Calendar.current
        calendar.timeZone = .current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)

        let day = components.day!
        let month = components.month!
        let hour = components.hour!
        let minute = components.minute!
        return "tweak started \(day).\(month) \(hour):\(minute)"
        //return date.description(with: Locale.current)
    }

    func setRerouteState(state: Bool) {
        rerouteEnabled = state
        preferences.set(state, forKey: "reroute")
        sync()
    }

    func setTargetIp(ip: UInt) {
        preferences.set(ip, forKey: "targetIP")
        // try pushing an endpoint update after changing target IP, can't hurt right?
        trigger()
    }

    func trigger() {
        spoofTrigger = spoofTrigger + 1
        preferences.set(spoofTrigger, forKey: "spoofTrigger")
        sync()
    }

    func triggerKeyExtract() {
        spoofTrigger = spoofTrigger + 1
        preferences.set(spoofTrigger, forKey: "keyExtractTrigger")
        sync()
    }

    func sync() {
        let nc = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(nc, CFNotificationName(NSString("net.rec0de.ios.watchwitch/ReloadPrefs")), nil, nil, true)
    }

}
