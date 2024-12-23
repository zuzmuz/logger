import Foundation

enum LogLevel: Int {
    case verbose = -1
    case debug = 0
    case info = 1
    case notice = 2
    case warning = 3
    case error = 4
    case critical = 5

    var label: String {
        switch self {
        case .verbose:
            return "VERBOSE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .notice:
            return "NOTICE"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .critical:
            return "CRITICAL"
        }
    }
}

protocol Logger {
    func log(level: LogLevel, message: Data)
    func log(level: LogLevel, message: String)
}


class FileLogger: Logger {
    var handle: FileHandle
    var dateFormatter: DateFormatter
    var level: LogLevel = .info

    init(path: URL, fileName: String) throws {
        let filePath = path.appending(path: fileName)
        if !FileManager.default.fileExists(atPath: path.relativeString) {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            if !FileManager.default.createFile(atPath: filePath.relativePath, contents: Data()) {
                throw NSError(domain: "Logger", code: 1, userInfo: ["message": "Failed to create log file"])
            }
        }

        self.handle = try FileHandle(forWritingTo: filePath)
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    }

    deinit {
        self.handle.closeFile()
    }

    func log(level: LogLevel, message: Data) {
        if level.rawValue >= self.level.rawValue {
            handle.seekToEndOfFile()
            handle.write("\(self.dateFormatter.string(from: Date())) \t\(level.label) \t".data(using: .utf8)!)
            handle.write(message)
            handle.write("\n".data(using: .utf8)!)
        }
    }

    func log(level: LogLevel, message: String) {
        log(level: level, message: message.data(using: .utf8)!)
    }
}

