//
//  EditedPhotoPreviewView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/03/26.
//

import SwiftUI
import AVFoundation
import SDWebImageSwiftUI
import _AVKit_SwiftUI

struct EditedPhotoPreviewView: View {
    let photo: EditedPhoto
    
    @State private var image: UIImage?
    
    // Zoom + Pan
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ✅ Respect Safe Area Top
                Spacer().frame(height: Device.topSafeArea)
                
                if let image = image {
                    // Image Container with equal padding on both sides
                    GeometryReader { geo in
                        let size = geo.size
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(zoomGesture(size: size))
                            .gesture(panGesture(size: size))
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) {
                                    if scale > 1 {
                                        resetImage()
                                    } else {
                                        scale = 3
                                    }
                                }
                            }
                            .clipped()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .padding(.horizontal, 10) // Equal padding left and right
                } else {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                }
                
                Spacer()
                
                infoView
                    .padding(.bottom, 30)
            }
        }
        .navigationTitle("My Creations".localized(language))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadImage()
        }
    }
    
    // MARK: - Zoom Gesture
    private func zoomGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                let newScale = scale * delta
                scale = min(max(newScale, 1), 4)
            }
            .onEnded { _ in
                lastScale = 1
                offset = boundedOffset(offset, scale: scale, size: size)
            }
    }
    
    // MARK: - Pan Gesture (Bounded)
    private func panGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                
                let newOffset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                
                offset = boundedOffset(newOffset, scale: scale, size: size)
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    // MARK: - Bound Offset
    private func boundedOffset(_ offset: CGSize, scale: CGFloat, size: CGSize) -> CGSize {
        let widthLimit = (size.width * (scale - 1)) / 2
        let heightLimit = (size.height * (scale - 1)) / 2
        
        return CGSize(
            width: min(max(offset.width, -widthLimit), widthLimit),
            height: min(max(offset.height, -heightLimit), heightLimit)
        )
    }
    
    private func resetImage() {
        withAnimation(.spring()) {
            scale = 1
            offset = .zero
            lastOffset = .zero
        }
    }
    
    // MARK: - Info View
    private var infoView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.green)
                Text("Edited Photo".localized(language))
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                Text(formatDate(photo.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack {
                Image(systemName: "hand.draw")
                    .foregroundColor(.gray)
                Text("Pinch to zoom • Double tap to reset".localized(language))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal, 10) // Equal padding left and right for info view
    }
    
    private func loadImage() {
        guard FileManager.default.fileExists(atPath: photo.fileURL.path) else {
            print("❌ Image file does not exist at path: \(photo.fileURL.path)")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: photo.fileURL),
               let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            } else {
                print("❌ Failed to load image data from: \(photo.fileURL.path)")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}
