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
    
    // Add this to track if we're coming back from editor
    @State private var isNavigating = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
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
                Text("Live Wallpaper Creator".localized(language))
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                
                // Subtitle
                Text("Transform your videos into stunning Live Wallpapers".localized(language))
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // PhotosPicker directly opens Gallery
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .videos,
                    photoLibrary: .shared()
                ) {
                    Text("Choose Your Video".localized(language))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#5A5ED9"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                
                .navigationDestination(isPresented: $navigateToEditor) {
                    if let videoURL = selectedVideoURL {
                        VideoEditingView(videoURL: videoURL)
                            .onDisappear {
                                // Reset state when coming back from editor
                                resetSelection()
                            }
                    }
                }
            }
        }
        .navigationTitle("Choose Video".localized(language))
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { newValue in
            if let newItem = newValue {
                loadVideo(from: newItem)
            }
        }
        // Request permission when view appears
        .onAppear {
            requestPhotoLibraryAccess()
        }
    }
    
    // MARK: Request Photo Library Permission
    
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    print("✅ Photo library access granted")
                case .denied, .restricted:
                    print("❌ Photo library access denied")
                    // Optionally show an alert to guide user to settings
                case .notDetermined:
                    print("⚠️ Photo library access not determined")
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: Load Selected Video
    
    func loadVideo(from item: PhotosPickerItem) {
        
        // Show loading indicator (optional)
        // You can add a @State loading variable and show ProgressView
        
        Task {
            do {
                // Load video data
                if let data = try? await item.loadTransferable(type: Data.self) {
                    
                    // Create unique filename to avoid conflicts
                    let fileName = "selectedVideo_\(UUID().uuidString).mov"
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(fileName)
                    
                    // Remove existing file if any
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    
                    // Write new data
                    try data.write(to: tempURL)
                    
                    await MainActor.run {
                        selectedVideoURL = tempURL
                        navigateToEditor = true
                    }
                }
            } catch {
                print("Error loading video: \(error)")
                // Handle error (show alert)
            }
        }
    }
    
    // MARK: Reset Selection
    
    func resetSelection() {
        // Clear the selected item to allow reselection
        selectedItem = nil
        
        // Optional: Clean up temporary file
        if let oldURL = selectedVideoURL {
            try? FileManager.default.removeItem(at: oldURL)
        }
        
        selectedVideoURL = nil
        navigateToEditor = false
    }
}

