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
        webView.backgroundColor = .clear
        
        // Load the HTML file from Resources
        if let htmlURL = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
