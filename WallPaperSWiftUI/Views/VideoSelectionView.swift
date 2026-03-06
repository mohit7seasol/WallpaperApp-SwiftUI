//
//  VideoSelectionView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 05/03/26.
//

import SwiftUI
import PhotosUI
import Lottie

struct VideoSelectionView: View {
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedVideoURL: URL?
    @State private var navigateToEditor = false
    
    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Spacer()
                
                // Lottie Animation
                MyLottieView(animationFileName: "Add", loopMode: .loop)
                    .frame(
                        width: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 160,
                        height: UIDevice.current.userInterfaceIdiom == .pad ? 200 : 160
                    )
                    .offset(y: -40)
                
                // Title
                Text("Live Wallpaper Creator")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                
                // Subtitle
                Text("Transform your videos into stunning Live Wallpapers")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // PhotosPicker directly opens Gallery
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .videos
                ) {
                    Text("Choose Your Video")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#5A5ED9"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                
                NavigationLink(
                    destination: VideoEditingView(videoURL: selectedVideoURL ?? URL(fileURLWithPath: "")),
                    isActive: $navigateToEditor
                ) {
                    EmptyView()
                }
            }
        }
        .navigationTitle("Choose Video")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { _, newItem in
            loadVideo(from: newItem)
        }
    }
    
    
    // MARK: Load Selected Video
    
    func loadVideo(from item: PhotosPickerItem?) {
        
        guard let item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("selectedVideo.mov")
                
                try? data.write(to: tempURL)
                
                await MainActor.run {
                    selectedVideoURL = tempURL
                    navigateToEditor = true
                }
            }
        }
    }
    
    
    // MARK: Video Editing Interface
    
    func videoEditingInterface() -> some View {
        
        VStack {
            Text("Video Editing Screen")
                .font(.title)
                .foregroundColor(.white)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}
