import Foundation

struct ClassDependencyStats: Encodable {
  let className: TypeName
  let dependencies: [DependencyCount]
}

struct DependencyCount: Encodable {
  let typeName: TypeName
  let count: Int
}
