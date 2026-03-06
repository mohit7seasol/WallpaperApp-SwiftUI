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
    
    func saveToPhotoLibrary() {

        guard let trimmedVideoURL = trimmedVideoURL else {
            errorMessage = "No processed video available"
            return
        }

        let asset = AVAsset(url: trimmedVideoURL)
        let duration = asset.duration.seconds

        if duration > 5 {
            errorMessage = "Live Photo video must be 5 seconds or less"
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
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
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
