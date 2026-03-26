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
    @Environment(\.presentationMode) var presentationMode
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var playerItem: AVPlayerItem?
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar - Same as EditedPhotoListView
                HStack {
                    // Back button using NavigationLink style
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("My Creations")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Share Button
                    Button(action: shareVideo) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color.black.opacity(0.8))
                
                Spacer()
                
                // Video Player
                if let player = player {
                    ZStack {
                        VideoPlayer(player: player)
                            .frame(maxWidth: .infinity)
                            .frame(height: UIScreen.main.bounds.height * 0.7)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Play/Pause Overlay Button
                        Button(action: togglePlayPause) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                        }
                        .opacity(isPlaying ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: isPlaying)
                    }
                    .onTapGesture {
                        togglePlayPause()
                    }
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .tint(.white)
                                Text("Loading video...")
                                    .foregroundColor(.white)
                            }
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
                        Text("Tap video to play/pause")
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
        .navigationBarHidden(true)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func setupPlayer() {
        guard FileManager.default.fileExists(atPath: photo.fileURL.path) else {
            print("❌ Video file does not exist at path: \(photo.fileURL.path)")
            return
        }
        
        playerItem = AVPlayerItem(url: photo.fileURL)
        player = AVPlayer(playerItem: playerItem)
        
        // Loop video
        let loopPlayerItem = playerItem
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: loopPlayerItem,
            queue: .main
        ) { _ in
            if let currentPlayer = self.player {
                currentPlayer.seek(to: .zero)
                currentPlayer.play()
            }
        }
        
        // Auto-play when loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.player?.play()
            self.isPlaying = true
        }
    }
    
    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    private func shareVideo() {
        let activityVC = UIActivityViewController(
            activityItems: [photo.fileURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy • h:mm a"
        return formatter.string(from: date)
    }
}
