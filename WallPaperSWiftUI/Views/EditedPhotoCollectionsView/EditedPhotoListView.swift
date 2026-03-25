//
//  EditedPhotoListView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 25/03/26.
//

import SwiftUI
import AVFoundation

struct EditedPhotoListView: View {
    
    @State private var selectedSegment = 0 // 0: Live Photo, 1: Edited Photo
    @StateObject private var wallpaperViewModel = WallpaperViewModel()
    @StateObject private var photoEditorViewModel = PhotoEditorViewModel()
    @State private var livePhotos: [LivePhotoInfo] = []
    @State private var editedPhotos: [EditedPhoto] = []
    
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
                                LivePhotoCard(photo: photo)
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
                                EditedPhotoCard(photo: photo)
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
    }
    
    private func loadData() {
        livePhotos = wallpaperViewModel.loadLivePhotos()
        editedPhotos = photoEditorViewModel.editedPhotos
    }
}

// MARK: - Live Photo Card
struct LivePhotoCard: View {
    let photo: LivePhotoInfo
    @State private var thumbnail: UIImage?
    @StateObject private var wallpaperViewModel = WallpaperViewModel()
    @State private var showDeleteAlert = false
    
    var body: some View {
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
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .onAppear {
            generateThumbnail()
        }
        .alert("Delete Live Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteLivePhoto()
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
    
    private func deleteLivePhoto() {
        wallpaperViewModel.deleteLivePhoto(photo)
        // Refresh the list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // You might want to use a notification or refresh callback
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
    @State private var image: UIImage?
    @State private var showDeleteAlert = false
    @StateObject private var photoEditorViewModel = PhotoEditorViewModel()
    
    var body: some View {
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
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .onAppear {
            loadImage()
        }
        .alert("Delete Edited Photo", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEditedPhoto()
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
    
    private func deleteEditedPhoto() {
        photoEditorViewModel.deleteEditedPhoto(photo)
        // Refresh the list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // You might want to use a notification or refresh callback
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
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
