import SwiftSyntax

typealias TypeName = String

typealias LabelAndType = (label: String, type: TypeName)

class FileVisitor: SyntaxVisitor {

  let fileName: String

  private(set) var numberOfStructs = 0
  private(set) var numberOfClasses = 0
  private(set) var numberOfEnums = 0
  private(set) var functionStats: [FunctionStats] = []

  // private(set) var dependentElementIdentifiers: [String] = []

  private(set) var classDependencies: [TypeName: [[LabelAndType]]] = [:]

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

    let memberInfo: [[LabelAndType]] = node.members.members
      .compactMap { $0.decl.asProtocol(DeclSyntaxProtocol.self) as? VariableDeclSyntax }
      .map(\.bindingInfos)

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

  // override func visit(_ decl: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
  //   dependentElementIdentifiers.append(
  //     contentsOf:
  //       decl.bindings.compactMap {
  //         $0.labelAndType?.type
  //       }
  //   )

  //   return .visitChildren
  // }

  override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
    body = "\(node)"
    return .visitChildren
  }

  var fileStats: FileStats {

    // let dependencyStats = Dictionary(grouping: dependentElementIdentifiers, by: { $0 })
    //   .mapValues { $0.count }
    //   .map(FileDependencyStats.init)

    let classDependencyStats = simplifiedClassDependencies.map {
      className, dependencies -> ClassDependencyStats in
      .init(
        className: className,
        dependencies:
          dependencies
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
      // dependencyStats: dependencyStats,
      classDependencyStats: classDependencyStats,
      dependencyLinks: dependencyLinks
    )
  }
}

extension FileVisitor {
  fileprivate var simplifiedClassDependencies:
    [TypeName /* source */: [TypeName /* target */: Int /* count */]]
  {
    classDependencies
      .mapValues { nestedLabelAndTypes -> [TypeName: Int] in
        let typeNames =
          nestedLabelAndTypes
          .flatMap { $0 }
          .map { $0.type }

        return Dictionary(grouping: typeNames, by: { $0 })
          .mapValues { $0.count }
      }
  }

  fileprivate var dependencyLinks: [DependencyLink] {
    return
      simplifiedClassDependencies.reduce(into: []) { acc, element in
        let source = element.key
        for (target, count) in element.value {
          acc.append(.init(source: source, target: target, count: count))
        }
      }
  }
}

extension VariableDeclSyntax {
  var bindingInfos: [LabelAndType] {
    self.bindings.compactMap(\.labelAndType)
  }
}

extension PatternBindingListSyntax.Element {
  var labelAndType: LabelAndType? {
    // Label
    guard let label = self.pattern.tokens.identifier else {
      return nil
    }

    // Type
    guard let type = self.typeAnnotation?.type,
      let typeName = type.tokens.identifier
    else {
      print("Type annotation not found")
      return nil
    }

    return (label: label, type: typeName)
  }
}

extension SwiftSyntax.TokenSequence {
  var identifier: String? {
    for token in self {
      switch token.tokenKind {
      case .identifier(let identifier):
        return identifier
      default:
        return nil
      }
    }

    return nil
  }
}
