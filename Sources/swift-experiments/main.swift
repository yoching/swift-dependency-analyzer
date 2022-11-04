import Files
import Foundation
import SwiftSyntax
import SwiftSyntaxParser

// let file = CommandLine.arguments[1]

func run() throws {

  print(CommandLine.arguments)

  let path = CommandLine.arguments[1]

  let sourceFolder = try Folder(path: path)

  let fileInfos = try sourceFolder.files.recursive.map { file throws -> FileStats in
    try analyzeOneFile(name: file.name, url: file.url)
  }

  let projectInfo = ProjectStats(files: fileInfos)

  try save(name: "stats.json", info: projectInfo)

  // try sourceFolder.files.recursive.forEach { file in
  //     try printSyntax(url: file.url)
  // }
}

func printSyntax(url: URL) throws {
  let sourceFile = try SyntaxParser.parse(url)
  let strippedSyntax = sourceFile.withoutTrivia()
  dump(strippedSyntax)
}

func analyzeOneFile(name: String, url: URL) throws -> FileStats {
  let sourceFile = try SyntaxParser.parse(url)

  let fileVisitor = FileVisitor(fileName: name)
  let _ = fileVisitor.walk(sourceFile)

  // print(sourceFile)

  print("---")
  print("Structs:", fileVisitor.numberOfStructs)
  print("Classes:", fileVisitor.numberOfClasses)
  print("Enums:", fileVisitor.numberOfEnums)
  print("Functions:", fileVisitor.functionStats)
  print("File length:", fileVisitor.body.components(separatedBy: "\n").count)
  print("---")

  return fileVisitor.fileStats

  // let incremented = AddOneToIntegerLiterals().visit(sourceFile)
  // print(incremented)
}

func save<Info: Encodable>(name: String, info: Info) throws {
  let encoder = JSONEncoder()
  encoder.outputFormatting = .prettyPrinted
  let jsonFile = try encoder.encode(info)
  let outputFolder = try Folder.current.createSubfolder(at: "Output")
  try outputFolder.createFile(at: name, contents: jsonFile)
}

try run()
