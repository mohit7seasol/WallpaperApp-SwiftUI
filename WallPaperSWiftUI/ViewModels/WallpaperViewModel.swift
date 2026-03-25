//
//  WallpaperViewModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 06/03/26.
//

import SwiftUI
import PhotosUI
import AVKit
import UniformTypeIdentifiers
import UIKit
import Combine
import Toasts // Add this import

class WallpaperViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedVideoURL: URL?
    @Published var trimmedVideoURL: URL?
    @Published var startTime: Double = 0
    @Published var endTime: Double = 5
    @Published var speedMultiplier: Double = 1.0
    @Published var videoDuration: Double = 0
    @Published var isProcessing = false
    @Published var showSuccessMessage = false
    @Published var errorMessage: String?
    @Published var livePhotoURL: URL?
    
    // MARK: - Toast Publisher (Option B)
    let toastPublisher = PassthroughSubject<ToastValue, Never>()
    
    // MARK: - Public Methods
    
    func resetVideo() {
        selectedItem = nil
        selectedVideoURL = nil
        trimmedVideoURL = nil
        startTime = 0
        endTime = 5
        speedMultiplier = 1.0
        videoDuration = 0
        showSuccessMessage = false
        errorMessage = nil
    }
    
    func loadVideo(from item: PhotosPickerItem) {
        print("Loading video from PhotosPickerItem")
        
        item.loadTransferable(type: VideoFile.self) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let videoFile):
                if let videoFile = videoFile {
                    print("Successfully loaded video file at: \(videoFile.url)")
                    
                    DispatchQueue.main.async {
                        self.selectedVideoURL = videoFile.url
                        
                        let asset = AVAsset(url: videoFile.url)
                        Task {
                            do {
                                let duration = try await asset.load(.duration).seconds
                                print("Video duration: \(duration) seconds")
                                self.videoDuration = duration
                                self.endTime = min(5, duration)
                            } catch {
                                print("Error loading duration: \(error)")
                                self.errorMessage = "Failed to load video duration: \(error.localizedDescription)"
                            }
                        }
                    }
                } else {
                    print("VideoFile is nil")
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to load video: VideoFile is nil"
                    }
                }
                
            case .failure(let error):
                print("Error loading video: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load video: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func processVideo() {
        guard let selectedVideoURL = selectedVideoURL else { return }
        
        print("🎬 Starting video processing...")
        print("🎬 Settings - Start: \(startTime)s, End: \(endTime)s, Speed: \(speedMultiplier)x")
        print("🎬 Duration: \(endTime - startTime)s -> Final: \((endTime - startTime) / speedMultiplier)s")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        isProcessing = true
        
        VideoProcessor.trimAndSpeedUpVideo(
            at: selectedVideoURL,
            from: startTime,
            to: endTime,
            speedMultiplier: speedMultiplier
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                
                switch result {
                case .success(let trimmedURL):
                    print("🎬 ✅ Video processing completed: \(trimmedURL.lastPathComponent)")
                    self.trimmedVideoURL = trimmedURL
                    
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                case .failure(let error):
                    print("🎬 ❌ Video processing failed: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    // MARK: - UPDATED: Save to Photo Library with Toast
    func saveToPhotoLibrary(presentToast: @escaping (ToastValue) -> Void) {
        guard let trimmedVideoURL = trimmedVideoURL else {
            let toast = ToastValue(
                icon: Image(systemName: "exclamationmark.triangle"),
                message: "No processed video available"
            )
            presentToast(toast)
            return
        }

        let asset = AVAsset(url: trimmedVideoURL)
        let duration = asset.duration.seconds

        // Show error toast if duration exceeds 5 seconds
        if duration > 5 {
            let toast = ToastValue(
                icon: Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange),
                message: "Live Photo video must be 5 seconds or less"
            )
            presentToast(toast)
            return
        }

        isProcessing = true

        VideoProcessor.saveAsLivePhoto(from: trimmedVideoURL) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isProcessing = false

                switch result {
                case .success:
                    // Save live photo info to storage
                    self.saveLivePhotoInfo(fileURL: trimmedVideoURL)
                    self.showSuccessMessage = true
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                    
                case .failure(let error):
                    let errorToast = ToastValue(
                        icon: Image(systemName: "xmark.circle"),
                        message: error.localizedDescription
                    )
                    presentToast(errorToast)
                    
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
    
    // MARK: - Alternative: Using Publisher (Option B)
    func saveToPhotoLibraryWithPublisher() {
        guard let trimmedVideoURL = trimmedVideoURL else {
            toastPublisher.send(
                ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle"),
                    message: "No processed video available"
                )
            )
            return
        }

        let asset = AVAsset(url: trimmedVideoURL)
        let duration = asset.duration.seconds

        if duration > 5 {
            toastPublisher.send(
                ToastValue(
                    icon: Image(systemName: "exclamationmark.triangle.fill"),
                    message: "Live Photo video must be 5 seconds or less"
                )
            )
            return
        }

        isProcessing = true

        VideoProcessor.saveAsLivePhoto(from: trimmedVideoURL) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isProcessing = false

                switch result {
                case .success:
                    self.showSuccessMessage = true
                case .failure(let error):
                    self.toastPublisher.send(
                        ToastValue(
                            icon: Image(systemName: "xmark.circle"),
                            message: error.localizedDescription
                        )
                    )
                }
            }
        }
    }
    
    func getRecommendedSpeed(for duration: Double) -> Double {
        if duration > 4.0 {
            return 2.0
        } else if duration > 3.0 {
            return 1.5
        } else {
            return 1.0
        }
    }
}

// MARK: - Live Photo & Edited Photo Storage
extension WallpaperViewModel {
    
    func saveLivePhotoInfo(fileURL: URL) {
        let fileName = fileURL.lastPathComponent
        let livePhoto = LivePhotoInfo(
            id: UUID(),
            fileName: fileName,
            fileURL: fileURL,
            createdAt: Date()
        )
        
        var livePhotos = loadLivePhotos()
        livePhotos.insert(livePhoto, at: 0)
        
        do {
            let data = try JSONEncoder().encode(livePhotos)
            UserDefaults.standard.set(data, forKey: "livePhotos")
            print("✅ Saved live photo info: \(fileName)")
        } catch {
            print("❌ Failed to save live photo info: \(error)")
        }
    }
    
    func loadLivePhotos() -> [LivePhotoInfo] {
        guard let data = UserDefaults.standard.data(forKey: "livePhotos") else { return [] }
        
        do {
            let photos = try JSONDecoder().decode([LivePhotoInfo].self, from: data)
            return photos
        } catch {
            print("❌ Failed to load live photos: \(error)")
            return []
        }
    }
    
    func deleteLivePhoto(_ photo: LivePhotoInfo) {
        var livePhotos = loadLivePhotos()
        livePhotos.removeAll { $0.id == photo.id }
        
        // Delete file from documents
        do {
            try FileManager.default.removeItem(at: photo.fileURL)
            print("✅ Deleted live photo file: \(photo.fileName)")
        } catch {
            print("❌ Failed to delete live photo file: \(error)")
        }
        
        // Save updated list
        do {
            let data = try JSONEncoder().encode(livePhotos)
            UserDefaults.standard.set(data, forKey: "livePhotos")
        } catch {
            print("❌ Failed to save updated live photos: \(error)")
        }
    }
}

struct LivePhotoInfo: Codable, Identifiable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case fileName
        case fileURL
        case createdAt
    }
    
    init(id: UUID, fileName: String, fileURL: URL, createdAt: Date) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        let urlString = try container.decode(String.self, forKey: .fileURL)
        fileURL = URL(string: urlString) ?? Self.getDocumentsDirectory().appendingPathComponent(fileName)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileURL.absoluteString, forKey: .fileURL)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
