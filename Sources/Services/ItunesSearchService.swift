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
    func searchSongs(term: String, offset: Int, limit: Int) async throws (Error) -> [Song]
    func fetchSongsFromAnAlbum(albumID: Int) async throws(any Error) -> AlbumData
}

final class ItunesSearchService: ItunesSearchServiceProtocol {

    // MARK: - Private properties

    private let urlScheme = "https"
    private let urlHost = "itunes.apple.com"
    private let urlSession: URLSession

    private enum paths: String {
        case search = "/search"
        case lookup = "/lookup"
    }

    // MARK: Initialization

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    // MARK: - Public methods

    func searchSongs(term: String, offset: Int, limit: Int) async throws (Error) -> [Song] {
        do {
            var components = URLComponents()
            components.scheme = urlScheme
            components.host = urlHost
            components.path = paths.search.rawValue
            components.queryItems = [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ]

            guard let url = components.url else {
                throw NetworkingError.urlMalformed
            }

            let (data, _) = try await urlSession.data(from: url)
            let response = try JSONDecoder().decode(SongSearchResponse.self, from: data)
            return response.results
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.otherError(innerError: error)
        }
    }

    func fetchSongsFromAnAlbum(albumID: Int) async throws(any Error) -> AlbumData {
        do {
            var components = URLComponents()
            components.scheme = urlScheme
            components.host = urlHost
            components.path = paths.lookup.rawValue
            components.queryItems = [
                URLQueryItem(name: "id", value: String(albumID)),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: "200")
            ]

            guard let url = components.url else {
                throw NetworkingError.urlMalformed
            }

            let (data, _) = try await urlSession.data(from: url)
            let response = try JSONDecoder().decode(AlbumLookupResponse.self, from: data)

            let albumCollection = response.results.compactMap { item in
                if case .collection(let collection) = item {
                    return collection
                }
                return nil
            }.first

            let tracks = response.results.compactMap { item in
                if case .track(let track) = item {
                    return track
                }
                return nil
            }

            guard let album = albumCollection else {
                 throw NetworkingError.otherError(innerError: NSError(
                     domain: "AlbumLookup",
                     code: 404,
                     userInfo: [NSLocalizedDescriptionKey: "Album collection not found"]
                 ))
             }

            return AlbumData(album: album, tracks: tracks)
        } catch let error as NetworkingError {
            throw error
        } catch {
            throw NetworkingError.otherError(innerError: error)
        }
    }
}
