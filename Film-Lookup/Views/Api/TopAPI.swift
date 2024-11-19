//
//  TopAPI.swift
//  Film-Lookup
//
//  Created by Aurnab Das on 11/10/24.
//

import Foundation

//
//  NowPlayingAPI.swift
//  Film-Lookup
//
//  Created by Aurnab Das on 11/10/24.
//

import Foundation


struct UpcomingMovie: Decodable {
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
    }
}


struct UpcomingResponse: Decodable {
    let results: [NowPlayingMovie]
}

func fetchUpcomingPosters() async throws -> [String] {

    guard let nowTopKey = getAPIKey() else {
            throw NSError(domain: "APIKeyError", code: 0, userInfo: [NSLocalizedDescriptionKey: "TMDB API key not found"])
        }

    let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming")!
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    let queryItems: [URLQueryItem] = [
        URLQueryItem(name: "language", value: "en-US"),
        URLQueryItem(name: "page", value: "1"),
    ]
    components.queryItems = queryItems

    var request = URLRequest(url: components.url!)
    request.httpMethod = "GET"
    request.timeoutInterval = 10
    request.allHTTPHeaderFields = [
        "accept": "application/json",
        "Authorization": "Bearer \(nowTopKey)"
    ]

    let (data, _) = try await URLSession.shared.data(for: request)


    let response = try JSONDecoder().decode(NowPlayingResponse.self, from: data)

    // first 10 posters are taken
    return response.results.prefix(10).compactMap { $0.posterPath }
}



