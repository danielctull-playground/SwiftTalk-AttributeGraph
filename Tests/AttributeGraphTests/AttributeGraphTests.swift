import Testing
@testable import AttributeGraph

@Test func example() async throws {
  let graph = AttributeGraph()
  let a = graph.input(name: "A", 10)
  let b = graph.input(name: "B", 20)
  let c = graph.rule(name: "C") { a.wrappedValue + b.wrappedValue }
  #expect(c.wrappedValue == 30)

  let expectedGraphViz = """
    digraph {
    A
    B
    C
    A -> C
    B -> C
    }
    """

  #expect(graph.graphViz == expectedGraphViz)

  // a.wrappedValue = 40
  // #expect(c.wrappedValue == 60)
  //
  // dependencies
  // a -> c
  // b -> c
}
