//
//  AudioSessionMock.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 31/07/25.
//

import AVFoundation
@testable import MusicPlayer

final class AudioSessionMock: AudioSessionProtocol {

    var setCategoryCallCount = 0
    var setActiveCallCount = 0
    var shouldThrowError = false

    var lastCategory: AVAudioSession.Category?
    var lastMode: AVAudioSession.Mode?
    var lastOptions: AVAudioSession.CategoryOptions?
    var lastActiveValue: Bool?

    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws {
        setCategoryCallCount += 1
        lastCategory = category
        lastMode = mode
        lastOptions = options

        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
    }

    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
        setActiveCallCount += 1
        lastActiveValue = active

        if shouldThrowError {
            throw NSError(domain: "MockError", code: 2, userInfo: nil)
        }
    }
}
