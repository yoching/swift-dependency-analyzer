import Foundation
import SwiftSyntax
import SwiftSyntaxParser

// let file = CommandLine.arguments[1]
let url = URL(fileURLWithPath: "./Sources/example.swift")
let sourceFile = try SyntaxParser.parse(url)

let fileVisitor = FileVisitor()
let _ = fileVisitor.walk(sourceFile)

// print(sourceFile)

print("---")
print("Structs:", fileVisitor.numberOfStructs)
print("Classes:", fileVisitor.numberOfClasses)
print("Enums:", fileVisitor.numberOfEnums)
print("Functions:", fileVisitor.functionsInfo)
print("File length:", fileVisitor.body.components(separatedBy: "\n").count)
print("---")

// let incremented = AddOneToIntegerLiterals().visit(sourceFile)
// print(incremented)