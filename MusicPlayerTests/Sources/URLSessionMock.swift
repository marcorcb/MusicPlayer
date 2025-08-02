//
//  URLSessionMock.swift
//  MusicPlayerTests
//
//  Created by Marco Braga on 01/08/25.
//

import Foundation
@testable import MusicPlayer

final class URLSessionMock: URLSessionProtocol {
    
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    var requestedURL: URL?
    var requestCount: Int = 0
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestedURL = url
        requestCount += 1
        
        if let error = mockError {
            throw error
        }
        
        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data, response)
    }
    
    func setSuccess(data: Data, statusCode: Int = 200) {
        mockData = data
        mockError = nil
        mockResponse = HTTPURLResponse(
            url: URL(string: "https://itunes.apple.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }
    
    func setError(_ error: Error) {
        mockError = error
        mockData = nil
        mockResponse = nil
    }
    
    func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
        requestedURL = nil
        requestCount = 0
    }
}
