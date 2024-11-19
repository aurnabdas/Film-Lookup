import SwiftUI

struct ContentView: View {
    @State private var nowPlayingPosterPaths: [String] = []
    @State private var UpcomingPosterPaths: [String] = []
    @State private var isLoadingNowPlaying = true
    @State private var isLoadingPopular = true

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    NavigationLink(destination: MovieDetailView()) {
                        Image(systemName: "film")
                    }
                    .padding()

                    NavigationLink(destination: MovieRecommendationView()) {
                        Image(systemName: "star")
                    }
                    .padding()
                }

                Spacer()

                // Now Playing Section
                Text("Now Playing")
                    .font(.headline)
                    .padding()

                VStack {
                    if isLoadingNowPlaying {
                        ProgressView("Loading Now Playing Movies").padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(nowPlayingPosterPaths, id: \.self) { posterPath in
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 200)
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            .padding()
                            .onAppear {
                                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                                    // Add animation if needed
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        do {
                            nowPlayingPosterPaths = try await fetchNowPlayingPosters()
                            isLoadingNowPlaying = false
                        } catch {
                            print("Failed to load now playing posters: \(error)")
                            isLoadingNowPlaying = false
                        }
                    }
                }

                // Popular Movies Section
                Text(" Movies")
                    .font(.headline)
                    .padding()

                VStack {
                    if isLoadingPopular {
                        ProgressView("Loading Popular Movies").padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(UpcomingPosterPaths, id: \.self) { posterPath in
                                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 200)
                                            .cornerRadius(8)
                                            .shadow(radius: 4)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                            .padding()
                            .onAppear {
                                withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                                    // Add animation if needed
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    Task {
                        do {
                            UpcomingPosterPaths = try await fetchUpcomingPosters()
                            isLoadingPopular = false
                        } catch {
                            print("Failed to load popular posters: \(error)")
                            isLoadingPopular = false
                        }
                    }
                }

                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
}
