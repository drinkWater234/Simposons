//
//  NetworkManager.swift
//  CharacterViewerApp
//
//  Created by William on 6/13/23.
//

import Foundation
import Combine

enum CustomError: Error {
    case badRequest
    case invalidURL
    case invalidStatusCode(Int)
    case decodeError(DecodingError)
    case unknownError
}

protocol NetworkManagerType {
    func getCharacters<T: Decodable>() async throws -> T
}

class NetworkManager: NetworkManagerType {
    
    let session: URLSession
    let decoder: JSONDecoder
    
    init(session: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func getCharacters<T>() async throws -> T where T: Decodable {
       
        var request: URLRequest?
#if SIMPSON
        let urlStr = "http://api.duckduckgo.com?q=simpsons+characters&format=json"
        guard let url = URL(string: urlStr) else { throw CustomError.invalidURL }
        request = URLRequest(url: url)
#elseif WIRE
        let urlStr = "http://api.duckduckgo.com?q=the+wire+characters&format=json"
        guard let url = URL(string: urlStr) else { throw CustomError.invalidURL }
        request = URLRequest(url: url)
#endif
        guard let request = request else { throw CustomError.unknownError }
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw CustomError.invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch let decodeError as DecodingError {
            throw CustomError.decodeError(decodeError)
        } catch {
            throw CustomError.unknownError
        }
    }
}
