import SwiftSyntax

class FileVisitor: SyntaxVisitor {

  let fileName: String

  private(set) var numberOfStructs = 0
  private(set) var numberOfClasses = 0
  private(set) var numberOfEnums = 0
  private(set) var functionStats: [FunctionStats] = []

  private(set) var dependentElementIdentifiers: [String] = []

  private(set) var body: String = ""

  init(fileName: String) {
    self.fileName = fileName
    super.init()
  }

  override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    numberOfStructs += 1
    return .visitChildren
  }

  override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
    numberOfClasses += 1
    return .visitChildren
  }

  override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    numberOfEnums += 1
    return .visitChildren
  }

  override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    let bodyStatementsLength = node.body?.statements.description.components(separatedBy: "\n").count ?? 0
    self.functionStats.append(
      .init(
        name: node.identifier.description,
        bodyLength: bodyStatementsLength
      )
    )
    return .visitChildren
  }

  override func visit(_ decl: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
    for binding in decl.bindings {

      // Label
      // let pattern = binding.pattern
      // for token in pattern.tokens {
      //   switch token.tokenKind {
      //     case .identifier(let identifier):
      //     default:
      //     break
      //   }
      // }

      // Type
      guard let type = binding.typeAnnotation?.type else {
        print("Type annotation not found")
        break
      }
      for token in type.tokens {
        switch token.tokenKind {
          case .identifier(let identifier):

          dependentElementIdentifiers.append(identifier)
          default:
          break
        }
      }
    }
    return .visitChildren
  }

  override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
    body = "\(node)"
    return .visitChildren
  }

  var fileStats: FileStats {

    let dependencyStats = Dictionary(grouping: dependentElementIdentifiers, by: { $0 })
      .mapValues { $0.count }
      .map(FileDependencyStats.init)

    return .init(
      name: fileName,
      numberOfStructs: numberOfStructs,
      numberOfClasses: numberOfClasses,
      numberOfEnums: numberOfEnums,
      functionStats: functionStats,
      fileLength: body.components(separatedBy: "\n").count,
      dependencyStats: dependencyStats
    )
  }
}

struct FileDependencyStats: Encodable {
  let identifier: String
  let count: Int
}