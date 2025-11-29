//
//  BuilderBottomSheet.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI

struct BuilderBottomSheet: View {
    let builder: BuilderPin
    @Binding var isPresented: BuilderPin?

    var body: some View {
        VStack(spacing: 16) {

            // Grab handle
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            // NAME (UPDATED)
            Text(builder.fullName)
                .font(.title2.bold())

            Text(builder.project)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "bolt.circle")
                Text(builder.status)
                    .bold()
            }
            .padding(.top, 4)

            Button("Meet in Person") {
                print("Meeting…")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.cornerRadius(12))
            .foregroundColor(.white)
            .padding(.top, 10)

            Button("Close") {
                withAnimation {
                    isPresented = nil
                }
            }
            .foregroundColor(.red)

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

