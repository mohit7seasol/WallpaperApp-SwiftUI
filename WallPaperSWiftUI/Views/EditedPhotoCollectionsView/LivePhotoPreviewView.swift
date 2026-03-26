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
    
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // ✅ Respect Safe Area Top
                Spacer().frame(height: Device.topSafeArea)
                
                Spacer()
                
                // ✅ Clean Video (No Controls)
                if let player = player {
                    VideoPlayer(player: player)
                        .disabled(true) // disable interactions
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .cornerRadius(20)
                        .clipped()
                } else {
                    ProgressView().tint(.white)
                }
                
                Spacer()
                
                infoView
                
                Spacer().frame(height: Device.bottomSafeArea)
            }
        }
        .navigationTitle("My Creations")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    // MARK: - Setup Player (Muted + Loop)
    private func setupPlayer() {
        guard FileManager.default.fileExists(atPath: photo.fileURL.path) else { return }
        
        let item = AVPlayerItem(url: photo.fileURL)
        let player = AVPlayer(playerItem: item)
        
        // ✅ HARD MUTE (important)
        player.isMuted = true
        player.volume = 0.0
        
        self.player = player
        
        // ✅ Loop playback
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
        
        // ✅ Start playing silently
        player.play()
    }
    
    // MARK: - Info UI
    private var infoView: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "livephoto")
                Text("Live Photo")
                Spacer()
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(formatDate(photo.createdAt))
                Spacer()
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy • h:mm a"
        return f.string(from: date)
    }
}

