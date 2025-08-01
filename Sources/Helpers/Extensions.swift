//
//  Extensions.swift
//  MusicPlayer
//
//  Created by Marco Braga on 31/07/25.
//

import Foundation
import AVFoundation

extension String {
    func itunesLargeImageURL() -> String {
        let pattern = #"\d+x\d+bb\.jpg"#
        let replacement = "400x400bb.jpg"
        return self.replacingOccurrences(
            of: pattern,
            with: replacement,
            options: .regularExpression
        )
    }
}

extension AVPlayer: AudioPlayerProtocol {}

extension AVAudioSession: AudioSessionProtocol {}

extension NotificationCenter: NotificationCenterProtocol {}

extension Song {
    static let mockSong = Song(trackId: 528437613,
                               collectionId: 528436018,
                               artistName: "LINKIN PARK",
                               trackName: "In the End",
                               artworkUrl60: "https://is1-ssl.mzstatic.com/image/thumb/Features115/v4/f0/31/b2/f031b2b2-bcf0-6102-426f-e0b2c7437415/dj.vrgpwamf.jpg/60x60bb.jpg",
                               artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Features115/v4/f0/31/b2/f031b2b2-bcf0-6102-426f-e0b2c7437415/dj.vrgpwamf.jpg/100x100bb.jpg",
                               previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/6c/60/cf/6c60cf91-e098-84bc-79af-8f3615b57b19/mzaf_12714078272888357351.plus.aac.p.m4a",
                               collectionName: "Hybrid Theory",
                               trackNumber: 8)

    static let mockSongs: [Song] = [
        Song(trackId: 185731686,
             collectionId: 185731554,
             artistName: "JAY-Z & LINKIN PARK",
             trackName: "Numb / Encore",
             artworkUrl60: "https://is1-ssl.mzstatic.com/image/thumb/Music71/v4/17/9f/fa/179ffa90-74cd-0afa-2c6e-5c166b7cd1c3/dj.vnurtdjw.jpg/60x60bb.jpg",
             artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music71/v4/17/9f/fa/179ffa90-74cd-0afa-2c6e-5c166b7cd1c3/dj.vnurtdjw.jpg/100x100bb.jpg",
             previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/ed/c5/2c/edc52c92-d0bd-d9ea-e1b2-25b89c90e3ac/mzaf_2299253512947720106.plus.aac.p.m4a",
             collectionName: "Collision Course (Bonus Video Version) - EP",
             trackNumber: 4),
        mockSong,
        Song(trackId: 518869937,
             collectionId: 518869932,
             artistName: "LINKIN PARK",
             trackName: "BURN IT DOWN",
             artworkUrl60: "https://is1-ssl.mzstatic.com/image/thumb/Features115/v4/ae/96/55/ae965544-a29d-5355-910a-1cc14dab7542/contsched.ltemslzy.jpg/60x60bb.jpg",
             artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Features115/v4/ae/96/55/ae965544-a29d-5355-910a-1cc14dab7542/contsched.ltemslzy.jpg/100x100bb.jpg",
             previewUrl: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/03/bd/20/03bd20e8-d59b-6aa1-8206-a543a669e3a6/mzaf_7293207381877726208.plus.aac.p.m4a",
             collectionName: "LIVING THINGS",
             trackNumber: 3)
    ]
}

extension Album {
    static let mockAlbum = Album(collectionId: 528436018,
                                 collectionName: "Hybrid Theory",
                                 artistName: "LINKIN PARK",
                                 artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Features115/v4/f0/31/b2/f031b2b2-bcf0-6102-426f-e0b2c7437415/dj.vrgpwamf.jpg/100x100bb.jpg")
}
