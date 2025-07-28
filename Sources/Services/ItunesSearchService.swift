//
//  ItunesSearchService.swift
//  MusicPlayer
//
//  Created by Marco Braga on 27/07/25.
//

import Foundation

enum NetworkingError: Error {
    case urlMalformed
    case otherError(innerError: Error)
}

protocol ItunesSearchServiceProtocol: AnyObject {
    func fetchSongs(term: String) async throws (Error) -> [Music]
}

final class ItunesSearchService: ItunesSearchServiceProtocol {

    // MARK: - Private Properties

    private let urlScheme = "https"
    private let urlHost = "itunes.apple.com"
    private let urlPath = "/search"
    private let urlSession: URLSession

    // MARK: Initialization

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    // MARK: - Public Methods

    func fetchSongs(term: String) async throws(any Error) -> [Music] {
        do {
            var components = URLComponents()
                components.scheme = urlScheme
                components.host = urlHost
                components.path = urlPath
                components.queryItems = [
                    URLQueryItem(name: "term", value: term),
                    URLQueryItem(name: "media", value: "music"),
                ]

            guard let url = components.url else {
                throw NetworkingError.urlMalformed
            }

            let (data, _) = try await urlSession.data(from: url)

            let musicResponse = try JSONDecoder().decode(MusicResponse.self, from: data)
            return musicResponse.results
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.otherError(innerError: error)
        }
    }
}
