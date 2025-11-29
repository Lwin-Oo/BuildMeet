//
//  ToolboxButton.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/28/25.
//

import SwiftUI

struct ToolboxButton: View {
    let icon: String
    let label: String
    let color: Color

    let onDragStart: () -> Void
    let onDragMove: (CGPoint) -> Void
    let onDragEnd: (CGPoint) -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .padding(12)
                .background(color)
                .clipShape(Circle())

            Text(label)
                .font(.caption)
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged { value in
                    onDragStart()
                    onDragMove(value.location)
                }
                .onEnded { value in
                    onDragEnd(value.location)
                }
        )
    }
}


