//
//  ToolboxView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/28/25.
//


import SwiftUI

struct ToolboxView: View {
    @Binding var isToolboxOpen: Bool
    @ObservedObject var dragVM: DragAndDropPinViewModel
    @ObservedObject var viewModel: MapViewModel
    
    var body: some View {
        VStack(spacing: 16) {

            ToolboxButton(
                icon: "mappin.and.ellipse",
                label: "Event",
                color: .red,
                onDragStart: {
                    dragVM.isDragging = true
                    dragVM.showFloatingPin = true

                    NotificationCenter.default.post(name: .enterDropMode, object: nil)

                },
                onDragMove: { point in
                    dragVM.dragPosition = point
                },
                onDragEnd: { point in
                    dragVM.showFloatingPin = false
                    dragVM.isDragging = false

                    // 🔥 Exit drop mode
                    NotificationCenter.default.post(name: .exitDropMode, object: nil)

                    let coord = GlobeMapCoordinateConverter.shared.convert(point: point)
                    print("🔥 Drag End Fired at coord:", coord)

                    if viewModel.isWithinAllowedRadius(drop: coord) {
                        NotificationCenter.default.post(
                            name: .eventPinDropped,
                            object: nil,
                            userInfo: ["coordinate": coord]
                        )
                    } else {
                        NotificationCenter.default.post(
                            name: .eventPinDropRejected,
                            object: nil,
                            userInfo: ["reason": "too_far"]
                        )
                    }
                }

            )
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
    }
}
