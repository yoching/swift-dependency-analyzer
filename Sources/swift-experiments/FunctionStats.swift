import Foundation

struct FunctionStats: CustomStringConvertible, Encodable {
  let name: String
  let bodyLength: Int

  var description: String {
    "(name: \(name), length: \(bodyLength))"
  }
}
