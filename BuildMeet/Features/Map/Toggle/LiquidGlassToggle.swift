//
//  LiquidGlassToggle.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/28/25.
//

import SwiftUI

struct LiquidGlassToggle: View {
    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        HStack(spacing: 0) {

            ToggleButton(
                label: "People",
                isOn: viewModel.showPeople,
                action: {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.showPeople = true
                    }
                }
            )

            ToggleButton(
                label: "Events",
                isOn: !viewModel.showPeople,
                action: {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.showPeople = false
                    }
                }
            )
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .cornerRadius(22)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
        )
    }
}
