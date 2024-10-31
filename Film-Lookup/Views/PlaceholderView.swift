//
//  PlaceholderView.swift
//  Film-Lookup
//
//  Created by Aurnab Das on 11/1/24.
//

import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray4))
            Text("Placeholder for movie list")
                .foregroundColor(.white)
        }
    }
}

#Preview {
    PlaceholderView()
}
