//
//  ContentView.swift
//  Add to Obsidian
//
//  Created by Thomas Schoffelen on 01/12/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image("Add to Obsidian")
                .resizable()
                .frame(width: 120, height: 120)
          
            VStack(spacing: 12) {
                Text("Add to Obsidian")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Use the Share button in other apps to quickly add links, articles, and music to your Obsidian vault.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                    Text("Tap the Share button in any app")
                        .font(.subheadline)
                }

                HStack {
                    Image(systemName: "note.text")
                        .foregroundColor(.blue)
                    Text("Select 'Add to Obsidian'")
                        .font(.subheadline)
                }

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Content added to your vault")
                        .font(.subheadline)
                }
            }
            .padding(24)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 32)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
