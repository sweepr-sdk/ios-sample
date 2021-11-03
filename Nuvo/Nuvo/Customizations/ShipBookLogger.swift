//
//  File.swift
//  SweeprNative
//
//  Created by Pawel Hofman on 30/03/2021.
//  Copyright © 2021 Sweepr Technologies Limited. All rights reserved.
//

import Foundation
import Sweepr
import ShipBookSDK

class ShipBookLogger: LogDestination {
  public var userId: String = ""

  public init(appId: String, appKey: String) {
    ShipBook.start(appId: appId, appKey: appKey)
  }

  func process(entry: LogEntry) {
    if let id = entry.user.id,
       id.compare(self.userId, options: .caseInsensitive) != .orderedSame {

      self.userId = id
      ShipBook.registerUser(userId: id)
    }

    let severity = ShipBookLogger.getSeverity(for: entry.level)
    ShipBookSDK.Log.message(msg: entry.message, severity: severity, tag: entry.tag,
                            function: entry.function, file: entry.file, line: entry.line)

    if let e = entry.error {
      ShipBookSDK.Log.message(msg: e.localizedDescription, severity: severity, tag: entry.tag,
                              function: entry.function, file: entry.file, line: entry.line)
    }

    if let e = entry.exception {
      ShipBookSDK.Log.message(msg: "\(e.domain): \(e.code): \(e.localizedDescription)", severity: severity, tag: entry.tag,
                              function: entry.function, file: entry.file, line: entry.line)
    }

    if let e = entry.fatal {
      ShipBookSDK.Log.message(msg: "\(e.name): \(String(describing: e.reason))", severity: severity, tag: entry.tag,
                              function: entry.function, file: entry.file, line: entry.line)
    }
  }

  private static func getSeverity(for level: LogLevel) -> ShipBookSDK.Severity {
    switch level {
    case .debug: return .Debug
    case .info: return .Info
    case .warning: return .Warning
    case .error: return .Error
    @unknown default:
        return .Verbose
    }
  }
}
