//
//  ExtensionsTests.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 02/08/25.
//

import Testing

struct ExtensionsTests {
    @Test("iTunes large image URL replaces 100x100 size")
    func test_itunesLargeImageURL_replaces100x100Size() {
        let originalURL = "https://is1-ssl.mzstatic.com/image/thumb/Music71/v4/17/9f/fa/179ffa90-74cd-0afa-2c6e-5c166b7cd1c3/dj.vnurtdjw.jpg/100x100bb.jpg"
        let expectedURL = "https://is1-ssl.mzstatic.com/image/thumb/Music71/v4/17/9f/fa/179ffa90-74cd-0afa-2c6e-5c166b7cd1c3/dj.vnurtdjw.jpg/400x400bb.jpg"

        let result = originalURL.itunesLargeImageURL()

        #expect(result == expectedURL)
    }

    @Test("iTunes large image URL handles special characters in path")
    func test_itunesLargeImageURL_handlesSpecialCharactersInPath() {
        let originalURL = "https://example.com/ã-ü-path/100x100bb.jpg"
        let expectedURL = "https://example.com/ã-ü-path/400x400bb.jpg"

        let result = originalURL.itunesLargeImageURL()

        #expect(result == expectedURL)
    }
}
