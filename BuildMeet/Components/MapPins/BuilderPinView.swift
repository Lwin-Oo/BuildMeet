//
//  BuilderPinView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI

struct BuilderPinView: View {
    let builder: BuilderPin

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(builder.statusColor)
                .frame(width: 18, height: 18)
                .shadow(
                    color: builder.isUrgent ? .red.opacity(0.7) : .clear,
                    radius: builder.isUrgent ? 10 : 0
                )

            Image(systemName: "hammer.fill")
                .foregroundColor(.white)
                .padding(8)
                .background(builder.statusColor)
                .clipShape(Circle())
        }
    }
}

