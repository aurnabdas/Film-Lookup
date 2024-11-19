import SwiftUI
import Charts // Import Charts framework
import GoogleGenerativeAI

struct MovieRecommendationView: View {

    struct AIResponse: Decodable {

        let worstDomestic: String
        let worstWorldwide: String
        let worstTogether: String

        let neutralDomestic: String
        let neutralWorldwide: String
        let neutralTogether: String

        let bestDomestic: String
        let bestWorldwide: String
        let bestTogether: String

        // Computed properties to convert strings to integers
        var worstDomesticInt: Int? { Int(worstDomestic) }
        var worstWorldwideInt: Int? { Int(worstWorldwide) }
        var worstTogetherInt: Int? { Int(worstTogether) }

        var neutralDomesticInt: Int? { Int(neutralDomestic) }
        var neutralWorldwideInt: Int? { Int(neutralWorldwide) }
        var neutralTogetherInt: Int? { Int(neutralTogether) }

        var bestDomesticInt: Int? { Int(bestDomestic) }
        var bestWorldwideInt: Int? { Int(bestWorldwide) }
        var bestTogetherInt: Int? { Int(bestTogether) }
    }

    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let category: String
        let value: Int
        let scenario: String
    }

    @State var textinput = ""
    @State private var airesponse: AIResponse?

    let generationConfig = GenerationConfig(responseMIMEType: "application/json")

    let generativeModel = GenerativeModel(
        name: "gemini-1.5-flash",
        apiKey: APIKey.default,
        generationConfig: GenerationConfig(responseMIMEType: "application/json")
    )

    var body: some View {

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Input field and search button
                HStack {
                    TextField("Enter a Film That Has Not Come Out", text: $textinput)
                        .textFieldStyle(.roundedBorder)
                    Button(action: querySearch) {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .foregroundColor(.blue)
                .padding()

                // Display Chart and Responses
                if let response = airesponse {
                    VStack {
                        Chart(generateChartData(from: response)) { data in
                            LineMark(
                                x: .value("Category", data.category),
                                y: .value("Value", data.value),
                                series: .value("Scenario", data.scenario)
                            )
                            .foregroundStyle(by: .value("Scenario", data.scenario))
//                            .symbol(by: .value("Scenario", data.scenario))
                        }
//https://stackoverflow.com/questions/74909944/how-to-customize-the-y-axis-values-in-swift-charts
                        .chartYAxis() {
                           AxisMarks(position: .leading) {
                               let value = $0.as(Int.self)!
                               AxisValueLabel {
                                   Text("\(value)")
                               }
                           }
                        }                    .frame(height: 250)
                        .padding()

//                        Table(generateChartData(from: response)) {
//                                TableColumn("Scenario", value: \.scenario)
//                                TableColumn("Category", value: \.category)
//                                TableColumn("Value") { dataPoint in
//                                    Text("\(dataPoint.value)") // Format the value as needed
//                                }
//                            }
//                            .frame(minWidth: 600, maxHeight: 300)
//                            .padding()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Worst Case:")
                                .font(.headline)
                            Text("Domestic: \(response.worstDomestic)")
                            Text("Worldwide: \(response.worstWorldwide)")
                            Text("Together: \(response.worstTogether)")

                            Text("Neutral Case:")
                                .font(.headline)
                            Text("Domestic: \(response.neutralDomestic)")
                            Text("Worldwide: \(response.neutralWorldwide)")
                            Text("Together: \(response.neutralTogether)")

                            Text("Best Case:")
                                .font(.headline)
                            Text("Domestic: \(response.bestDomestic)")
                            Text("Worldwide: \(response.bestWorldwide)")
                            Text("Together: \(response.bestTogether)")
                        }


                    }
                }

                Spacer()
            }
            .navigationTitle("Recommendation")
        }
    }

    func querySearch() {
        airesponse = nil
        Task {
            let jsonString = """
            {
                "worstDomestic": "150000000",
                "worstWorldwide": "400000000",
                "worstTogether": "550000000",
                "neutralDomestic": "250000000",
                "neutralWorldwide": "650000000",
                "neutralTogether": "900000000",
                "bestDomestic": "350000000",
                "bestWorldwide": "900000000",
                "bestTogether": "1250000000"
            }
            """
            let prompt = """
            I give you a movie that is coming out in the future. Can you tell me how much it will make in three scenarios: the best outcome, a neutral outcome, and a bad outcome for that film?

            This is the name of the movie: \(textinput)

            Ensure the output format matches this example:
            \(jsonString)
            """
            do {
                let response = try await generativeModel.generateContent(prompt)
                if let text = response.text, let jsonData = text.data(using: .utf8) {
                    airesponse = try JSONDecoder().decode(AIResponse.self, from: jsonData)
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }

    func generateChartData(from response: AIResponse) -> [ChartDataPoint] {
        [
            ChartDataPoint(category: "Domestic", value: response.worstDomesticInt ?? 0, scenario: "Worst"),
            ChartDataPoint(category: "Worldwide", value: response.worstWorldwideInt ?? 0, scenario: "Worst"),
            ChartDataPoint(category: "Together", value: response.worstTogetherInt ?? 0, scenario: "Worst"),
            ChartDataPoint(category: "Domestic", value: response.neutralDomesticInt ?? 0, scenario: "Neutral"),
            ChartDataPoint(category: "Worldwide", value: response.neutralWorldwideInt ?? 0, scenario: "Neutral"),
            ChartDataPoint(category: "Together", value: response.neutralTogetherInt ?? 0, scenario: "Neutral"),
            ChartDataPoint(category: "Domestic", value: response.bestDomesticInt ?? 0, scenario: "Best"),
            ChartDataPoint(category: "Worldwide", value: response.bestWorldwideInt ?? 0, scenario: "Best"),
            ChartDataPoint(category: "Together", value: response.bestTogetherInt ?? 0, scenario: "Best")
        ]
    }
}

#Preview {
    MovieRecommendationView()
}
