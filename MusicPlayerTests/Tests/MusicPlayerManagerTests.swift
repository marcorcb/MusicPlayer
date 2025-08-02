//
//  MusicPlayerManagerTests.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 31/07/25.
//

import Testing
import Foundation
import AVFoundation
import XCTest
@testable import MusicPlayer

struct MusicPlayerManagerTests : ~Copyable {

    // MARK: - Public properties

    var sut: MusicPlayerManager!
    var audioPlayerMock: AudioPlayerMock!
    var audioSessionMock: AudioSessionMock!
    var timeFormatterMock: TimeFormatterMock!

    // MARK: - Initialization

    init() {
        audioPlayerMock = AudioPlayerMock()
        audioSessionMock = AudioSessionMock()
        timeFormatterMock = TimeFormatterMock()

        let dependencies = MusicPlayerDependencies(
            audioPlayer: audioPlayerMock,
            audioSession: audioSessionMock,
            notificationCenter: NotificationCenter.default,
            timeFormatter: timeFormatterMock
        )

        sut = MusicPlayerManager(dependencies: dependencies)
    }

    // MARK: - Tests

    @Test("Initialization setup AudioSession success")
    func test_initialization_setupAudioSession() async throws {
        #expect(audioSessionMock.setCategoryCallCount == 1)
        #expect(audioSessionMock.setActiveCallCount == 1)
        #expect(audioSessionMock.lastCategory == .playback)
        #expect(audioSessionMock.lastMode == .default)
        #expect(audioSessionMock.lastOptions == [.allowAirPlay, .allowBluetooth])
        #expect(audioSessionMock.lastActiveValue == true)
    }

    @Test("Initialization setup AudioSession error")
    func test_initialization_setupAudioSession_error() async throws {
        audioSessionMock.shouldThrowError = true

        let dependencies = MusicPlayerDependencies(
            audioPlayer: audioPlayerMock,
            audioSession: audioSessionMock,
            notificationCenter: NotificationCenter.default,
            timeFormatter: timeFormatterMock
        )

        let playerManager = MusicPlayerManager(dependencies: dependencies)

        #expect(playerManager.playerError == "Audio session setup failed")
    }

    @Test("Play valid song and song list")
    func test_play_validSongAndSongList() async throws {
        let songs = [
            Song.mock(trackId: 1, trackName: "Song 1"),
            Song.mock(trackId: 2, trackName: "Song 2")
        ]

        sut.play(song: songs[1], songList: songs)

        #expect(sut.playlist == songs)
        #expect(sut.currentIndex == 1)
        #expect(sut.currentSong?.trackId == songs[1].trackId)
        #expect(sut.isLoading)
        #expect(audioPlayerMock.playCallCount == 1)
    }

    @Test("Play valid song not on song list error")
    func test_play_validSongNotOnList_error() async throws {
        let songs = [Song.mock(trackId: 1)]
        let songNotOnList = Song.mock(trackId: 2)

        sut.play(song: songNotOnList, songList: songs)

        #expect(sut.playerError == "Failed to find song in playlist")
        #expect(audioPlayerMock.playCallCount == 0)
    }

    @Test("Play valid song but empty list error")
    func test_play_validSongEmptyList_error() async throws {
        let song = Song.mock()

        sut.play(song: song, songList: [])

        #expect(sut.playerError == "Failed to find song in playlist")
        #expect(audioPlayerMock.playCallCount == 0)
    }

    @Test("Next song on valid playlist")
    func test_nextSong_validPlaylist() async throws {
        let songs = [
            Song.mock(trackId: 1),
            Song.mock(trackId: 2),
            Song.mock(trackId: 3)
        ]
        sut.play(song: songs[0], songList: songs)

        sut.nextSong()

        #expect(sut.currentIndex == 1)
        #expect(sut.currentSong?.id == songs[1].id)
    }

    @Test("Next song on last song in valid playlist with repeat on")
    func test_nextSongOnLastSong_validPlaylist_repeatOn() async throws {
        let songs = [
            Song.mock(trackId: 1),
            Song.mock(trackId: 2),
            Song.mock(trackId: 3)
        ]
        sut.play(song: songs[2], songList: songs)
        sut.isRepeatOn = true

        sut.nextSong()

        #expect(sut.currentIndex == 0)
        #expect(sut.currentSong?.id == songs[0].id)
    }

    @Test("Next song on last song in valid playlist with repeat off")
    func test_nextSongOnLastSong_validPlaylist_repeatOff() async throws {
        let songs = [
            Song.mock(trackId: 1),
            Song.mock(trackId: 2),
            Song.mock(trackId: 3)
        ]
        sut.play(song: songs[2], songList: songs)
        sut.isRepeatOn = false

        sut.nextSong()

        #expect(sut.currentIndex == 2)
        #expect(sut.currentSong?.id == songs[2].id)
    }

    @Test("Previous song on valid playlist")
    func test_previousSong_validPlaylist() async throws {
        let songs = [
            Song.mock(trackId: 1),
            Song.mock(trackId: 2),
            Song.mock(trackId: 3)
        ]
        sut.play(song: songs[1], songList: songs)

        sut.previousSong()

        #expect(sut.currentIndex == 0)
        #expect(sut.currentSong?.id == songs[0].id)
    }

    @Test("Previous song on first song in valid playlist with repeat on")
    func test_previousSongOnFirstSong_validPlaylist_repeatOn() async throws {
        let songs = [
            Song.mock(trackId: 1),
            Song.mock(trackId: 2),
            Song.mock(trackId: 3)
        ]
        sut.play(song: songs[0], songList: songs)
        sut.isRepeatOn = true

        sut.previousSong()

        #expect(sut.currentIndex == 2)
        #expect(sut.currentSong?.id == songs[2].id)
    }

    @Test("Toggle shuffle on")
    func test_toggleShuffleOn() async throws {
        let songs = [
            Song.mock(trackId: 1),
            Song.mock(trackId: 2),
            Song.mock(trackId: 3)
        ]
        sut.play(song: songs[1], songList: songs)

        sut.toggleShuffle()

        #expect(sut.isShuffleOn)
        #expect(sut.shuffledPlaylist.count == songs.count)
        #expect(sut.shuffledPlaylist[0].trackId == songs[1].trackId)
        #expect(sut.currentShuffledIndex == 0)
    }

    @Test("Toggle shuffle off")
    func test_toggleShuffleOff() async throws {
        let songs = [
            Song.mock(trackId: 1),
            Song.mock(trackId: 2),
            Song.mock(trackId: 3)
        ]
        sut.play(song: songs[1], songList: songs)

        sut.toggleShuffle()
        sut.toggleShuffle()

        #expect(sut.isShuffleOn == false)
        #expect(sut.shuffledPlaylist.isEmpty)
        #expect(sut.currentShuffledIndex == 0)
        #expect(sut.currentIndex == 1)
    }

    @Test("Pause player")
    func test_pausePlayer() async throws {
        let songs = [Song.mock()]
        sut.play(song: songs[0], songList: songs)

        sut.togglePlayPause()

        #expect(audioPlayerMock.pauseCallCount == 1)
        #expect(sut.isPlaying == false)
    }

    @Test("Unpause player")
    func test_unpausePlayer() async throws {
        let songs = [Song.mock()]
        sut.play(song: songs[0], songList: songs)

        sut.togglePlayPause()
        sut.togglePlayPause()

        #expect(audioPlayerMock.playCallCount == 2)
        #expect(sut.isPlaying == true)
    }

    @Test("Stop player reset state")
    func test_stopPlayer_resetState() async throws {
        let songs = [Song.mock()]
        sut.play(song: songs[0], songList: songs)

        sut.stop()

        #expect(audioPlayerMock.pauseCallCount == 1)
        #expect(audioPlayerMock.seekCallCount == 1)
        #expect(sut.currentTime == 0)
        #expect(sut.isPlaying == false)
    }

    @Test("Slider start seeking")
    func test_sliderStartSeeking() async throws {
        sut.sliderValue = 45.0

        #expect(sut.isSeekInProgress)
        #expect(sut.seekTime == 45.0)
    }

    @Test("Format current time", .tags(.timeFormatter))
    func test_formatCurrentTime() async throws {
        sut.currentTime = 125.0
        timeFormatterMock.returnValue = "2:05"

        let result = sut.formattedCurrentTime

        #expect(result == "2:05")
        #expect(timeFormatterMock.formatTimeCallCount == 1)
        #expect(timeFormatterMock.lastFormattedTime == 125.0)
    }

    @Test("Format current time when seeking", .tags(.timeFormatter))
    func test_formatCurrentTime_whenSeeking() async throws {
        sut.currentTime = 60.0
        sut.sliderValue = 90.0
        timeFormatterMock.returnValue = "1:30"

        let result = sut.formattedCurrentTime

        #expect(result == "1:30")
        #expect(timeFormatterMock.lastFormattedTime == 90.0)
    }

    @Test("Format current duration", .tags(.timeFormatter))
    func test_formatCurrentDuration() async throws {
        sut.duration = 180.0
        timeFormatterMock.returnValue = "3:00"

        let result = sut.formattedDuration

        #expect(result == "3:00")
        #expect(timeFormatterMock.formatTimeCallCount == 1)
        #expect(timeFormatterMock.lastFormattedTime == 180.0)
    }

    @Test("Progress", .tags(.progress))
    func test_progress() async throws {
        sut.currentTime = 60.0
        sut.duration = 120.0

        #expect(sut.progress == 0.5)
    }

    @Test("Progress when seeking", .tags(.progress))
    func test_progress_whenSeeking() async throws {
        sut.currentTime = 30.0
        sut.duration = 120.0
        sut.sliderValue = 90.0

        #expect(sut.progress == 0.75)
    }

    @Test("Progress on zero duration", .tags(.progress))
    func test_progress_onZeroDuration() async throws {
        sut.currentTime = 60.0
        sut.duration = 0.0

        #expect(sut.progress == 0.0)
    }

    @Test("Last song has next song with repeat on")
    func test_lastSongHasNextSong_withRepeatOn() async throws {
        let songs = [Song.mock(trackId: 1)]
        sut.play(song: songs[0], songList: songs)
        sut.isRepeatOn = true

        #expect(sut.hasNextSong)
    }

    @Test("Last song has next song with repeat off")
    func test_lastSongHasNextSong_withRepeatOff() async throws {
        let songs = [Song.mock(trackId: 1), Song.mock(trackId: 2)]
        sut.play(song: songs[1], songList: songs)
        sut.isRepeatOn = false

        #expect(sut.hasNextSong == false)
    }

    @Test("First song has previous song with repeat on")
    func test_firstSongHasPreviousSong_withRepeatOn() async throws {
        let songs = [Song.mock(trackId: 1)]
        sut.play(song: songs[0], songList: songs)
        sut.isRepeatOn = true

        #expect(sut.hasPreviousSong)
    }

    @Test("First song has previous song with repeat off")
    func test_firstSongHasPreviousSong_withRepeatOff() async throws {
        let songs = [Song.mock(trackId: 1), Song.mock(trackId: 2)]
        sut.play(song: songs[0], songList: songs)
        sut.isRepeatOn = false

        #expect(sut.hasPreviousSong == false)
    }

    @Test("Song title is the same as current song")
    func test_songTitleIsTheSameAsCurrentSong() async throws {
        let song = Song.mock(trackName: "Test track")
        sut.currentSong = song

        #expect(sut.songTitle == song.trackName)
    }

    @Test("Song title without current song is default message")
    func test_songTitleWithoutCurrentSongIsDefaultMessage() async throws {
        sut.currentSong = nil

        #expect(sut.songTitle == "No song playing")
    }

    @Test("Artist name is the same as current song artist name")
    func test_artistNameIsTheSameAsCurrentSongArtistName() async throws {
        let song = Song.mock(artistName: "Test artist")
        sut.currentSong = song

        #expect(sut.artistName == song.artistName)
    }

    @Test("Artist name without current song is default message")
    func test_artistNameWithoutCurrentSongIsDefaultMessage() async throws {
        sut.currentSong = nil

        #expect(sut.artistName == "Unknown Artist")
    }

    @Test("Small artwork URL with valid URL")
    func test_smallArtworkURLWithValidURL() async throws {
        let song = Song.mock(artworkUrl60: "https://example.com/artwork60.jpg")
        sut.currentSong = song

        #expect(sut.smallArtworkURL?.absoluteString == song.artworkUrl60)
    }

    @Test("Small artwork URL with invalid URL")
    func test_smallArtworkURLWithInvalidURL() async throws {
        let song = Song.mock(artworkUrl60: "")
        sut.currentSong = song

        #expect(sut.smallArtworkURL == nil)
    }

    @Test("Standard artwork URL with valid URL")
    func test_standardArtworkURLWithValidURL() async throws {
        let song = Song.mock(artworkUrl100: "https://example.com/artwork100.jpg")
        sut.currentSong = song

        #expect(sut.standardArtworkURL?.absoluteString ==  song.artworkUrl100)
    }

    @Test("Standard artwork URL with invalid URL")
    func test_standardArtworkURLWithInvalidURL() async throws {
        let song = Song.mock(artworkUrl100: "")
        sut.currentSong = song

        #expect(sut.standardArtworkURL == nil)
    }

    @Test("Load and play current song with invalid preview URL")
    func test_loadAndPlayCurrentSongWithInvalidPreviewURL_error() async throws {
        let song = Song.mock(previewUrl: "")
        sut.play(song: song, songList: [song])

        #expect(sut.playerError == "Invalid preview URL")
        #expect(sut.isPlaying == false)
        #expect(sut.isLoading == false)
    }

    @Test("Time observer updates current time")
    func test_timeObserverUpdatesCurrentTime() async throws {
        let songs = [Song.mock()]
        sut.play(song: songs[0], songList: songs)

        let testTime = CMTime(seconds: 45.0, preferredTimescale: 600)
        audioPlayerMock.simulateTimeUpdate(time: testTime)

        #expect(sut.currentTime == 45.0)
    }

    @Test("Time observer does not update while seeking")
    func test_timeObserverDoesNotUpdateWhileSeeking() async throws {
        let songs = [Song.mock()]
        sut.play(song: songs[0], songList: songs)
        sut.sliderValue = 30.0

        let testTime = CMTime(seconds: 45.0, preferredTimescale: 600)
        audioPlayerMock.simulateTimeUpdate(time: testTime)

        #expect(sut.currentTime != 45.0)
    }

    @Test("Cleanup removes time observer")
    mutating func test_cleanupRemovesTimeObserver() async throws {
        let songs = [Song.mock()]
        sut.play(song: songs[0], songList: songs)

        sut = nil

        #expect(audioPlayerMock.removeTimeObserverCallCount == 1)
    }

    @Test("Player controls playback flow")
    func test_playerControlsPlaybackFlow_PlayPauseResumeStop() async throws {
        let songs = [Song.mock(trackId: 1), Song.mock(trackId: 2)]

        // Play
        sut.play(song: songs[0], songList: songs)
        #expect(sut.isLoading)
        #expect(sut.currentSong?.trackId == songs[0].trackId)
        #expect(audioPlayerMock.playCallCount == 1)

        // Pause
        sut.togglePlayPause()
        #expect(audioPlayerMock.pauseCallCount == 1)
        #expect(sut.isPlaying == false)

        // Resume
        sut.togglePlayPause()
        #expect(audioPlayerMock.playCallCount == 2)
        #expect(sut.isPlaying == true)

        // Stop
        sut.stop()
        #expect(audioPlayerMock.pauseCallCount == 2)
        #expect(sut.currentTime == 0)
        #expect(sut.isPlaying == false)
    }

    @Test("Shuffle playback flow")
    func test_shufflePlaybackFlow() async throws {
        let songs = [
            Song.mock(trackId: 1, trackName: "Song 1"),
            Song.mock(trackId: 2, trackName: "Song 2"),
            Song.mock(trackId: 3, trackName: "Song 3")
        ]

        sut.play(song: songs[1], songList: songs)
        #expect(sut.currentIndex == 1)
        #expect(sut.isShuffleOn == false)

        // Enable shuffle
        sut.toggleShuffle()
        #expect(sut.isShuffleOn == true)
        #expect(sut.shuffledPlaylist.count == 3)
        #expect(sut.shuffledPlaylist[0].trackId == songs[1].trackId)
        #expect(sut.currentShuffledIndex == 0)

        // Next song while in shuffle
        sut.nextSong()
        #expect(sut.currentShuffledIndex == 1)

        // Previous song while in shuffle
        sut.previousSong()
        #expect(sut.currentShuffledIndex == 0)

        // Disable shuffle
        sut.toggleShuffle()
        #expect(sut.isShuffleOn == false)
        #expect(sut.currentShuffledIndex == 0)
        #expect(sut.shuffledPlaylist.isEmpty == true)
        #expect(sut.currentIndex == 1)
    }
}
