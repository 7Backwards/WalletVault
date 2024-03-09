//
//  LogManager.swift
//  SafeWallet
//
//  Created by Gonçalo on 07/03/2024.
//

import Foundation

class Logger {
    enum Level: String {
        case debug = "DEBUG", info = "INFO", warning = "WARNING", error = "ERROR"
    }

    private static var logFileURL: URL = {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let logDirectory = urls[0].appendingPathComponent("Logs", isDirectory: true)

        // Create Logs directory if it doesn't exist
        if !fileManager.fileExists(atPath: logDirectory.path) {
            try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        }

        return logDirectory.appendingPathComponent("appLog.txt")
    }()

    private static let queue = DispatchQueue(label: "logger.queue", qos: .background)

    static func log(_ message: String, level: Level = .info) {
        #if DEBUG
        let logMessage = "[\(level.rawValue)] \(message)\n"
        print(logMessage, terminator: "")
        #endif
        
        queue.async {
            appendToFile(logMessage)
        }
    }

    private static func appendToFile(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }

        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: data)
        } else {
            let fileHandle = try? FileHandle(forWritingTo: logFileURL)
            fileHandle?.seekToEndOfFile()
            fileHandle?.write(data)
            fileHandle?.closeFile()
        }
    }
}
