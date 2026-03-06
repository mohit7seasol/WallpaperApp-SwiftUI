//
//  VideoPlayerComponent.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 06/03/26.
//

import SwiftUI
import AVKit

struct VideoPlayerComponent: View {
    
    let videoURL: URL
    let player: AVPlayer?
    let showAspectRatioWarning: Bool
    let aspectRatio: CGFloat
    let videoResolution: CGSize
    
    let onPlaySelection: () -> Void
    let onSeekToStart: () -> Void
    let onShowAspectRatioWarning: () -> Void
    let onDismissAspectRatioWarning: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: Video Player
            ZStack {
                
                VideoPlayer(player: player ?? AVPlayer(url: videoURL))
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                
                // Play button overlay
                if player?.timeControlStatus != .playing {
                    Button(action: onPlaySelection) {
                        ZStack {
                            
                            Circle()
                                .fill(.black.opacity(0.6))
                                .frame(width: 70,height: 70)
                            
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            //////////////////////////////////////////////////////
            // MARK: Preview Button
            //////////////////////////////////////////////////////
            
            Button(action: onPlaySelection) {
                
                HStack(spacing: 8) {
                    
                    Image(systemName: "play.fill")
                        .font(.subheadline)
                    
                    Text("Preview")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    LinearGradient(
                        colors: [
                            Color.gradientOne,
                            Color.gradientOne
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            //////////////////////////////////////////////////////
            // MARK: Info Button
            //////////////////////////////////////////////////////
            
            Button(action: onShowAspectRatioWarning) {
                
                HStack(spacing: 6) {
                    
                    Image(systemName: "info.circle")
                    
                    Text("Info")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    Color.white.opacity(0.08)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            //////////////////////////////////////////////////////
            // MARK: Aspect Ratio Warning
            //////////////////////////////////////////////////////
            
            if showAspectRatioWarning {
                
                AspectRatioWarningView(
                    currentRatio: aspectRatio,
                    resolution: videoResolution,
                    onDismiss: onDismissAspectRatioWarning
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: Aspect Ratio Warning View
//////////////////////////////////////////////////////////////

struct AspectRatioWarningView: View {
    
    let currentRatio: CGFloat
    let resolution: CGSize
    let onDismiss: () -> Void
    
    private var isPortrait: Bool {
        resolution.height > resolution.width
    }
    
    private var aspectRatioStatus: (title: String, message: String, color: Color, icon: String) {
        
        let idealRatio: CGFloat = 9.0/16.0
        let currentDisplayRatio = isPortrait ? resolution.width / resolution.height : resolution.height / resolution.width
        
        if abs(currentDisplayRatio - idealRatio) < 0.1 {
            return (
                title: "Perfect Match",
                message: "Your video is perfectly optimized for Live Wallpapers",
                color: .green,
                icon: "checkmark.circle.fill"
            )
        } else if abs(currentDisplayRatio - idealRatio) < 0.2 {
            return (
                title: "Good Compatibility",
                message: "Your video has good aspect ratio for Live Wallpapers",
                color: .orange,
                icon: "exclamationmark.triangle.fill"
            )
        } else {
            return (
                title: "Compatibility Warning",
                message: "Your video may not fill the screen perfectly",
                color: .red,
                icon: "xmark.circle.fill"
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with enhanced styling
            HStack {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(aspectRatioStatus.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: aspectRatioStatus.icon)
                        .foregroundColor(aspectRatioStatus.color)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(aspectRatioStatus.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Video Analysis Report")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Dismiss button with enhanced styling
                Button(action: onDismiss) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "xmark")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Status Card
            VStack(spacing: 12) {
                // Status message with icon
                HStack(spacing: 12) {
                    Image(systemName: aspectRatioStatus.icon)
                        .font(.title2)
                        .foregroundColor(aspectRatioStatus.color)
                    
                    Text(aspectRatioStatus.message)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                
                // Progress indicator for aspect ratio match
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Compatibility Score")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(compatibilityScore)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(aspectRatioStatus.color)
                    }
                    
                    // Custom progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(aspectRatioStatus.color)
                                .frame(width: geometry.size.width * compatibilityPercentage, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            
            // Video Specifications Card
            VStack(alignment: .leading, spacing: 16) {
                Text("VIDEO SPECIFICATIONS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .tracking(0.5)
                
                VStack(spacing: 16) {
                    // Resolution row
                    HStack {
                        Label {
                            Text("Resolution")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } icon: {
                            Image(systemName: "rectangle.split.3x3")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(resolution.width)) × \(Int(resolution.height))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.2))
                            )
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Orientation row
                    HStack {
                        Label {
                            Text("Orientation")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } icon: {
                            Image(systemName: isPortrait ? "iphone" : "tv")
                                .font(.caption)
                                .foregroundColor(.purple)
                                .frame(width: 24)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: isPortrait ? "arrow.up.and.down" : "arrow.left.and.right")
                                .font(.caption2)
                                .foregroundColor(.purple)
                            
                            Text(isPortrait ? "Portrait" : "Landscape")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.purple.opacity(0.2))
                        )
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    // Aspect Ratio row
                    HStack {
                        Label {
                            Text("Aspect Ratio")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } icon: {
                            Image(systemName: "rectangle.ratio.3.to.4")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .frame(width: 24)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.2f:1", currentRatio))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.2))
                            )
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            
            // Tips Card
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("PRO TIPS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .tracking(0.5)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    TipRow(
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        text: "Portrait videos (9:16) work best for Live Wallpapers"
                    )
                    
                    TipRow(
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        text: "Square videos (1:1) are also good"
                    )
                    
                    TipRow(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange,
                        text: "Landscape videos may have black bars on sides"
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.yellow.opacity(0.1),
                                Color.orange.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(20)
        .background(
            ZStack {
                // Main background
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.1))
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Border
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .shadow(color: aspectRatioStatus.color.opacity(0.1), radius: 15, x: 0, y: 5)
    }
    
    // Computed properties for compatibility score
    private var compatibilityPercentage: Double {
        let idealRatio: CGFloat = 9.0/16.0
        let currentDisplayRatio = isPortrait ? resolution.width / resolution.height : resolution.height / resolution.width
        let difference = abs(currentDisplayRatio - idealRatio)
        return max(0, min(1, 1 - (difference * 2.5)))
    }
    
    private var compatibilityScore: String {
        let percentage = compatibilityPercentage * 100
        if percentage >= 80 {
            return "Excellent"
        } else if percentage >= 60 {
            return "Good"
        } else if percentage >= 40 {
            return "Fair"
        } else {
            return "Poor"
        }
    }
}

// MARK: - Supporting View
struct TipRow: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(iconColor)
                .frame(width: 16)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    VideoPlayerComponent(
        videoURL: URL(string: "https://example.com/video.mp4")!,
        player: nil,
        showAspectRatioWarning: true,
        aspectRatio: 16/9,
        videoResolution: CGSize(width: 1920, height: 1080),
        onPlaySelection: {},
        onSeekToStart: {},
        onShowAspectRatioWarning: {},
        onDismissAspectRatioWarning: {}
    )
}
