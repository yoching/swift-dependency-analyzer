import SwiftSyntax

class FileVisitor: SyntaxVisitor {

  // MARK: - Properties
  let fileName: String

  private(set) var numberOfStructs = 0
  private(set) var numberOfClasses = 0
  private(set) var numberOfEnums = 0

  private(set) var functionStats: [FunctionStats] = []

  private(set) var classDependencies: [TypeName: [[LabelAndType]]] = [:]

  private(set) var body: String = ""

  // MARK: - Initializer
  init(fileName: String) {
    self.fileName = fileName
    super.init()
  }

  // MARK: - Visit methods
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
    functionStats.append(
      .init(
        name: node.identifier.description,
        bodyLength: bodyStatementsLength
      )
    )
    return .visitChildren
  }

  override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
    body = "\(node)"
    return .visitChildren
  }

  // MARK: - Stats
  var fileStats: FileStats {
    return .init(
      name: fileName,
      fileLength: body.components(separatedBy: "\n").count,
      numberOfStructs: numberOfStructs,
      numberOfClasses: numberOfClasses,
      numberOfEnums: numberOfEnums,
      functionStats: functionStats,
      classDependencyStats: simplifiedClassDependencies.map(ClassDependencyStats.init),
      dependencyLinks: dependencyLinks
    )
  }
}

// MARK: - Private Methods
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
    simplifiedClassDependencies
      .reduce(into: []) { acc, element in
        let source = element.key
        acc.append(
          contentsOf:
            element.value
            .map { (target, count) -> DependencyLink in
              return DependencyLink(source: source, target: target, count: count)
            }
        )
      }
  }
}

// MARK: - SwiftSyntax extensions
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
