//  Copyright © 2020 Eric M M PEI. All rights reserved.

import Foundation

/// Writes the textual representations of the given items into the standard
/// output.
///
/// You can pass zero or more items to the `print(_:separator:terminator:)`
/// function. The textual representation for each item is the same as that
/// obtained by calling `String(item)`. The following example prints a string,
/// a closed range of integers, and a group of floating-point values to
/// standard output:
///
///     printLog("One two three four five")
///     // Prints "One two three four five"
///
///     printLog(1...5)
///     // Prints "1...5"
///
///     printLog(1.0, 2.0, 3.0, 4.0, 5.0)
///     // Prints "1.0 2.0 3.0 4.0 5.0"
///
/// To print the items separated by something other than a space, pass a string
/// as `separator`.
///
///     printLog(1.0, 2.0, 3.0, 4.0, 5.0, separator: " ... ")
///     // Prints "1.0 ... 2.0 ... 3.0 ... 4.0 ... 5.0"
///
/// The output from each call to `print(_:separator:terminator:)` includes a
/// newline by default. To print the items without a trailing newline, pass an
/// empty string as `terminator`.
///
///     for n in 1...5 {
///         printLog(n, terminator: "")
///     }
///     // Prints "12345"
///
/// - Note:
/// This function takes effect in Debug mode only.
///
/// - Parameters:
///   - items: Zero or more items to print.
///   - file: The file path of the current log line.
///   - method: The method name of the current log line belongs to.
///   - line: The line number of the current log.
///   - separator: A string to print between each item. The default is a single space (`" "`).
///   - terminator: The string to print after all items have been printed. The default is a newline (`"\n"`).
public func printLog(_ items: Any...,
                     file: String = #file,
                     method: String = #function,
                     line: Int = #line,
                     separator: String = " ",
                     terminator: String = "\n") {
    #if DEBUG
    let verbosePrefix = "[\((file as NSString).lastPathComponent)][\(method)][\(line)]: "
    guard items.count != 0 else {
        print(verbosePrefix, terminator: terminator)
        return
    }
    print(verbosePrefix, terminator: "")
    items.enumerated().forEach {
        var innerTerminator = separator
        if $0 == items.endIndex - 1 {
            innerTerminator = ""
        }
        print($1, terminator: innerTerminator)
    }
    print("", terminator: terminator)
    #endif
}
