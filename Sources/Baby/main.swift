
/*
 * @nixzhu (zhuhongxu@gmail.com)
 */

import Foundation
import BabyBrain

func main(_ arguments: [String]) {
    func printVersion() {
        print("Version 0.26.0")
        print("Created by nixzhu with love.")
    }
    
    func printUsage() {
        print("Usage: $ json_path output_path baby config.json")
    }

    func loadConfig(filePath: String) -> Meta? {
        
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            print("File not found `\(filePath)`!")
            return nil
        }
        guard fileManager.isReadableFile(atPath: filePath) else {
            print("No permission to read file at `\(filePath)`!")
            return nil
        }
        guard let data = fileManager.contents(atPath: filePath) else {
            print("File is empty!")
            return nil
        }
      
        do {
            let decoder = JSONDecoder()
            let project = try decoder.decode(Meta.self, from: data)
            return project
        } catch {
            print("Error decode json:", error.localizedDescription)
            exit(0)
        }
    }

    func getFileContent(path: String) -> String? {
        let fileManager = FileManager.default
        guard fileManager.isReadableFile(atPath: path) else {
            print("No permission to read file `\(path)`!")
            return nil
        }
        guard let data = fileManager.contents(atPath: path) else {
            print("File is empty!")
            return nil
        }
        guard let jsonString = String(data: data, encoding: .utf8) else {
            print("File is not encoded with UTF8!")
            return nil
        }

        return jsonString
    }
    
    func writeFileContent(path: String, content: String) {
        let fileManager = FileManager.default
        let data = content.data(using: .utf8)
        
        if !fileManager.createFile(atPath: path, contents: data) {
            print("Error write \(path)")
        } else {
            print(path, "\(data?.count ?? 0) bytes written")
        }
    }
    
    
    func generateCode(modelName: String, json: String, project: Meta) -> String? {
        
        guard let (value, _) = parse(json) else {
            print("Invalid JSON!")
            return nil
        }

        let upgradedValue = value.upgraded(newName: modelName, meta: project)
        return upgradedValue.swiftCode(meta: project)
    }

    
    // Main

    if CommandLine.argc != 3 && CommandLine.argc != 4 {
        printVersion()
        printUsage()
        return
    }
    
    let project: Meta?
    if CommandLine.argc == 4 {
        project = loadConfig(filePath: CommandLine.arguments[3])
    } else {
        project = Meta.default
    }
    guard project != nil else { return }
    
    let jsonURLs: [URL]
    do {
        let fileManager = FileManager.default
        let dirURL = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        let fileURLs = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        jsonURLs = fileURLs.filter { $0.pathExtension == "json" }
    } catch {
        print(error.localizedDescription)
        return
    }
    
    guard !jsonURLs.isEmpty else {
        print("No any .json files in directory \(CommandLine.arguments[1])")
        return
    }

    for fileURL in jsonURLs {
        let name = fileURL.deletingPathExtension().lastPathComponent
        guard let fileContent = getFileContent(path: fileURL.path) else { return }

        let swiftCode = generateCode(modelName: name, json: fileContent, project: project!)
        guard swiftCode != nil else { return }
        
        let outputPath = URL(fileURLWithPath: CommandLine.arguments[2])
            .appendingPathComponent(name)
            .appendingPathExtension("swift")
            .path

        let header = """
////
///  \(name).swift
//

import Foundation
\n
"""
        writeFileContent(path: outputPath, content: header + swiftCode!)
    }
    
}

main(CommandLine.arguments)
