//
//  VideoEditingView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 05/03/26.
//

import SwiftUI
import AVKit
import PhotosUI

struct VideoEditingView: View {
    
    // MARK: - Properties
    
    let videoURL: URL
    
    // State variables for video editing
    @State private var startTime: Double = 0
    @State private var endTime: Double = 5.0
    @State private var speedMultiplier: Double = 1.0
    @State private var videoDuration: Double = 0
    @State private var player: AVPlayer?
    @State private var isProcessing: Bool = false
    @State private var trimmedVideoURL: URL?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var currentPreviewTime: Double = 0
    @State private var timeObserverToken: Any?
    @State private var showAspectRatioWarning: Bool = false
    @State private var aspectRatio: CGFloat = 16/9
    @State private var videoResolution: CGSize = .zero
    
    // Computed property for final duration
    private var finalDuration: Double {
        let selectedDuration = endTime - startTime
        return selectedDuration / speedMultiplier
    }
    
    // Computed property to check if final duration is valid (max 5 seconds)
    private var isFinalDurationValid: Bool {
        finalDuration <= 5.0
    }
    
    // Computed property to check if processing can be performed
    private var canProcess: Bool {
        let duration = endTime - startTime
        let finalDuration = duration / speedMultiplier
        return duration > 0 && finalDuration <= 5.0
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Preview Section
                    VStack(spacing: 12) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Video Player with custom styling
                        ZStack {
                            if let player = player {
                                VideoPlayer(player: player)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            // Play button overlay when paused
                            if player?.timeControlStatus != .playing {
                                Button(action: playSelection) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.black.opacity(0.7))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "play.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Aspect ratio warning
                        if showAspectRatioWarning {
                            AspectRatioWarningView(
                                currentRatio: aspectRatio,
                                resolution: videoResolution,
                                onDismiss: {
                                    withAnimation(.spring()) {
                                        showAspectRatioWarning = false
                                    }
                                }
                            )
                            .transition(.scale.combined(with: .opacity))
                            .padding(.horizontal)
                        }
                        
                        // Preview Controls - Fixed slider range issue
                        if endTime > startTime {
                            HStack {
                                Button(action: playSelection) {
                                    Image(systemName: "play.fill")
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                }
                                
                                Slider(value: $currentPreviewTime, in: startTime...endTime, step: 0.1)
                                    .accentColor(.blue)
                                    .onChange(of: currentPreviewTime) { newTime in
                                        seekTo(time: newTime)
                                    }
                                
                                Button(action: {
                                    player?.pause()
                                    seekToStartTime()
                                }) {
                                    Image(systemName: "gobackward")
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.gray.opacity(0.3))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                    
                    // Trim Video Section - Matches UI in image
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "scissors")
                                .foregroundColor(.blue)
                            Text("Trim Video")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("Max 5 Seconds")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        // Time Labels - Matches image layout
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(formatTime(startTime))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .center, spacing: 4) {
                                Text("Duration")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(formatTime(endTime - startTime))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("End")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(formatTime(endTime))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Range Slider for trimming
                        if videoDuration > 0 {
                            RangeSlider(
                                lowerValue: $startTime,
                                upperValue: $endTime,
                                minimumValue: 0,
                                maximumValue: videoDuration,
                                step: 0.1,
                                maxRange: min(5.0 * speedMultiplier, videoDuration)
                            )
                            .frame(height: 50)
                            .onChange(of: startTime) { _, _ in
                                seekToStartTime()
                                currentPreviewTime = startTime
                            }
                            .onChange(of: endTime) { _, _ in
                                if player?.timeControlStatus == .playing {
                                    playSelection()
                                }
                            }
                        }
                        
                        if !isFinalDurationValid {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Max Duration Reached")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Playback Speed Section - Matches UI in image
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(.purple)
                            Text("Playback Speed")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("Final Duration: \(formatFinalDuration(finalDuration))")
                                .font(.subheadline)
                                .foregroundColor(isFinalDurationValid ? .green : .orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(isFinalDurationValid ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        // Speed Options
                        HStack(spacing: 12) {
                            ForEach([1.0, 1.5, 2.0, 2.5], id: \.self) { speed in
                                SpeedButton(
                                    speed: speed,
                                    isSelected: speedMultiplier == speed,
                                    finalDuration: (endTime - startTime) / speed,
                                    action: {
                                        withAnimation(.spring()) {
                                            speedMultiplier = speed
                                            updatePlayerRate()
                                            autoAdjustSelectionForSpeed(speed)
                                        }
                                    }
                                )
                            }
                        }
                        
                        // Speed Conversion Preview - Matches image
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Speed Conversion Preview:")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    Text("\(formatTime(endTime - startTime)) at \(String(format: "%.1f", speedMultiplier))x = \(formatFinalDuration(finalDuration)) final duration")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            if isFinalDurationValid {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Perfect! Final Duration is within Live photo limits.")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("Final duration exceeds 5 seconds. Consider increasing speed or reducing clip length.")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Trim Video First Button - Matches image
                        Button(action: processVideo) {
                            HStack(spacing: 12) {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "scissors")
                                        .font(.title3)
                                }
                                
                                Text(isProcessing ? "Processing..." : "Trim Video First")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(canProcess ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!canProcess || isProcessing)
                        
                        // Preview Selection Button
                        Button(action: playSelection) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.callout)
                                Text("Preview Selection")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        
                        // Create Live Wallpaper Button (only shown after processing)
                        if trimmedVideoURL != nil {
                            Button(action: createLiveWallpaper) {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.title3)
                                    Text("Create Live Wallpaper")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Edit Video")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupPlayer()
            loadVideoDuration()
            analyzeVideoProperties()
        }
        .onDisappear {
            cleanup()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Message"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        seekToStartTime()
    }
    
    private func loadVideoDuration() {
        let asset = AVAsset(url: videoURL)
        Task {
            do {
                let duration = try await asset.load(.duration).seconds
                await MainActor.run {
                    videoDuration = duration
                    endTime = min(5.0, duration) // Default to first 5 seconds or full video if shorter
                    if duration < 5.0 {
                        endTime = duration
                    }
                    currentPreviewTime = startTime
                }
            } catch {
                print("Error loading video duration: \(error)")
            }
        }
    }
    
    private func analyzeVideoProperties() {
        let asset = AVAsset(url: videoURL)
        
        Task {
            do {
                guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else { return }
                let naturalSize = try await videoTrack.load(.naturalSize)
                let transform = try await videoTrack.load(.preferredTransform)
                
                // Calculate actual display size considering transform
                let size = naturalSize.applying(transform)
                let actualSize = CGSize(width: abs(size.width), height: abs(size.height))
                
                await MainActor.run {
                    self.videoResolution = actualSize
                    self.aspectRatio = actualSize.width / actualSize.height
                    
                    // Check if aspect ratio is not ideal for Live Wallpapers
                    let isPortrait = actualSize.height > actualSize.width
                    let idealRatio: CGFloat = 9.0/16.0 // Portrait ratio for phones
                    let currentRatio = isPortrait ? actualSize.width / actualSize.height : actualSize.height / actualSize.width
                    
                    // Show warning if not close to ideal mobile aspect ratio
                    if abs(currentRatio - idealRatio) > 0.2 {
                        withAnimation(.spring()) {
                            showAspectRatioWarning = true
                        }
                    }
                }
            } catch {
                print("Error analyzing video: \(error)")
            }
        }
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time - Double(Int(time))) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    private func formatFinalDuration(_ time: Double) -> String {
        let seconds = Int(time)
        let tenths = Int((time - Double(seconds)) * 10)
        return String(format: "%02d.%d", seconds, tenths)
    }
    
    private func seekTo(time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func seekToStartTime() {
        seekTo(time: startTime)
        currentPreviewTime = startTime
    }
    
    private func playSelection() {
        guard let player = player, endTime > startTime else { return }
        
        // Remove any existing observer first
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        // Seek to start time
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 600)
        player.seek(to: startCMTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
            if finished {
                // Start playback with selected speed
                player.rate = Float(self.speedMultiplier)
                
                // Set up a new observer
                let observer = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
                    let currentSeconds = time.seconds
                    if currentSeconds >= self.endTime {
                        player.pause()
                        self.seekToStartTime()
                    }
                    self.currentPreviewTime = time.seconds
                }
                
                // Store the observer token for later removal
                self.timeObserverToken = observer
            }
        }
    }
    
    private func updatePlayerRate() {
        guard let player = player else { return }
        
        // Only update rate if the player is currently playing
        if player.timeControlStatus == .playing {
            player.rate = Float(speedMultiplier)
        }
    }
    
    private func autoAdjustSelectionForSpeed(_ newSpeed: Double) {
        let currentDuration = endTime - startTime
        let newFinalDuration = currentDuration / newSpeed
        
        // Calculate the maximum original duration we can select at this speed to get 5 seconds final
        let maxOriginalDuration = 5.0 * newSpeed
        let availableDuration = min(maxOriginalDuration, videoDuration)
        
        // Check if current selection is invalid (too long for the new speed)
        if newFinalDuration > 5.0 {
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
            
            startTime = newStartTime
            endTime = newEndTime
        }
    }
    
    private func processVideo() {
        guard canProcess else { return }
        
        isProcessing = true
        
        // Simulate processing (replace with actual video processing logic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            trimmedVideoURL = videoURL // In real implementation, this would be the processed video URL
            isProcessing = false
            alertMessage = "Video trimmed successfully! You can now create your Live Wallpaper."
            showAlert = true
        }
    }
    
    private func createLiveWallpaper() {
        alertMessage = "Live Wallpaper created successfully!"
        showAlert = true
    }
    
    private func cleanup() {
        if let player = player, let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        player?.pause()
    }
}

// MARK: - Speed Button Component

struct SpeedButton: View {
    let speed: Double
    let isSelected: Bool
    let finalDuration: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(String(format: "%.1f", speed))x")
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(speedDescription)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                
                Text(formatFinalDuration(finalDuration))
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.purple : Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var speedDescription: String {
        switch speed {
        case 1.0: return "Normal Speed"
        case 1.5: return "Smooth Motion"
        case 2.0: return "Smooth Motion"
        case 2.5: return "Smooth Motion"
        default: return ""
        }
    }
    
    private func formatFinalDuration(_ time: Double) -> String {
        let seconds = Int(time)
        let tenths = Int((time - Double(seconds)) * 10)
        return String(format: "%02d.%d", seconds, tenths)
    }
}

// MARK: - Aspect Ratio Warning Component

struct AspectRatioWarningView: View {
    let currentRatio: CGFloat
    let resolution: CGSize
    let onDismiss: () -> Void
    
    private var isPortrait: Bool {
        resolution.height > resolution.width
    }
    
    private var aspectRatioStatus: (message: String, color: Color, icon: String) {
        let idealRatio: CGFloat = 9.0/16.0
        let currentDisplayRatio = isPortrait ? resolution.width / resolution.height : resolution.height / resolution.width
        
        if abs(currentDisplayRatio - idealRatio) < 0.1 {
            return ("Perfect for Live Wallpapers!", Color.green, "checkmark.circle.fill")
        } else if abs(currentDisplayRatio - idealRatio) < 0.2 {
            return ("Good aspect ratio", Color.orange, "exclamationmark.triangle.fill")
        } else {
            return ("May not fill screen perfectly", Color.red, "xmark.circle.fill")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: aspectRatioStatus.icon)
                    .foregroundColor(aspectRatioStatus.color)
                    .font(.title2)
                
                Text("Video Analysis")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            
            // Status message
            Text(aspectRatioStatus.message)
                .font(.subheadline)
                .foregroundColor(aspectRatioStatus.color)
                .fontWeight(.medium)
            
            // Video specs
            VStack(spacing: 12) {
                HStack {
                    Text("Resolution:")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(Int(resolution.width)) × \(Int(resolution.height))")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Orientation:")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                    Text(isPortrait ? "Portrait" : "Landscape")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Aspect Ratio:")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    Spacer()
                    Text(String(format: "%.2f:1", currentRatio))
                        .foregroundColor(.gray)
                }
            }
            .font(.subheadline)
            
            // Recommendations
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 Tips for best results:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Portrait videos (9:16) work best")
                    Text("• Square videos (1:1) are also good")
                    Text("• Landscape videos may have black bars")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - RangeSlider Component

struct RangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    let minimumValue: Double
    let maximumValue: Double
    let step: Double
    let maxRange: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .cornerRadius(2)
                
                // Selected range
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: max(0, width(for: upperValue - lowerValue, in: geometry)), height: 4)
                    .offset(x: position(for: lowerValue, in: geometry))
                    .cornerRadius(2)
                
                // Lower thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: position(for: lowerValue, in: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = valueFrom(offset: value.location.x, in: geometry)
                                let constrainedValue = min(max(newValue, minimumValue), upperValue - step)
                                let steppedValue = round(constrainedValue / step) * step
                                if upperValue - steppedValue <= maxRange {
                                    lowerValue = steppedValue
                                }
                            }
                    )
                
                // Upper thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 2)
                    .offset(x: position(for: upperValue, in: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = valueFrom(offset: value.location.x, in: geometry)
                                let constrainedValue = max(min(newValue, maximumValue), lowerValue + step)
                                let steppedValue = round(constrainedValue / step) * step
                                if steppedValue - lowerValue <= maxRange {
                                    upperValue = steppedValue
                                }
                            }
                    )
            }
            .frame(height: 40)
        }
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let range = maximumValue - minimumValue
        let percentage = (value - minimumValue) / range
        return CGFloat(percentage) * (geometry.size.width - 24)
    }
    
    private func width(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let range = maximumValue - minimumValue
        let percentage = value / range
        return CGFloat(percentage) * (geometry.size.width - 24)
    }
    
    private func valueFrom(offset: CGFloat, in geometry: GeometryProxy) -> Double {
        let percentage = Double(offset / (geometry.size.width - 24))
        return minimumValue + (percentage * (maximumValue - minimumValue))
    }
}
