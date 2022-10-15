import SwiftSyntax

class FileVisitor: SyntaxVisitor {

  let fileName: String
  private(set) var numberOfStructs = 0
  private(set) var numberOfClasses = 0
  private(set) var numberOfEnums = 0
  private(set) var functionStats: [FunctionStats] = []

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

  override func visit(_ node: SourceFileSyntax) -> SyntaxVisitorContinueKind {
    body = "\(node)"
    return .visitChildren
  }

  var fileStats: FileStats {
    .init(
      name: fileName,
      numberOfStructs: numberOfStructs,
      numberOfClasses: numberOfClasses,
      numberOfEnums: numberOfEnums,
      functionStats: functionStats,
      fileLength: body.components(separatedBy: "\n").count
    )
  }
}
