//
//  NavigationService.swift
//  MusicPlayer
//
//  Created by Marco Braga on 30/07/25.
//

import Foundation

protocol NavigationServiceProtocol {
    func navigateToAlbum(_ song: Song)
}

@Observable
class NavigationService: NavigationServiceProtocol {
    var shouldNavigateToAlbum: Song? = nil

    func navigateToAlbum(_ song: Song) {
        shouldNavigateToAlbum = song
    }
}
