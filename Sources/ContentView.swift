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
        
        // Load HTML directly (embedded iOS-style launcher)
            let htmlString = """
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
* { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
body { margin: 0; padding: 0; background: #000; font-family: -apple-system, BlinkMacSystemFont, sans-serif; min-height: 100vh; color: white; overflow-x: hidden; }
.status-bar { height: 47px; background: rgba(0,0,0,0.8); backdrop-filter: blur(20px); display: flex; justify-content: space-between; align-items: flex-end; padding: 0 25px 10px; position: fixed; top: 0; left: 0; right: 0; z-index: 1000; }
.status-time { font-size: 16px; font-weight: 600; }
.grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 25px 12px; padding: 60px 20px 100px; }
.app { display: flex; flex-direction: column; align-items: center; cursor: pointer; }
.app:active { transform: scale(0.95); }
.app-icon { width: 60px; height: 60px; border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 6px; box-shadow: 0 2px 8px rgba(0,0,0,0.3); }
.app-name { font-size: 11px; text-align: center; max-width: 70px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.dock { position: fixed; bottom: 20px; left: 50%; transform: translateX(-50%); background: rgba(40,40,40,0.7); backdrop-filter: blur(30px); border-radius: 35px; padding: 12px 16px; display: flex; gap: 20px; }
.dock .app-icon { width: 55px; height: 55px; }
</style>
</head>
<body>
<div class="status-bar">
<span class="status-time" id="time"></span>
</div>
<div class="grid" id="appGrid"></div>
<div class="dock" id="dock"></div>
<script>
const apps = [
{name:'Settings',icon:'⚙️',color:'#8E8E93',bundle:'com.apple.Preferences'},
{name:'Safari',icon:'🧭',color:'#007AFF',bundle:'com.apple.safari'},
{name:'Messages',icon:'💬',color:'#34C759',bundle:'com.apple.MobileSMS'},
{name:'Music',icon:'🎵',color:'#FF2D55',bundle:'com.apple.Music'},
{name:'Photos',icon:'🌸',color:'#FF9500',bundle:'com.apple.mobileslideshow'},
{name:'Camera',icon:'📷',color:'#8E8E93',bundle:'com.apple.camera'},
{name:'Weather',icon:'☁️',color:'#5AC8FA',bundle:'com.apple.weather'},
{name:'Clock',icon:'🕐',color:'#000',bundle:'com.appleclock'},
];
const dockApps = apps.slice(0,4);
const gridApps = apps.slice(4);
function updateTime(){const n=new Date();document.getElementById('time').textContent=n.getHours()+':'+n.getMinutes().toString().padStart(2,'0');}
updateTime();setInterval(updateTime,1000);
function createApp(app){const d=document.createElement('div');d.className='app';d.innerHTML='<div class="app-icon" style="background:'+app.color+'">'+app.icon+'</div><span class="app-name">'+app.name+'</span>';d.ondblclick=()=>launchApp(app.bundle);return d;}
function launchApp(b){console.log('Launch:',b);if(window.webkit&&window.webkit.messageHandlers.launchApp)window.webkit.messageHandlers.launchApp.postMessage(b);}
gridApps.forEach(a=>document.getElementById('appGrid').appendChild(createApp(a)));
dockApps.forEach(a=>document.getElementById('dock').appendChild(createApp(a)));
</script>
</body>
</html>
"""
            webView.loadHTMLString(htmlString, baseURL: nil)
        
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
