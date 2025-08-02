//
//  MusicPlayerManager.swift
//  MusicPlayer
//
//  Created by Marco Braga on 28/07/25.
//

import AVFoundation
import Combine

protocol AudioPlayerProtocol: Sendable {
    var currentItem: AVPlayerItem? { get }
    var timeControlStatus: AVPlayer.TimeControlStatus { get }
    
    func replaceCurrentItem(with item: AVPlayerItem?)
    func play()
    func pause()
    func seek(to time: CMTime, completionHandler: @Sendable @escaping (Bool) -> Void)
    func addPeriodicTimeObserver(forInterval interval: CMTime, queue: DispatchQueue?, using block: @escaping @Sendable (CMTime) -> Void) -> Any
    func removeTimeObserver(_ observer: Any)
}

protocol AudioSessionProtocol: Sendable {
    func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) throws
    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
}

protocol NotificationCenterProtocol: Sendable  {
    func publisher(for name: Notification.Name, object: AnyObject?) -> NotificationCenter.Publisher
}

protocol TimeFormatterProtocol: Sendable {
    func formatTime(_ time: TimeInterval) -> String
}

final class DefaultTimeFormatter: TimeFormatterProtocol, Sendable {
    func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MusicPlayerDependencies: Sendable {
    let audioPlayer: AudioPlayerProtocol
    let audioSession: AudioSessionProtocol
    let notificationCenter: NotificationCenterProtocol
    let timeFormatter: TimeFormatterProtocol
    
    static let `default` = MusicPlayerDependencies(
        audioPlayer: AVPlayer(),
        audioSession: AVAudioSession.sharedInstance(),
        notificationCenter: NotificationCenter.default,
        timeFormatter: DefaultTimeFormatter()
    )
}

@MainActor
final class MusicPlayerManager: ObservableObject {
    
    // MARK: - Public properties
    
    @Published var playlist: [Song] = []
    @Published var shuffledPlaylist: [Song] = []
    @Published var currentIndex: Int = 0
    @Published var currentShuffledIndex: Int = 0
    @Published var currentSong: Song?
    
    @Published var isPlaying: Bool = false
    @Published var isShuffleOn: Bool = false
    @Published var isRepeatOn: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isLoading: Bool = false
    @Published var playerError: String?
    
    @Published var isSeekInProgress: Bool = false
    @Published var seekTime: TimeInterval = 0
    
    var hasNextSong: Bool {
        isRepeatOn || !isCurrentIndexLast
    }
    
    var hasPreviousSong: Bool {
        isRepeatOn || !isCurrentIndexFirst
    }
    
    var songTitle: String {
        currentSong?.trackName ?? "No song playing"
    }
    
    var artistName: String {
        currentSong?.artistName ?? "Unknown Artist"
    }
    
    var smallArtworkURL: URL? {
        URL(string: currentSong?.artworkUrl60 ?? "")
    }
    
    var standardArtworkURL: URL? {
        URL(string: currentSong?.artworkUrl100 ?? "")
    }
    
    var largeArtworkURL: URL? {
        URL(string: currentSong?.artworkUrl100.itunesLargeImageURL() ?? "")
    }
    
    var formattedCurrentTime: String {
        let timeToFormat = isSeekInProgress ? seekTime : currentTime
        return dependencies.timeFormatter.formatTime(timeToFormat)
    }
    
    var formattedDuration: String {
        dependencies.timeFormatter.formatTime(duration)
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        let timeToUse = isSeekInProgress ? seekTime : currentTime
        return timeToUse / duration
    }
    
    var sliderValue: TimeInterval {
        get {
            isSeekInProgress ? seekTime : currentTime
        }
        
        set {
            if !isSeekInProgress {
                startSeeking()
            }
            
            seekTime = newValue
        }
    }
    
    // MARK: - Private properties
    
    private let dependencies: MusicPlayerDependencies
    private var player: AudioPlayerProtocol?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    private var isCurrentIndexLast: Bool {
        currentActiveIndex == currentPlaylist.count - 1
    }
    
    private var isCurrentIndexFirst: Bool {
        currentActiveIndex == 0
    }
    
    private var currentPlaylist: [Song] {
        isShuffleOn ? shuffledPlaylist : playlist
    }
    
    private var currentActiveIndex: Int {
        isShuffleOn ? currentShuffledIndex : currentIndex
    }
    
    // MARK: - Initialization
    
    init(dependencies: MusicPlayerDependencies = .default) {
        self.dependencies = dependencies
        setupAudioSession()
    }
    
    // MARK: - Public methods
    
    func play(song: Song, songList: [Song]) {
        guard let index = songList.firstIndex(where: { $0.trackId == song.trackId }),
              !songList.isEmpty, index < songList.count else {
            playerError = "Failed to find song in playlist"
            return
        }
        
        let validSongs = songList.filter { $0.previewUrl != nil }
        
        playlist = validSongs
        currentIndex = index
        currentSong = songList[index]
        
        loadAndPlayCurrentSong()
    }
    
    func nextSong() {
        guard hasNextSong else { return }
        
        if isShuffleOn {
            navigateShuffledNext()
        } else {
            navigateRegularNext()
        }
        
        updateCurrentSongAndPlay()
    }
    
    func previousSong() {
        guard hasPreviousSong else { return }
        
        if isShuffleOn {
            navigateShuffledPrevious()
        } else {
            navigateRegularPrevious()
        }
        
        updateCurrentSongAndPlay()
    }
    
    func toggleShuffle() {
        isShuffleOn.toggle()
        
        if isShuffleOn {
            enableShuffle()
        } else {
            disableShuffle()
        }
    }
    
    func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero) { _ in }
        currentTime = 0
        isPlaying = false
    }
    
    func finishSeeking(completionHandler: @escaping @Sendable (Bool) -> Void) {
        guard isSeekInProgress else { return }
        
        let cmTime = CMTime(seconds: seekTime, preferredTimescale: 600)
        player?.seek(to: cmTime) { [weak self] completed in
            Task { @MainActor in
                guard let self = self else { return }
                if completed {
                    self.currentTime = self.seekTime
                    completionHandler(completed)
                }
                self.isSeekInProgress = false
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupAudioSession() {
        do {
            try dependencies.audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth]
            )
            try dependencies.audioSession.setActive(true, options: [])
        } catch {
            print("Failed to setup audio session: \(error)")
            playerError = "Audio session setup failed"
        }
    }
    
    private func navigateShuffledNext() {
        if isCurrentIndexLast && isRepeatOn {
            currentShuffledIndex = 0
        } else {
            currentShuffledIndex += 1
        }
    }
    
    private func navigateShuffledPrevious() {
        if isCurrentIndexFirst && isRepeatOn {
            currentShuffledIndex = shuffledPlaylist.count - 1
        } else {
            currentShuffledIndex -= 1
        }
    }
    
    private func navigateRegularNext() {
        if isCurrentIndexLast && isRepeatOn {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
    }
    
    private func navigateRegularPrevious() {
        if isCurrentIndexFirst && isRepeatOn {
            currentIndex = playlist.count - 1
        } else {
            currentIndex -= 1
        }
    }
    
    private func updateCurrentSongAndPlay() {
        currentSong = currentPlaylist[isShuffleOn ? currentShuffledIndex : currentIndex]
        loadAndPlayCurrentSong()
    }
    
    private func loadAndPlayCurrentSong() {
        guard let song = currentSong,
              let previewUrl = song.previewUrl,
              let url = URL(string: previewUrl) else {
            playerError = "Invalid preview URL"
            stop()
            return
        }
        
        cleanup()
        
        isLoading = true
        playerError = nil
        
        playerItem = AVPlayerItem(url: url)
        player = dependencies.audioPlayer
        player?.replaceCurrentItem(with: playerItem)
        
        observePlayerItem()
        
        player?.play()
        isPlaying = true
    }
    
    private func enableShuffle() {
        guard let currentSong = self.currentSong else {
            shuffledPlaylist = playlist.shuffled()
            currentShuffledIndex = 0
            return
        }
        
        var remainingSongs = playlist.filter { $0.trackId != currentSong.trackId }
        remainingSongs.shuffle()
        
        shuffledPlaylist = [currentSong] + remainingSongs
        currentShuffledIndex = 0
    }
    
    private func disableShuffle() {
        guard let currentSong = self.currentSong else {
            shuffledPlaylist = []
            currentIndex = 0
            return
        }
        
        if let originalIndex = playlist.firstIndex(where: { $0.trackId == currentSong.trackId }) {
            currentIndex = originalIndex
        } else {
            currentIndex = 0
        }
        
        shuffledPlaylist = []
        currentShuffledIndex = 0
    }
    
    private func startSeeking() {
        isSeekInProgress = true
        seekTime = currentTime
    }
    
    private func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime) { _ in }
        currentTime = time
    }
    
    private func observePlayerItem() {
        guard let playerItem = playerItem else { return }
        
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                switch status {
                    case .readyToPlay:
                        self?.handleReadyToPlay()
                    case .failed:
                        self?.handlePlayerError(playerItem.error)
                    case .unknown:
                        break
                    @unknown default:
                        break
                }
            }
            .store(in: &cancellables)
        
        playerItem.publisher(for: \.duration)
            .sink { [weak self] duration in
                if duration.isValid && !duration.isIndefinite {
                    self?.duration = duration.seconds
                }
            }
            .store(in: &cancellables)
        
        dependencies.notificationCenter.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.handleSongEnded()
            }
            .store(in: &cancellables)
        
        setupTimeObserver()
    }
    
    private func handleReadyToPlay() {
        isLoading = false
        
        if let playerItem = playerItem {
            let itemDuration = playerItem.duration
            if itemDuration.isValid && !itemDuration.isIndefinite {
                duration = itemDuration.seconds
            }
        }
        
        extractBasicInfo()
    }
    
    private func extractBasicInfo() {
        guard let asset = playerItem?.asset else { return }
        
        Task {
            do {
                let duration = try await asset.load(.duration)
                if duration.isValid && !duration.isIndefinite {
                    self.duration = duration.seconds
                }
            } catch let error {
                print("Failed to load asset duration: \(error.localizedDescription)")
            }
        }
    }
    
    private func handlePlayerError(_ error: Error?) {
        isLoading = false
        isPlaying = false
        playerError = error?.localizedDescription ?? "Unknown player error"
        print("Player error: \(playerError ?? "")")
    }
    
    private func handleSongEnded() {
        isPlaying = false
        currentTime = 0
        
        if hasNextSong {
            nextSong()
        } else {
            stop()
        }
    }
    
    private func setupTimeObserver() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                guard let self = self else { return }
                if time.isValid && !time.isIndefinite && !self.isSeekInProgress {
                    self.currentTime = time.seconds
                }
            }
        }
    }
    
    private func cleanup() {
        
        isSeekInProgress = false
        seekTime = 0
        
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        cancellables.removeAll()
        
        player?.pause()
        player = nil
        playerItem = nil
        
        currentTime = 0
        duration = 0
        isLoading = false
    }
}
