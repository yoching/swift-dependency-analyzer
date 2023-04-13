import Foundation

struct FileStats: Encodable {

  let name: String
  let fileLength: Int

  let numberOfStructs: Int
  let numberOfClasses: Int
  let numberOfEnums: Int

  let functionStats: [FunctionStats]

  let classDependencyStats: [ClassDependencyStats]

  let dependencyLinks: [DependencyLink]
}
