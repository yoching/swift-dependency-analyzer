import Foundation

struct ClassDependencyStats: Encodable {
  let className: String
  let dependencies: [FileDependencyStats]
}
