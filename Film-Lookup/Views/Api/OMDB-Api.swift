//
//  OMDBA-Api.swift
//  Film-Lookup
//
//  Created by Aurnab Das on 11/10/24.
//

import Foundation

struct OMDBDetails: Decodable{
    let Title: String
    let Year: String
    let Rated: String
    let Released: String 
    let Runtime: String
    let Director: String
    let Writer: String
    let Actors: String
    let Plot: String
    let Poster: String
    let BoxOffice: String
    let Metascore: String
    let imdbRating: String
}

let apiKey = "f92b7858"

func fetchFromOMDBApi(query: String) async throws -> OMDBDetails {
    let url = URL(string: "https://www.omdbapi.com/?t=\(query)&apikey=\(apiKey)")!
    let(data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(OMDBDetails.self, from: data)
//    print(response.Actors)
    return response

}
