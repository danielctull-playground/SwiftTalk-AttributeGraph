import Testing
@testable import AttributeGraph

@Test func example() async throws {
  let graph = AttributeGraph()
  let a = graph.input(10)
  let b = graph.input(20)
  let c = graph.rule { a.wrappedValue + b.wrappedValue }
  #expect(c.wrappedValue == 30)
  // a.wrappedValue = 40
  // #expect(c.wrappedValue == 60)
  //
  // dependencies
  // a -> c
  // b -> c
}
