//
//  TimeFormatterMock.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 31/07/25.
//

import Foundation
@testable import MusicPlayer

final class TimeFormatterMock: TimeFormatterProtocol {

    var formatTimeCallCount = 0
    var lastFormattedTime: TimeInterval?
    var returnValue = "0:00"

    func formatTime(_ time: TimeInterval) -> String {
        formatTimeCallCount += 1
        lastFormattedTime = time
        return returnValue
    }
}
