//
//  MovieSearchAPI.swift
//  Film-Lookup
//
//  Created by Aurnab Das on 11/3/24.
//

import Foundation

//The sources include chapter 25, TMDB Api Documentation, https://www.youtube.com/watch?v=ERr0GXqILgc&t=357s (gave me a better understanding then the book, https://stackoverflow.com/questions/69804293/when-to-use-codingkeys-in-decodableswift (understanding codingkeys)

// Model for the movie data
struct Movie: Decodable {
    let posterPath: String?
    let releaseDate: String?
    let overview: String?

    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case overview
    }
}

// this was intially forgotten
struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
}


func getAPIKey() -> String? {
    guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
          let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: Any] else {
        print("Error: Could not find APIKeys.plist")
        return nil
    }
    return dictionary["TMDB_KEY"] as? String
}

// this is mostly taken by the API documentation of TMDB
func fetchMovieData(query: String) async throws -> Movie? {

    guard let tmdbKey = getAPIKey() else {
            throw NSError(domain: "APIKeyError", code: 0, userInfo: [NSLocalizedDescriptionKey: "TMDB API key not found"])
        }



    let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing")!
    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
    let queryItems: [URLQueryItem] = [
        URLQueryItem(name: "query", value: query),
        URLQueryItem(name: "include_adult", value: "false"),
        URLQueryItem(name: "language", value: "en-US"),
        URLQueryItem(name: "page", value: "1"),
    ]
    components.queryItems = queryItems


    var request = URLRequest(url: components.url!)
    request.httpMethod = "GET"
    request.timeoutInterval = 10
    request.allHTTPHeaderFields = [
        "accept": "application/json",
        "Authorization": "Bearer \(tmdbKey)"
    ]

    let (data, _) = try await URLSession.shared.data(for: request)

    // this is just for me to see the response
//    print(String(decoding: data, as: UTF8.self))

    // this is to
    let response = try JSONDecoder().decode(MovieResponse.self, from: data)

    // Return the first movie in the results array, if it exists
    return response.results.first
}

