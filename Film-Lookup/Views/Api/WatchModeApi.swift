import Foundation

// Model for movie details
struct WatchDetails: Decodable {
    let id: Int
    let name: String
    let type: String
    let year: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case year
    }
}

// Model for the response containing movies
struct WatchResponse: Decodable {
    let titleResults: [WatchDetails]

    enum CodingKeys: String, CodingKey {
        case titleResults = "title_results"
    }
}

// Model for source details
struct WatchSource: Decodable {
    let name: String
    let region: String
    let iosURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case region
        case iosURL = "ios_url"
    }
}

// Fetch the WatchMode API key from the plist file
func getWatchModeKey() -> String? {
    guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
          let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: Any],
          let apiKey = dictionary["Watch_KEY"] as? String else {
        print("Error: Could not retrieve WatchMode API key.")
        return nil
    }
    return apiKey
}

// Fetch a movie ID from WatchMode by query
func fetchMovieID(query: String) async throws -> Int? {
    guard let watchKey = getWatchModeKey() else {
        throw NSError(domain: "APIKeyError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Watch API key not found"])
    }

    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
    let urlString = "https://api.watchmode.com/v1/search/?apiKey=\(watchKey)&search_field=name&search_value=\(encodedQuery)&types=movie"
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "URLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(WatchResponse.self, from: data)

    // Print the movie results for debugging
    print("Movie results for query '\(query)': \(response.titleResults)")

    // Filter for exact name match
    if let movieID = response.titleResults.first(where: { $0.name == query })?.id {
        print("Found movie ID: \(movieID)")
        return movieID
    } else {
        print("No exact match found for query '\(query)'")
        return nil
    }
}


func fetchMovieSources(query: String) async throws -> [WatchSource] {
    // Step 1: Fetch the movie ID
    guard let movieID = try await fetchMovieID(query: query) else {
        throw NSError(domain: "MovieIDError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No exact match found for the query."])
    }

    // Step 2: Fetch sources for the movie ID
    guard let watchKey = getWatchModeKey() else {
        throw NSError(domain: "APIKeyError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Watch API key not found"])
    }

    let urlString = "https://api.watchmode.com/v1/title/\(movieID)/sources/?apiKey=\(watchKey)"
    guard let url = URL(string: urlString) else {
        throw NSError(domain: "URLError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    let sources = try JSONDecoder().decode([WatchSource].self, from: data)

    // Print the sources for debugging
    print("Streaming sources for movie ID \(movieID): \(sources)")

    return sources
}


func extractSourceNames(from sources: [WatchSource]) -> [String] {
    let sourceNames = sources
        .filter { $0.region == "US" } // Only include sources where the region is "US"
        .map { $0.name } // Extract the name of the source
    print("Extracted source names (US only): \(sourceNames)")
    return sourceNames
}

