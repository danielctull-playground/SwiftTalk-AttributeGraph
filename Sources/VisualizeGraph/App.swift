import AppKit
import SwiftUI

@main
struct MyApp: App {

  init() {
    DispatchQueue.main.async {
      NSApp.setActivationPolicy(.regular)
      NSApp.activate(ignoringOtherApps: true)
      NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }
  }

  var body: some Scene {
    WindowGroup {
      Sample()
    }
  }
}
