import SwiftSyntax

class FileVisitor: SyntaxVisitor {

  private(set) var numberOfStructs = 0
  private(set) var numberOfClasses = 0
  private(set) var numberOfEnums = 0
  private(set) var functionsInfo: [FunctionInfo] = []

  private(set) var body: String = ""

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
    self.functionsInfo.append(
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
}

struct FunctionInfo: CustomStringConvertible {
  let name: String
  let bodyLength: Int

  var description: String {
    "(name: \(name), length: \(bodyLength))"
  }
}