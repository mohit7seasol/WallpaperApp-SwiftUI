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
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Share Button
                    Button(action: shareImage) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Image with Zoom & Pan
                if let image = image {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale = min(max(scale * delta, 1), 4)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                    }
                                    .simultaneously(with: DragGesture()
                                        .onChanged { value in
                                            let newOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            offset = newOffset
                                        }
                                        .onEnded { value in
                                            lastOffset = offset
                                        }
                                    )
                            )
                            .onTapGesture(count: 2) {
                                withAnimation(.spring()) {
                                    if scale > 1 {
                                        scale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 3
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.7)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
                
                Spacer()
                
                // Info Card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.green)
                        Text("Edited Photo")
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
                        Text("Pinch to zoom • Double tap to reset")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        if let data = try? Data(contentsOf: photo.fileURL),
           let uiImage = UIImage(data: data) {
            image = uiImage
        }
    }
    
    private func shareImage() {
        guard let image = image else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}
