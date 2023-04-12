import Foundation

struct DependencyLink: Encodable {
  let source: String
  let target: String
  let count: Int
}
