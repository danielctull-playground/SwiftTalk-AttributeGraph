import Testing
@testable import AttributeGraph

@Test func example() async throws {
  let graph = AttributeGraph()
  let a = graph.input(name: "A", 10)
  let b = graph.input(name: "B", 20)
  let c = graph.rule(name: "C") { a.wrappedValue + b.wrappedValue }
  #expect(c.wrappedValue == 30)

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C
    A -> C
    B -> C
    }
    """)

   a.wrappedValue = 40
//   #expect(c.wrappedValue == 60)

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C [style=dashed]
    A -> C [style=dashed]
    B -> C
    }
    """)
}

@Test func twoDeep() async throws {
  let graph = AttributeGraph()
  let a = graph.input(name: "A", 10)
  let b = graph.input(name: "B", 20)
  let c = graph.rule(name: "C") { a.wrappedValue + b.wrappedValue }
  let d = graph.rule(name: "D") { c.wrappedValue * 2 }
  #expect(c.wrappedValue == 30)
  #expect(d.wrappedValue == 60)

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C
    D
    A -> C
    B -> C
    C -> D
    }
    """)

  a.wrappedValue = 40

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C [style=dashed]
    D [style=dashed]
    A -> C [style=dashed]
    B -> C
    C -> D
    }
    """)

  #expect(d.wrappedValue == 120)

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C
    D
    A -> C
    B -> C
    C -> D
    }
    """)
}

@Test func example3() async throws {
  let graph = AttributeGraph()
  let a = graph.input(name: "A", 10)
  let b = graph.input(name: "B", 20)
  let c = graph.rule(name: "C") { a.wrappedValue + b.wrappedValue }
  let d = graph.rule(name: "D") { c.wrappedValue * 2 }
  let e = graph.rule(name: "E") { a.wrappedValue * 2 }
  #expect(c.wrappedValue == 30)
  #expect(d.wrappedValue == 60)
  #expect(e.wrappedValue == 20)

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C
    D
    E
    A -> C
    A -> E
    B -> C
    C -> D
    }
    """)

  a.wrappedValue = 40

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C [style=dashed]
    D [style=dashed]
    E [style=dashed]
    A -> C [style=dashed]
    A -> E [style=dashed]
    B -> C
    C -> D
    }
    """)

  #expect(d.wrappedValue == 120)

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C
    D
    E [style=dashed]
    A -> E [style=dashed]
    A -> C
    B -> C
    C -> D
    }
    """)

  #expect(e.wrappedValue == 80)

  #expect(graph.graphViz == """
    digraph {
    A
    B
    C
    D
    E
    A -> C
    A -> E
    B -> C
    C -> D
    }
    """)
}
