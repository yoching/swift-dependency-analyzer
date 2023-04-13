import Foundation

struct DependencyLink: Encodable {
  let source: TypeName
  let target: TypeName
  let count: Int
}
