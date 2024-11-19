import SwiftUI
import GoogleGenerativeAI

struct MovieDetailView: View {
    @State private var movieName: String = ""
    @State private var movieDetails: Movie?
    @State private var omdbDetail: OMDBDetails?
    @State private var showDetails: Bool = false
    @State private var errorMessage: String?
    let availablePlatforms = ["Netflix", "Prime Video", "HBO Max"] // Placeholder platforms
//    @State private var availablePlatforms: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField("Enter Film Name", text: $movieName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Button(action: {
                        Task {
                            if !movieName.isEmpty {
                                do {
//                                    movieDetails = try await fetchMovieData(query: movieName)
                                    async let omdbResult = fetchFromOMDBApi(query: movieName)
                                    omdbDetail = try await omdbResult


//                                    async let sourcesResult = fetchMovieSources(query: movieName)
//                                    let sources = try await sourcesResult
//                                    availablePlatforms = extractSourceNames(from: sources)

                                    showDetails = omdbDetail != nil
                                    

                                    errorMessage = omdbDetail == nil ? "No movie found" : nil

                                } catch {
                                    errorMessage = "Error fetching movie data: \(error.localizedDescription)"
                                }
                            }

                        }
                    }) {
                        Text("Enter")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing)


                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                if showDetails, let omdbDetail = omdbDetail {
                    HStack {
                        
                        VStack{
                            // The List and Navigation chapter 22
                            if let posterPath = omdbDetail.Poster {
                                AsyncImage(url: URL(string: posterPath)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 200)
                                        .padding()
                                } placeholder: {
                                    ProgressView() // this shows a loading screen Chapter 24 Pg 683
                                }
                            } else {
                                Image(systemName: "film.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 100)
                                    .padding()
                            }
                        }

                        
                        // this VStack had other boiler plate infromation that i will try to get from another api
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Name: \(omdbDetail.Title ?? "N/A")")
                                .font(.headline)

                            Text("Release Date: \(omdbDetail.Released ?? "N/A")")
                                .font(.caption)
                            
                            Text("Rated: \(omdbDetail.Rated ?? "N/A")")
                                .font(.caption)
                            
                            Text("Runtime: \(omdbDetail.Runtime ?? "N/A")")
                                .font(.caption)

                            Text("Director: \(omdbDetail.Director ?? "N/A")")
                                .font(.caption)



                            Text("Actors: \(omdbDetail.Actors ?? "N/A")")
                            .font(.caption)



                        }


                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overview: \(omdbDetail.Plot ?? "No description available.")")
                            .font(.caption)

                        Text("Writer: \(omdbDetail.Writer ?? "N/A")")
                            .font(.caption)



                        Text("BoxOffice: \(omdbDetail.BoxOffice ?? "N/A")")
                            .font(.caption)

                        Text("Metascore: \(omdbDetail.Metascore ?? "N/A")/100")
                            .font(.caption)

                        Text("imdbRating: \(omdbDetail.imdbRating ?? "N/A")/10")
                            .font(.caption)
                    }
                    .padding()





                    Text("Currently Being Available On")
                        .font(.headline)
                        .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                        ForEach(availablePlatforms, id: \.self) { platform in
                            CustomPlatformView(name: platform)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Movie Detail")
        }
    }
}

#Preview {
    MovieDetailView()
}
