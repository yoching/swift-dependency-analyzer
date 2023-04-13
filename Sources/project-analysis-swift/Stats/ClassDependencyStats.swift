import Foundation

struct ClassDependencyStats: Encodable {
  let className: TypeName
  let dependencies: [DependencyCount]
}

extension ClassDependencyStats {
  init(
    className: TypeName,
    dependencies: [TypeName /* target */: Int /* count */]
  ) {
    self.className = className
    self.dependencies = dependencies.map(DependencyCount.init)
  }
}

struct DependencyCount: Encodable {
  let typeName: TypeName
  let count: Int
}
