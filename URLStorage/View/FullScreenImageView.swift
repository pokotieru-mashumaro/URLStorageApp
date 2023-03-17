//
//  FullScreenImageView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/12.
//

import SwiftUI

struct FullScreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var item: GroupItem?
    
    @State private var scale = 1.0
    @State private var lastScale = 1.0
    
    @State private var magnifying = 1.0
    @State private var currentScale = 1.0
    
    @State private var position: CGPoint = .zero
    @State private var dragging: CGSize = .zero
    
    private let minScale = 1.0
    private let maxScale = 5.0
    
    var body: some View {
        GeometryReader { geometryProxy in
            
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if item!.itemimage == nil {
                    FullScreenVideoThumbnailView(url: item!.url ?? "")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(contentMode: .fit)
                        .position(
                            x: (position.x + dragging.width),
                            y: (position.y + dragging.height)
                        )
                        .scaleEffect(currentScale * magnifying)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    magnifying = value
                                }
                                .onEnded { _ in
                                    let scale = currentScale * magnifying
                                    if scale > maxScale {
                                        currentScale = maxScale
                                    } else if scale < minScale {
                                        currentScale = minScale
                                    } else {
                                        currentScale = scale
                                    }
                                    magnifying = 1.0
                                }
                                .simultaneously(with: DragGesture()
                                    .onChanged { value in
                                        dragging = value.translation
                                        dragging.width /= currentScale
                                        dragging.height /= currentScale
                                    }
                                    .onEnded { value in
                                        withAnimation {
                                            let positionx = position.x + dragging.width
                                            let positiony = position.y + dragging.height
                                            // 枠外にハミ出ないように位置調整
                                            let centerX = geometryProxy.size.width / 2
                                            if abs(positionx - centerX) > centerX / currentScale {
                                                position.x = centerX
                                            } else {
                                                position.x = positionx
                                            }
                                            
                                            let centerY = geometryProxy.size.height / 2
                                            if abs(positiony - centerY) > centerY / currentScale {
                                                position.y = centerY
                                            } else {
                                                position.y = positiony
                                            }
                                            dragging = .zero
                                        }
                                    }
                                )
                                .simultaneously(with: TapGesture(count: 2)
                                    .onEnded { _ in
                                        withAnimation {
                                            currentScale = 1.0
                                        }
                                    }
                                )
                        )
                } else {
                    Image(uiImage: UIImage(data: item!.itemimage!)!)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(contentMode: .fit)
                        .position(
                            x: (position.x + dragging.width),
                            y: (position.y + dragging.height)
                        )
                        .scaleEffect(currentScale * magnifying)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    magnifying = value
                                }
                                .onEnded { _ in
                                    let scale = currentScale * magnifying
                                    if scale > maxScale {
                                        currentScale = maxScale
                                    } else if scale < minScale {
                                        currentScale = minScale
                                    } else {
                                        currentScale = scale
                                    }
                                    magnifying = 1.0
                                }
                                .simultaneously(with: DragGesture()
                                    .onChanged { value in
                                        dragging = value.translation
                                        dragging.width /= currentScale
                                        dragging.height /= currentScale
                                    }
                                    .onEnded { value in
                                        withAnimation {
                                            let positionx = position.x + dragging.width
                                            let positiony = position.y + dragging.height
                                            // 枠外にハミ出ないように位置調整
                                            let centerX = geometryProxy.size.width / 2
                                            if abs(positionx - centerX) > centerX / currentScale {
                                                position.x = centerX
                                            } else {
                                                position.x = positionx
                                            }
                                            
                                            let centerY = geometryProxy.size.height / 2
                                            if abs(positiony - centerY) > centerY / currentScale {
                                                position.y = centerY
                                            } else {
                                                position.y = positiony
                                            }
                                            dragging = .zero
                                        }
                                    }
                                )
                                .simultaneously(with: TapGesture(count: 2)
                                    .onEnded { _ in
                                        withAnimation {
                                            currentScale = 1.0
                                        }
                                    }
                                )
                        )
                }
            }
            .onAppear {
                position.x = geometryProxy.size.width / 2
                position.y = geometryProxy.size.height / 2
            }
            .overlay {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .hAlign(.leading)
                .vAlign(.top)
            }
        }
    }
}

struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
