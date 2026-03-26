//
//  EditedPhotoListView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 25/03/26.
//

import SwiftUI
import AVFoundation
import SDWebImageSwiftUI
import _AVKit_SwiftUI

struct EditedPhotoListView: View {
    
    @State private var selectedSegment = 0 // 0: Live Photo, 1: Edited Photo
    @StateObject private var wallpaperViewModel = WallpaperViewModel()
    @StateObject private var photoEditorViewModel = PhotoEditorViewModel()
    @State private var livePhotos: [LivePhotoInfo] = []
    @State private var editedPhotos: [EditedPhoto] = []
    @State private var selectedLivePhoto: LivePhotoInfo?
    @State private var selectedEditedPhoto: EditedPhoto?
    @State private var showPreview = false
    
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Segment Control
            Picker("", selection: $selectedSegment) {
                Text("Live Photo Creation".localized(language)).tag(0)
                Text("Edited Photo Creation".localized(language)).tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.black.opacity(0.3))
            
            // MARK: - Content
            TabView(selection: $selectedSegment) {
                // Live Photo Tab
                ScrollView {
                    if livePhotos.isEmpty {
                        EmptyStateView(
                            icon: "livephoto",
                            title: "No Live Photos",
                            message: "Create your first live wallpaper by trimming a video and saving it as a live photo."
                        )
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(livePhotos) { photo in
                                LivePhotoCard(
                                    photo: photo,
                                    onDelete: { deleteLivePhoto(photo) },
                                    onTap: {
                                        selectedLivePhoto = photo
                                        showPreview = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                .tag(0)
                
                // Edited Photo Tab
                ScrollView {
                    if editedPhotos.isEmpty {
                        EmptyStateView(
                            icon: "photo.on.rectangle.angled",
                            title: "No Edited Photos",
                            message: "Edit your first photo using the photo editor and save it."
                        )
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(editedPhotos) { photo in
                                EditedPhotoCard(
                                    photo: photo,
                                    onDelete: { deleteEditedPhoto(photo) },
                                    onTap: {
                                        selectedEditedPhoto = photo
                                        showPreview = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationTitle("My Creations".localized(language))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshCreations"))) { _ in
            loadData()
        }
        .fullScreenCover(isPresented: $showPreview) {
            if let livePhoto = selectedLivePhoto {
                LivePhotoPreviewView(photo: livePhoto)
            } else if let editedPhoto = selectedEditedPhoto {
                EditedPhotoPreviewView(photo: editedPhoto)
            }
        }
    }
    
    private func loadData() {
        livePhotos = wallpaperViewModel.loadLivePhotos()
        editedPhotos = photoEditorViewModel.editedPhotos
    }
    
    private func deleteLivePhoto(_ photo: LivePhotoInfo) {
        wallpaperViewModel.deleteLivePhoto(photo)
        // Reload data immediately
        loadData()
    }
    
    private func deleteEditedPhoto(_ photo: EditedPhoto) {
        photoEditorViewModel.deleteEditedPhoto(photo)
        // Reload data immediately
        loadData()
    }
}

// MARK: - Live Photo Card
struct LivePhotoCard: View {
    let photo: LivePhotoInfo
    let onDelete: () -> Void
    let onTap: () -> Void
    
    @State private var thumbnail: UIImage?
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Thumbnail
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "livephoto")
                                .foregroundColor(.white)
                        )
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(formatDate(photo.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Delete Button
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            generateThumbnail()
        }
        .alert("Delete Live Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this live photo?")
        }
    }
    
    private func generateThumbnail() {
        let asset = AVAsset(url: photo.fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0, preferredTimescale: 600)
        
        DispatchQueue.global().async {
            if let cgImage = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    self.thumbnail = thumbnail
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Edited Photo Card
struct EditedPhotoCard: View {
    let photo: EditedPhoto
    let onDelete: () -> Void
    let onTap: () -> Void
    
    @State private var image: UIImage?
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Thumbnail
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                }
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Edited Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(formatDate(photo.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Delete Button
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadImage()
        }
        .alert("Delete Edited Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this edited photo?")
        }
    }
    
    private func loadImage() {
        if let data = try? Data(contentsOf: photo.fileURL),
           let uiImage = UIImage(data: data) {
            image = uiImage
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Live Photo Preview View
struct LivePhotoPreviewView: View {
    let photo: LivePhotoInfo
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack {
                // Close Button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .onTapGesture {
                            if isPlaying {
                                player.pause()
                            } else {
                                player.play()
                            }
                            isPlaying.toggle()
                        }
                        .overlay(
                            // Play/Pause Overlay
                            Button(action: {
                                if isPlaying {
                                    player.pause()
                                } else {
                                    player.play()
                                }
                                isPlaying.toggle()
                            }) {
                                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.8))
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .opacity(isPlaying ? 0 : 1)
                            .animation(.easeInOut(duration: 0.3), value: isPlaying)
                        )
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
                        Image(systemName: "livephoto")
                            .foregroundColor(.blue)
                        Text("Live Photo")
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
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("Tap to play/pause")
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
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: photo.fileURL)
        player?.actionAtItemEnd = .none
        
        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 80)
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}
