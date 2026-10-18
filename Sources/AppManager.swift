import Foundation

class AppManager {
    static let shared = AppManager()
    
    var installedApps: [InstalledApp] = []
    
    func launchApp(bundleID: String) {
        print("Launching app with bundle ID: \(bundleID)")
        // This would integrate with LiveContainer's app launching logic
    }
    
    func deleteApp(bundleID: String) {
        print("Deleting app: \(bundleID)")
        installedApps.removeAll { $0.bundleID == bundleID }
    }
}

struct InstalledApp {
    let name: String
    let bundleID: String
    let icon: String
}
