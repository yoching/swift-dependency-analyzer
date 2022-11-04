import SwiftSyntax

class FileVisitor: SyntaxVisitor {

  let fileName: String

  private(set) var numberOfStructs = 0
  private(set) var numberOfClasses = 0
  private(set) var numberOfEnums = 0
  private(set) var functionStats: [FunctionStats] = []

  private(set) var dependentElementIdentifiers: [String] = []

  private(set) var classDependencies: [String: [[(label: String, type: String)]]] = [:]

  private var simplifiedClassDependencies: [String: [String]] {
    return classDependencies.mapValues {
      $0.flatMap { $0.map { $0.type } }
    }
  }
  private var simplifiedClassDependencies2:
    [String /* source */: [String /* target */: Int /* count */]]
  {
    simplifiedClassDependencies.mapValues {
      dependentElementIdentifiers -> [String: Int] in
      return Dictionary(grouping: dependentElementIdentifiers, by: { $0 })
        .mapValues { $0.count }
    }
  }
  private var dependencyLinks: [DependencyLink] {
    return
      simplifiedClassDependencies2.reduce(into: []) { acc, element in
        let source = element.key
        for (target, count) in element.value {
          acc.append(.init(source: source, target: target, count: count))
        }
      }
  }

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

    var className = ""
    switch node.identifier.tokenKind {
    case .identifier(let identifier):
      className = identifier
    default:
      break
    }

    var memberInfo: [[(label: String, type: String)]] = []
    for member: MemberDeclListItemSyntax in node.members.members {
      if let variableDecl = member.decl.asProtocol(DeclSyntaxProtocol.self) as? VariableDeclSyntax {
        memberInfo.append(dependentElementIdentifier(decl: variableDecl))
      }
    }

    classDependencies[className] = memberInfo

    return .visitChildren
  }

  override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    numberOfEnums += 1
    return .visitChildren
  }

  override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    let bodyStatementsLength =
      node.body?.statements.description.components(separatedBy: "\n").count ?? 0
    self.functionStats.append(
      .init(
        name: node.identifier.description,
        bodyLength: bodyStatementsLength
      )
    )
    return .visitChildren
  }

  override func visit(_ decl: VariableDeclSyntax) -> SyntaxVisitorContinueKind {

    print(decl.parent)
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

    let classDependencyStats = simplifiedClassDependencies.map {
      className, dependentElementIdentifiers -> ClassDependencyStats in
      .init(
        className: className,
        dependencies: Dictionary(grouping: dependentElementIdentifiers, by: { $0 })
          .mapValues { $0.count }
          .map(FileDependencyStats.init)
      )
    }

    return .init(
      name: fileName,
      numberOfStructs: numberOfStructs,
      numberOfClasses: numberOfClasses,
      numberOfEnums: numberOfEnums,
      functionStats: functionStats,
      fileLength: body.components(separatedBy: "\n").count,
      dependencyStats: dependencyStats,
      classDependencyStats: classDependencyStats,
      dependencyLinks: dependencyLinks
    )
  }

  func dependentElementIdentifier(decl: VariableDeclSyntax) -> [(label: String, type: String)] {
    return decl.bindings.compactMap(dependentElementIdentifier)
  }

  func dependentElementIdentifier(binding: PatternBindingListSyntax.Element) -> (
    label: String, type: String
  )? {
    var label: String = ""

    // Label
    let pattern = binding.pattern
    for token in pattern.tokens {
      switch token.tokenKind {
      case .identifier(let identifier):
        label = identifier
      default:
        return nil
      }
    }

    // Type
    var typeName: String = ""
    guard let type = binding.typeAnnotation?.type else {
      print("Type annotation not found")
      return nil
    }

    for token in type.tokens {
      switch token.tokenKind {
      case .identifier(let identifier):
        typeName = identifier
      default:
        return nil
      }
    }

    return (label: label, type: typeName)
  }
}

struct FileDependencyStats: Encodable {
  let identifier: String
  let count: Int
}

struct ClassDependencyStats: Encodable {
  let className: String
  let dependencies: [FileDependencyStats]
}

struct DependencyLink: Encodable {
  let source: String
  let target: String
  let count: Int
}
