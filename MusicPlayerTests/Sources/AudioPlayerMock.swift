//
//  AudioPlayerMock.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 31/07/25.
//

import AVFoundation
@testable import MusicPlayer

final class AudioPlayerMock: AudioPlayerProtocol {

    var currentItem: AVPlayerItem?
    var timeControlStatus: AVPlayer.TimeControlStatus = .paused

    var playCallCount = 0
    var pauseCallCount = 0
    var seekCallCount = 0
    var addTimeObserverCallCount = 0
    var removeTimeObserverCallCount = 0

    var seekCompletionResult: Bool = true
    var seekToTime: CMTime?
    var timeObserverInterval: CMTime?
    var timeObserverBlock: ((CMTime) -> Void)?

    func replaceCurrentItem(with item: AVPlayerItem?) {
        currentItem = item
    }

    func play() {
        playCallCount += 1
        timeControlStatus = .playing
    }

    func pause() {
        pauseCallCount += 1
        timeControlStatus = .paused
    }

    func seek(to time: CMTime, completionHandler: @escaping @Sendable (Bool) -> Void) {
        seekCallCount += 1
        seekToTime = time
        DispatchQueue.main.async {
            completionHandler(self.seekCompletionResult)
        }
    }

    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping @Sendable (CMTime) -> Void) -> Any {
        addTimeObserverCallCount += 1
        timeObserverInterval = interval
        timeObserverBlock = block
        return "MockTimeObserver"
    }

    func removeTimeObserver(_ observer: Any) {
        removeTimeObserverCallCount += 1
    }

    func simulateTimeUpdate(time: CMTime) {
        timeObserverBlock?(time)
    }
}
