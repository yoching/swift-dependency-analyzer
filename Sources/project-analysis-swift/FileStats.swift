import Foundation

struct FileStats: Encodable {
  let name: String
  let numberOfStructs: Int
  let numberOfClasses: Int
  let numberOfEnums: Int
  let functionStats: [FunctionStats]

  let fileLength: Int
  // let dependencyStats: [FileDependencyStats]
  let classDependencyStats: [ClassDependencyStats]
  let dependencyLinks: [DependencyLink]
}
