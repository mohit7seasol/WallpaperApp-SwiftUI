//
//  PhotoChooseView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 24/03/26.
//

import SwiftUI
import Photos
import PhotosUI
import Combine

struct PhotoChooseView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var images: [PhotoAsset] = []
    @State private var isLoading = false
    @State private var selectedImage: PhotoAsset?
    @State private var navigateToEditor = false
    @State private var showPermissionAlert = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @StateObject private var photoObserver = PhotoLibraryObserver()
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App"
    
    var body: some View {
        ZStack {
            Color.appBgColor
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else if images.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No Photos Found".localized(self.language))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Tap below to access your photos".localized(self.language))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button {
                        checkPermission()
                    } label: {
                        Text("Access Photos".localized(self.language))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 160)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "1973E8"),
                                        Color(hex: "0E4082")
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(25)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(images) { img in
                            PhotoThumbnailView(asset: img)
                                .onTapGesture {
                                    selectedImage = img
                                    navigateToEditor = true
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Select Photo".localized(self.language))
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                    Button {
                        showPermissionManagement()
                    } label: {
                        Text("Manage".localized(self.language))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            photoObserver.onChange = {
                loadImages()
            }
            checkPermission()
        }
        .alert("Permission Required".localized(self.language), isPresented: $showPermissionAlert) {
            Button("Cancel".localized(self.language), role: .cancel) { }
            Button("Settings".localized(self.language)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please grant photo library access to select photos".localized(self.language))
        }
        NavigationLink(
            destination: Group {
                if let img = selectedImage {
                    PhotoEditorMainView(asset: img.asset)
                } else {
                    EmptyView()
                }
            },
            isActive: $navigateToEditor
        ) {
            EmptyView()
        }
    }
    
    private func showPermissionManagement() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: rootViewController)
        }
    }
    
    private func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if status == .authorized || status == .limited {
            loadImages()
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        loadImages()
                    } else {
                        showPermissionAlert = true
                    }
                }
            }
        } else {
            showPermissionAlert = true
        }
    }
    
    private func loadImages() {
        isLoading = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let fetch = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var temp: [PhotoAsset] = []
        
        fetch.enumerateObjects { asset, _, _ in
            temp.append(PhotoAsset(asset: asset))
        }
        
        images = temp
        isLoading = false
    }
}

// MARK: - PhotoAsset Model
struct PhotoAsset: Identifiable {
    let id = UUID()
    let asset: PHAsset
}

// MARK: - PhotoThumbnailView
struct PhotoThumbnailView: View {
    let asset: PhotoAsset
    @State private var image: UIImage?
    
    let screenWidth = UIScreen.main.bounds.width
    var cellWidth: CGFloat {
        return (screenWidth - 48) / 3
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cellWidth, height: cellWidth * 1.5)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: cellWidth, height: cellWidth * 1.5)
                    .cornerRadius(12)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: asset.asset,
            targetSize: CGSize(width: 300, height: 300),
            contentMode: .aspectFill,
            options: options
        ) { img, _ in
            if let img = img {
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }
    }
}

// MARK: - LimitAccessPhotoView
struct LimitAccessPhotoView: View {
    let appName: String
    @State private var showManageOptions = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Photo".localized(self.language))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Button {
                    showManageOptions = true
                } label: {
                    Text("Manage".localized(self.language))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(12)
                }
            }
            
            Text("\("You've given".localized(self.language)) \(appName) \("limited access to select number of photos".localized(self.language))")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .alert("Manage".localized(self.language), isPresented: $showManageOptions) {
            Button("Select More Photos".localized(self.language)) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: rootViewController)
                }
            }
            
            Button("Change Settings".localized(self.language)) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Cancel".localized(self.language), role: .cancel) { }
        } message: {
            Text("\("You've given".localized(self.language)) \(appName) \("limited access to select number of photos".localized(self.language))")
        }
    }
}

// MARK: - PhotoLibraryObserver
class PhotoLibraryObserver: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    
    var onChange: (() -> Void)?
    
    override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.onChange?()
        }
    }
}
