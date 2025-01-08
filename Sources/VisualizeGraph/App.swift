import SwiftUI

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      Graphviz(dot: """
        digraph {
            A -> B
            B -> C
            A -> C
        }
        """
      )
    }
  }
}
