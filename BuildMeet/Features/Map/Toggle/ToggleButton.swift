//
//  ToggleButton.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/28/25.
//

import SwiftUI

struct ToggleButton: View {
    let label: String
    let isOn: Bool
    let action: () -> Void

    @Namespace private var toggleNamespace

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(
                    ZStack {
                        if isOn {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.85))
                                .matchedGeometryEffect(id: "toggle", in: toggleNamespace)
                                .shadow(radius: 3)
                        }
                    }
                )
                .foregroundColor(isOn ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}
