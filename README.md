# Swift Project Analysis 2

Analyze Swift projects using [SwiftSyntax](https://github.com/apple/swift-syntax)!

## Features
- Analyze swift files and export the result as a json file.
- Detect dependencies between classes:
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
- Make dependency links:
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
  - Another representation of class dependencies
  - This could be used for visualization, such as network diagram

- Count class/struct/enum
- Count file length
- Count function length:
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

You can run this with an example by this command:
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
- This follows my previous project, [Swift Project Analysis - 1](https://github.com/yoching/SwiftProjectAnalysis-1), which was written in Rust for learning purposes.
- Class dependencies could be visualized using libraries such as [D3](https://d3js.org/)