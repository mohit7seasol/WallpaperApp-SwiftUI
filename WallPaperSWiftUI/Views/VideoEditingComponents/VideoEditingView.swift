//
//  VideoEditingView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 05/03/26.
//

import SwiftUI
import AVKit
import AVFoundation
import Photos

struct VideoEditingView: View {
    
    // MARK: - Video Data
    let videoURL: URL
    
    // MARK: - Player
    @State private var player: AVPlayer?
    @State private var asset: AVAsset?
    
    // MARK: - Trim State
    @State private var startTime: Double = 0
    @State private var endTime: Double = 5
    @State private var videoDuration: Double = 0
    
    // MARK: - Speed
    @State private var speedMultiplier: Double = 1.0
    
    // MARK: - Processing
    @State private var isProcessing = false
    @State private var trimmedVideoURL: URL?
    
    // MARK: - UI State
    @State private var showAspectRatioWarning = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Video Info
    @State private var aspectRatio: CGFloat = 0
    @State private var videoResolution: CGSize = .zero
    @StateObject private var viewModel = WallpaperViewModel()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    // MARK: - Computed
    
    var finalDuration: Double {
        (endTime - startTime) / speedMultiplier
    }
    
    var isFinalDurationValid: Bool {
        finalDuration <= 5.0
    }
    
    var canProcess: Bool {
        endTime > startTime && isFinalDurationValid
    }
    
    // MARK: - View
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 24) {
                
                // MARK: - Video Player
                
                VideoPlayerComponent(
                    videoURL: videoURL,
                    player: player,
                    showAspectRatioWarning: showAspectRatioWarning,
                    aspectRatio: aspectRatio,
                    videoResolution: videoResolution,
                    onPlaySelection: playSelection,
                    onSeekToStart: seekToStartTime,
                    onShowAspectRatioWarning: {
                        showAspectRatioWarning.toggle()
                    },
                    onDismissAspectRatioWarning: {
                        showAspectRatioWarning = false
                    }
                )
                
                // MARK: - Trimming
                
                VideoTrimmingComponent(
                    startTime: $startTime,
                    endTime: $endTime,
                    videoDuration: videoDuration,
                    speedMultiplier: speedMultiplier,
                    isFinalDurationValid: canProcess,
                    formatTime: formatTime,
                    onStartChanged: {
                        seekToStartTime()
                    },
                    onEndChanged: {
                        if player?.timeControlStatus == .playing {
                            playSelection()
                        }
                    }
                )
                
                // MARK: - Speed Control
                
                SpeedControlComponent(
                    speedMultiplier: $speedMultiplier,
                    startTime: startTime,
                    endTime: endTime,
                    onSpeedChange: { newSpeed in
                        // Auto-adjust selection range when speed changes
                        autoAdjustSelectionForSpeed(newSpeed)
                        
                        // Update player rate
                        updatePlayerRate()
                        
                        // Update preview if playing
                        if player?.timeControlStatus == .playing {
                            playSelection()
                        }
                    }
                )
                
                // MARK: - Processing Actions
                
                VideoProcessingActions(
                    speedMultiplier: $speedMultiplier,
                    isProcessing: $viewModel.isProcessing,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    asset: asset,
                    startTime: startTime,
                    endTime: endTime,
                    canProcess: canProcess,
                    trimmedVideoURL: viewModel.trimmedVideoURL,
                    onCreateWallpaper: handleCreateLiveWallpaper,
                    onPreview: playSelection
                )
                .alert("🎉 Success!".localized(language), isPresented: $viewModel.showSuccessMessage) {
                    Button("OK".localized(language)) {
                        dismiss()   // Navigate back to previous/root view
                    }
                    
                } message: {
                    SuccessAlertMessage()
                }
            }
            .padding()
        }
        .navigationTitle("Live Wallpaper".localized(language))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupVideo()
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("Success", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds - floor(seconds)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, secs, ms)
    }
    
    // MARK: - Unified action (like reference code)
    private func handleCreateLiveWallpaper() {
        viewModel.startTime = startTime
        viewModel.endTime = endTime
        viewModel.speedMultiplier = speedMultiplier

        if viewModel.trimmedVideoURL != nil {
            viewModel.saveToPhotoLibrary()
        } else {
            viewModel.processVideo()
        }
    }
}

#Preview {
    VideoEditingView(
        videoURL: URL(string: "https://example.com/video.mp4")!
    )
}

// MARK: - Video Setup and Playback Extensions
extension VideoEditingView {
    
    func setupVideo() {

        asset = AVAsset(url: videoURL)
        player = AVPlayer(url: videoURL)

        viewModel.selectedVideoURL = videoURL

        guard let asset = asset else { return }

        videoDuration = asset.duration.seconds
        endTime = min(5, videoDuration)

        if let track = asset.tracks(withMediaType: .video).first {
            let size = track.naturalSize.applying(track.preferredTransform)
            videoResolution = CGSize(width: abs(size.width), height: abs(size.height))
            aspectRatio = videoResolution.width / videoResolution.height
        }
    }
    
    func playSelection() {
        
        guard let player = player else { return }
        
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        
        player.seek(to: start)
        player.rate = Float(speedMultiplier)
        player.play()
    }
    
    func seekToStartTime() {
        
        guard let player = player else { return }
        
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        player.seek(to: start)
    }
    
    func updatePlayerRate() {
        player?.rate = Float(speedMultiplier)
    }
    
    // MARK: - Auto-adjust selection for speed changes
    func autoAdjustSelectionForSpeed(_ newSpeed: Double) {
        let currentDuration = endTime - startTime
        let newFinalDuration = currentDuration / newSpeed
        
        print("🔧 Speed changed to \(newSpeed)x: Current duration \(currentDuration)s -> Final duration \(newFinalDuration)s")
        
        // Calculate the maximum original duration we can select at this speed to get 5 seconds final
        let maxOriginalDuration = 5.0 * newSpeed
        let availableDuration = min(maxOriginalDuration, videoDuration)
        
        print("🔧 Max original duration at \(newSpeed)x speed: \(maxOriginalDuration)s, available: \(availableDuration)s")
        
        // Check if current selection is invalid (too long for the new speed)
        if newFinalDuration > 5.0 {
            print("🔧 Current selection too long for new speed! Must shrink from \(currentDuration)s to max \(availableDuration)s")
            
            // Shrink selection while keeping it centered if possible
            let currentCenter = (startTime + endTime) / 2
            let halfDuration = availableDuration / 2
            
            var newStartTime = max(0, currentCenter - halfDuration)
            var newEndTime = min(videoDuration, currentCenter + halfDuration)
            
            // Adjust if selection goes beyond video bounds
            if newEndTime > videoDuration {
                newEndTime = videoDuration
                newStartTime = max(0, videoDuration - availableDuration)
            } else if newStartTime < 0 {
                newStartTime = 0
                newEndTime = min(videoDuration, availableDuration)
            }
            
            print("🔧 Shrinking selection: \(startTime)s-\(endTime)s -> \(newStartTime)s-\(newEndTime)s")
            startTime = newStartTime
            endTime = newEndTime
            
        } else if availableDuration > currentDuration + 0.1 {
            print("🔧 Can expand selection to use more video")
            
            // Try to keep the selection centered, but adjust if needed
            let currentCenter = (startTime + endTime) / 2
            let halfDuration = availableDuration / 2
            
            var newStartTime = max(0, currentCenter - halfDuration)
            var newEndTime = min(videoDuration, currentCenter + halfDuration)
            
            // Adjust if selection goes beyond video bounds
            if newEndTime > videoDuration {
                newEndTime = videoDuration
                newStartTime = max(0, videoDuration - availableDuration)
            } else if newStartTime < 0 {
                newStartTime = 0
                newEndTime = min(videoDuration, availableDuration)
            }
            
            print("🔧 Expanding selection: \(startTime)s-\(endTime)s -> \(newStartTime)s-\(newEndTime)s")
            startTime = newStartTime
            endTime = newEndTime
        }
    }
}
struct SuccessAlertMessage: View {
    
    var body: some View {
        Text("""
🎉 Live Wallpaper Created Successfully!

Your Live Photo has been saved to Photos.

To set it as your wallpaper:
1. Open Settings
2. Tap Wallpaper
3. Choose your new Live Photo
4. Set it as Lock Screen
""")
    }
}
