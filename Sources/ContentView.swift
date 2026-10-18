import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct WebViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        
        // Add message handlers for JavaScript communication
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "launchApp")
        contentController.add(context.coordinator, name: "deleteApp")
        contentController.add(context.coordinator, name: "launchFilePicker")
        config.userContentController = contentController
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = true
        webView.isOpaque = false
        webView.backgroundColor = .white
        
        // Debug: Print bundle path and check for resources
        print("📦 Bundle path: \(Bundle.main.bundlePath)")
        print("📦 Bundle resource path: \(Bundle.main.resourcePath ?? "nil")")
        
        // List all files in bundle
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("📦 Files in bundle: \(files)")
            } catch {
                print("📦 Error listing bundle files: \(error)")
            }
        }
        
        // Load the HTML file from Resources
        if let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html") {
            print("✅ Found index.html at: \(htmlURL.path)")
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        } else {
            print("❌ Could not find index.html in bundle")
            // Fallback: load from app bundle root
            let htmlString = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                    body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 20px; background: #fff; }
                    h1 { color: #333; }
                    p { color: #666; }
                </style>
            </head>
            <body>
                <h1>LauncherApp</h1>
                <p>HTML file not found in bundle.</p>
                <p>Bundle path: <code id="path"></code></p>
                <script>document.getElementById('path').textContent = window.location.href;</script>
            </body>
            </html>
            """
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("📱 JS Message: \(message.name) - \(message.body)")
            
            switch message.name {
            case "launchApp":
                if let bundleID = message.body as? String {
                    AppManager.shared.launchApp(bundleID: bundleID)
                }
            case "deleteApp":
                if let bundleID = message.body as? String {
                    AppManager.shared.deleteApp(bundleID: bundleID)
                }
            case "launchFilePicker":
                print("📁 File picker requested")
            default:
                break
            }
        }
    }
}
