//
//  PhotoEditorMainView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 24/03/26.
//

import SwiftUI
import Photos

// MARK: - Feature Enum
enum PhotoFeature: Int, Identifiable {
    case draw = 0
    case crop
    case text
    case filter
    case adjust
    case blur
    
    var id: Int { rawValue }
}

struct PhotoEditorMainView: View {
    
    let asset: PHAsset
    @Environment(\.dismiss) var dismiss
    
    @State private var image: UIImage?
    @State private var editedImage: UIImage?
    @State private var selectedFeature: PhotoFeature?
    
    var body: some View {
        ZStack {
            // Background
            Constant.previewBlueGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // ✅ IMAGE
                if let displayImage = editedImage ?? image {
                    Image(uiImage: displayImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                } else {
                    Spacer()
                    ProgressView().tint(.white)
                    Spacer()
                }
                
                Spacer()
                
                // ✅ FEATURES TOOLBAR
                PhotoFeaturesView { feature in
                    selectedFeature = feature
                }
                
                // ✅ BOTTOM BUTTONS
                HStack(spacing: 20) {
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(25)
                    }
                    
                    Button {
                        applyChanges()
                    } label: {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "1973E8"),
                                        Color(hex: "0E4082")
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
                .padding(.top, 20)
            }
        }
        // ✅ DEFAULT NAVIGATION BAR
        .navigationTitle("Photo Editor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            loadImage()
        }
        .fullScreenCover(item: $selectedFeature) { feature in
            featureView(feature)
        }
    }
    
    // MARK: - Load Image
    private func loadImage() {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 1200, height: 1200),
            contentMode: .aspectFit,
            options: options
        ) { img, _ in
            DispatchQueue.main.async {
                self.image = img
            }
        }
    }
    
    // MARK: - Apply Changes
    private func applyChanges() {
        if let finalImage = editedImage ?? image {
            UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
            dismiss()
        }
    }
    
    // MARK: - Feature Navigation
    @ViewBuilder
    private func featureView(_ feature: PhotoFeature) -> some View {
        if let currentImage = editedImage ?? image {
            switch feature {
            case .draw:
                DrawView(image: currentImage) { editedImage = $0 }
            case .crop:
                CropView(image: currentImage) { editedImage = $0 }
            case .text:
                TextEditorView(image: currentImage) { editedImage = $0 }
            case .filter:
                FilterView(image: currentImage) { editedImage = $0 }
            case .adjust:
                AdjustView(image: currentImage) { editedImage = $0 }
            case .blur:
                BlurDrawView(image: currentImage) { editedImage = $0 }
            }
        }
    }
}

