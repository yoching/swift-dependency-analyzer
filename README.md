# Swift Project Analysis 2

Analyze Swift projects using [SwiftSyntax](https://github.com/apple/swift-syntax).

## Features
- Analyze swift files in a folder and export the result to stats.json
- Detect class dependencies
  ```json
  {
    "className" : "A",
    "dependencies" : [
      {
        "typeName" : "B",
        "count" : 2
      }, // 2 references to `B`
      {
        "typeName" : "Int",
        "count" : 1
      } // 1 reference to `Int`
    ]
  }
  ```
- Dependency links
  - This could be used for visualization such as network diagram
  ```json
  [
    {
      "source" : "A",
      "target" : "B",
      "count" : 2
    }, // 2 references from `A` to `B`
    {
      "source" : "A",
      "target" : "Int",
      "count" : 1
    } // 1 reference from `A` to `Int`
  ]
  ```
- Count class/struct/enum
- Count file length
- Count function length
  ```json
  [
    {
      "name" : "foo",
      "bodyLength" : 1
    }
  ]
  ```

## How to run
```bash
$ swift run project-analysis-swift <path-to-project>
```

## Example

You can run this analysis for an example by the following command:
```bash
$ swift run project-analysis-swift ./Input/
```

### Input (example.swift)
```swift
class A {

  let b: B
  let b2: B

  let int: Int

  func foo() {

  }
}

class B {
}
```

### Output
```json
{
  "files" : [
    {
      "name" : "example.swift",
      "fileLength" : 14,
      
      "numberOfClasses" : 2,
      "numberOfStructs" : 0,
      "numberOfEnums" : 0,

      "functionStats" : [
        {
          "name" : "foo",
          "bodyLength" : 1
        }
      ],

      "classDependencyStats" : [
        {
          "className" : "A",
          "dependencies" : [
            {
              "typeName" : "B",
              "count" : 2
            },
            {
              "typeName" : "Int",
              "count" : 1
            }
          ]
        },
        {
          "className" : "B",
          "dependencies" : []
        }
      ],

      "dependencyLinks" : [
        {
          "source" : "A",
          "target" : "B",
          "count" : 2
        },
        {
          "source" : "A",
          "target" : "Int",
          "count" : 1
        }
      ]
    }
  ]
}
```

## Motivation
- I was interested in objectively comparing multiple Swift projects because I've made a lot of iOS apps from scratch during my career.
- This follows my previous project, [Swift Project Analysis - 1](https://github.com/yoching/SwiftProjectAnalysis-1), which was written in Rust, maily for learning purposes.
- Class dependencies could be visualized using data visualization libraries such as [D3](https://d3js.org/)