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
    
    @State private var selectedSegment = 0
    @StateObject private var wallpaperViewModel = WallpaperViewModel()
    @StateObject private var photoEditorViewModel = PhotoEditorViewModel()
    
    @State private var livePhotos: [LivePhotoInfo] = []
    @State private var editedPhotos: [EditedPhoto] = []
    
    @State private var selectedLivePhoto: LivePhotoInfo?
    @State private var selectedEditedPhoto: EditedPhoto?
    @State private var navigateToLivePreview = false
    @State private var navigateToEditedPreview = false
    
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Segment
            Picker("", selection: $selectedSegment) {
                Text("Live Photo Creation".localized(language)).tag(0)
                Text("Edited Photo Creation".localized(language)).tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.black.opacity(0.3))
            
            // MARK: Content
            TabView(selection: $selectedSegment) {
                
                // Live Photos
                ScrollView {
                    if livePhotos.isEmpty {
                        EmptyStateView(
                            icon: "livephoto".localized(language),
                            title: "No Live Photos".localized(language),
                            message: "Create your first live wallpaper.".localized(language)
                        )
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(livePhotos) { photo in
                                LivePhotoCard(
                                    photo: photo,
                                    onDelete: { deleteLivePhoto(photo) },
                                    onTap: {
                                        selectedLivePhoto = photo
                                        navigateToLivePreview = true
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
                .tag(0)
                
                // Edited Photos
                ScrollView {
                    if editedPhotos.isEmpty {
                        EmptyStateView(
                            icon: "photo.on.rectangle.angled",
                            title: "No Edited Photos".localized(language),
                            message: "Edit your first photo.".localized(language)
                        )
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(editedPhotos) { photo in
                                EditedPhotoCard(
                                    photo: photo,
                                    onDelete: { deleteEditedPhoto(photo) },
                                    onTap: {
                                        selectedEditedPhoto = photo
                                        navigateToEditedPreview = true
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
        // ✅ KEEP ONLY THIS (default navigation title)
        .navigationTitle("My Creations".localized(language))
        .navigationBarTitleDisplayMode(.inline)
        
        // ✅ Navigation links
        .background(
            NavigationLink(
                destination: LivePhotoPreviewView(photo: selectedLivePhoto ?? LivePhotoInfo(id: UUID(), fileName: "", fileURL: URL(string: "about:blank")!, createdAt: Date())),
                isActive: $navigateToLivePreview
            ) { EmptyView() }
        )
        .background(
            NavigationLink(
                destination: EditedPhotoPreviewView(photo: selectedEditedPhoto ?? EditedPhoto(id: UUID(), fileName: "", fileURL: URL(string: "about:blank")!, createdAt: Date())),
                isActive: $navigateToEditedPreview
            ) { EmptyView() }
        )
        .onAppear {
            loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshCreations"))) { _ in
            loadData()
        }
    }
    
    private func loadData() {
        livePhotos = wallpaperViewModel.loadLivePhotos()
        editedPhotos = photoEditorViewModel.editedPhotos
    }
    
    private func deleteLivePhoto(_ photo: LivePhotoInfo) {
        wallpaperViewModel.deleteLivePhoto(photo)
        loadData()
    }
    
    private func deleteEditedPhoto(_ photo: EditedPhoto) {
        photoEditorViewModel.deleteEditedPhoto(photo)
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
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
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
                    Text("Live Photo".localized(language))
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
        .alert("Delete Live Photo".localized(language), isPresented: $showDeleteAlert) {
            Button("Cancel".localized(language), role: .cancel) { }
            Button("Delete".localized(language), role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this live photo?".localized(language))
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
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
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
                    Text("Edited Photo".localized(language))
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
        .alert("Delete Edited Photo".localized(language), isPresented: $showDeleteAlert) {
            Button("Cancel".localized(language), role: .cancel) { }
            Button("Delete".localized(language), role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this edited photo?".localized(language))
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
