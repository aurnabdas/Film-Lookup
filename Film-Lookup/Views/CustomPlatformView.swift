//
//  CustomPlatformView.swift
//  Film-Lookup
//
//  Created by Aurnab Das on 11/1/24.
//

import SwiftUI

struct CustomPlatformView: View {
    let name: String

    var body: some View {
        VStack {
            Image(systemName: "tv")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            Text(name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(width: 100, height: 120)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    CustomPlatformView(name: "Netflix")
}
