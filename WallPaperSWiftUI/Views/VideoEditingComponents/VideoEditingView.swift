//
//  VideoEditingView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 05/03/26.
//

import SwiftUI
import AVKit
import AVFoundation

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
                    onSpeedChange: { speed in
                        speedMultiplier = speed
                        updatePlayerRate()
                    }
                )
                
                
                // MARK: - Processing Actions
                
                VideoProcessingActions(
                    speedMultiplier: $speedMultiplier,
                    isProcessing: $isProcessing,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    asset: asset,
                    startTime: startTime,
                    endTime: endTime,
                    canProcess: canProcess,
                    trimmedVideoURL: trimmedVideoURL,
                    onCreateWallpaper: processVideo,
                    onPreview: playSelection
                )
            }
            .padding()
        }
        .navigationTitle("Live Wallpaper")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupVideo()
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        let ms = Int((seconds - floor(seconds)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, secs, ms)
    }
}

#Preview {
    VideoEditingView(
        videoURL: URL(string: "https://example.com/video.mp4")!
    )
}

extension VideoEditingView {
    
    func setupVideo() {
        
        asset = AVAsset(url: videoURL)
        player = AVPlayer(url: videoURL)
        
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
    
    
    func processVideo() {
        
        guard let asset = asset else { return }
        
        isProcessing = true
        
        DispatchQueue.global().async {
            
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".mov")
            
            let start = CMTime(seconds: startTime, preferredTimescale: 600)
            let duration = CMTime(seconds: endTime - startTime, preferredTimescale: 600)
            
            let exporter = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetHighestQuality
            )
            
            exporter?.outputURL = outputURL
            exporter?.outputFileType = .mov
            exporter?.timeRange = CMTimeRange(start: start, duration: duration)
            
            exporter?.exportAsynchronously {
                
                DispatchQueue.main.async {
                    
                    isProcessing = false
                    
                    if exporter?.status == .completed {
                        trimmedVideoURL = outputURL
                    } else {
                        alertMessage = "Failed to process video."
                        showAlert = true
                    }
                }
            }
        }
    }
}
