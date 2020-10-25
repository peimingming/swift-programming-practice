//
//  Copyright © 2020 Eric M M PEI. All rights reserved.
//

import Foundation

private let postFix = "-Filtered"

// MARK: - filter

func filter() {
    let arguments = ProcessInfo.processInfo.arguments
    guard let index1 = arguments.lastIndex(of: "-module-name")?.advanced(by: 3),
        arguments.count > index1.distance(to: 0) else {
            print("The path of the plist files not found.")
            return
    }
    let index2 = index1.advanced(by: 1)
    guard arguments.count > index2.distance(to: 0) else {
        print("The keyword which will be used to serach not found.")
        return
    }
    
    let path = ProcessInfo.processInfo.arguments[index1] + "/"
    let keyword = arguments[index2]
    
    let possibleFiles = (try? FileManager.default.contentsOfDirectory(atPath: path))?.filter {
        ($0.contains(".plist") || $0.contains(".strings")) && !$0.contains(postFix)
    }
    guard let files = possibleFiles, files.count > 0 else {
        print("No files need to be filtered")
        return
    }
    
    var temp = [String: Bool]()
    
    files.forEach {
        if $0.contains(".strings") {
            let baseFileNamePrefix = $0
                .replacingOccurrences(of: "-en.strings", with: "")
                .replacingOccurrences(of: "-zh_Hant.strings", with: "")
                .replacingOccurrences(of: "-zh_Hans.strings", with: "")
            if temp.updateValue(true, forKey: baseFileNamePrefix) == nil {
                filterStrings(path: path, baseFileNamePrefix: baseFileNamePrefix, keyword: keyword)
            }
        } else if $0.contains(".plist") {
            filterPlist(path: path, fileName: $0, keyword: keyword)
        }
    }
}

// MARK: Filter .strings files

func filterStrings(path: String,
                   baseFileNamePrefix: String,
                   keyword: String) {
    let pattern = "\"(.*)\" = \"(.*)\";"
    let regex = try! Regex(pattern)
    
    typealias Key = String
        
    @discardableResult
    func filter(withFileName fileName: String, withKeys keys: [Key]? = nil) -> [Key]? {
        guard let data = FileManager.default.contents(atPath: path + fileName),
            let string = String(data: data, encoding: .utf8) else {
            print("File not found, file: \(path + fileName)")
            return nil
        }
        
        let isEn = fileName.contains("en.strings")
        
        var enKeys = [Key]()
        
        let output = regex.matches(in: string).reduce("") {
            var match = $1
            guard let key = match.captures[0],
                let value = match.captures[1] else {
                fatalError("key and value must exist.")
            }
            
            if isEn, value.lowercased().contains(keyword) {
                enKeys.append(key)
                return $0 + match.string + "\n"
            } else if keys?.contains(key) ?? false {
                return $0 + match.string + "\n"
            } else {
                return $0
            }
        }
        
        let count = isEn ? enKeys.count : keys?.count ?? 0
        
        let filteredFileName = fileName.filterdFileName(withExtension: ".strings")
        let filteredPathURL = URL(fileURLWithPath: path + filteredFileName)
        guard let filteredData = output.data(using: .utf8),
            let _ = try? filteredData.write(to: filteredPathURL) else {
                print("Write to file failed, filtered file: \(filteredFileName)")
                return nil
        }
        print("Successfully!!! filtered file: \(filteredFileName), count: \(count)")
        return enKeys
    }
    
    let keys = filter(withFileName: "\(baseFileNamePrefix)-en.strings")
    
    filter(withFileName: "\(baseFileNamePrefix)-zh_Hant.strings", withKeys: keys)
    
    filter(withFileName: "\(baseFileNamePrefix)-zh_Hans.strings", withKeys: keys)
}

// MARK: - Filter .plist files

func filterPlist(path: String,
                 fileName: String,
                 keyword: String) {
    let fileURL = URL(fileURLWithPath: path + fileName)
    
    guard var json: [String: Any] = NSDictionary(contentsOf: fileURL) as? [String: Any] else {
        print("Incorrect plist file format, should be [String: Any].")
        return
    }
    
    guard let en = json["en"] as? [String: String],
        let zhHK = json["zh_HK"] as? [String: String],
        let zh = json["zh"] as? [String: String] else {
            print("Incorrect plist file format, should be [String: Any].")
            return
    }
    
    let enFiltered: [String: String] = en.filter { $1.lowercased().contains(keyword) }
    let keys = enFiltered.keys
    let zhHKFiltered: [String: String] = zhHK.filter { keys.contains($0.key) }
    let zhFiltered: [String: String] = zh.filter { keys.contains($0.key) }
    
    let count = enFiltered.count
    
    guard count == zhHKFiltered.count,
        count == zhFiltered.count else {
            print("Filtered copy count not matched.")
            return
    }
    
    json["en"] = enFiltered
    json["zh_HK"] = zhHKFiltered
    json["zh"] = zhFiltered
    
    guard let data = try? PropertyListSerialization.data(fromPropertyList: json, format: .xml, options: 0) else {
        print("Filtered xml file cannot be generated.")
        return
    }
    
    do {
        let filteredFileName = fileName.filterdFileName(withExtension: ".plist")
        try data.write(to: URL(fileURLWithPath: path + filteredFileName))
        print("Successfully!!! filtered file: \(filteredFileName), count: \(count)")

    } catch {
        print("Filtered xml cannot be cached")
        return
    }
    
}

// MARK: - Private helpers

private extension String {
    func filterdFileName(withExtension ext: String) -> String {
        var filteredFileName = self
        if let extensionRange = range(of: ext) {
            filteredFileName.removeSubrange(extensionRange)
        }
        filteredFileName += postFix + ext
        return filteredFileName
    }
}

private struct Regex {
    let regularExpression: NSRegularExpression

    init(_ pattern: String) throws {
        regularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
    }
    
    func matches(in string: String) -> [Match] {
        let matches = regularExpression
            .matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            .map { Match(checkingResult: $0, base: string) }
        return matches
    }
}

extension Regex {
    struct Match {
        private let checkingResult: NSTextCheckingResult
        private let base: String
        
        init(checkingResult: NSTextCheckingResult, base: String) {
            precondition(checkingResult.regularExpression != nil, "regularExpression is nil.")
            self.checkingResult = checkingResult
            self.base = base
        }
        
        lazy var string: String = {
            guard let range = Range(checkingResult.range, in: base) else {
                fatalError("range not found in the base.")
            }
            return String(describing: base[range])
        }()
        
        lazy var captures: [String?] = {
            stride(from: 0, to: checkingResult.numberOfRanges, by: 1)
                .map(checkingResult.range)
                .dropFirst()
                .map {
                    guard let range = Range($0, in: self.base) else {
                        return nil
                    }
                    return String(describing: self.base[range])
                }
        }()
    }
}

// MARK: - Start filtering

filter()
