//
//  OMDBA-Api.swift
//  Film-Lookup
//
//  Created by Aurnab Das on 11/10/24.
//

import Foundation

struct OMDBDetails: Decodable{
    let Title: String?
    let Year: String?
    let Rated: String?
    let Released: String?
    let Runtime: String?
    let Director: String?
    let Writer: String?
    let Actors: String?
    let Plot: String?
    let Poster: String?
    let BoxOffice: String?
    let Metascore: String?
    let imdbRating: String?
}


func getOMDBKey() -> String? {
    guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist"),
          let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: Any] else {
        print("Error: Could not find APIKeys.plist")
        return nil
    }
    return dictionary["OMDB_KEY"] as? String
}



func fetchFromOMDBApi(query: String) async throws -> OMDBDetails {

    guard let omdbKey = getOMDBKey() else {
            throw NSError(domain: "APIKeyError", code: 0, userInfo: [NSLocalizedDescriptionKey: "OMDB API key not found"])
        }

    let url = URL(string: "https://www.omdbapi.com/?t=\(query)&apikey=\(omdbKey)")!
    let(data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(OMDBDetails.self, from: data)
//    print(response.Actors)
    return response

}
