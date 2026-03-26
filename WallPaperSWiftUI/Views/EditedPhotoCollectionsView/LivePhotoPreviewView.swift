//
//  LivePhotoPreviewView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/03/26.
//

import SwiftUI
import AVFoundation
import SDWebImageSwiftUI
import _AVKit_SwiftUI

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
