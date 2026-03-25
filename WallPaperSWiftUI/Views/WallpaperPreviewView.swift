//
//  WallpaperPreviewView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 25/03/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct WallpaperPreviewView: View {
    
    let imageURL: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var previewMode: PreviewMode = .home
    @State private var showDownloadOptions = false
    
    enum PreviewMode {
        case home
        case lock
    }
    
    var body: some View {
        ZStack {
            
            // MARK: - Wallpaper
            WebImage(url: URL(string: imageURL))
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            overlayView
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // ✅ Back Button Only
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            
            // ✅ Download Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDownloadOptions = true
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.white)
                }
            }
        }
        
        // ✅ TAP TO CHANGE MODE
        .onTapGesture {
            withAnimation(.easeInOut) {
                switch previewMode {
                case .home:
                    previewMode = .lock
                case .lock:
                    previewMode = .home
                }
            }
        }
        
        .actionSheet(isPresented: $showDownloadOptions) {
            ActionSheet(
                title: Text("Download"),
                buttons: [
                    .default(Text("Download")) {
                        downloadImage(from: imageURL)
                    },
                    .cancel()
                ]
            )
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - OVERLAY SWITCH
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    @ViewBuilder
    var overlayView: some View {
        switch previewMode {
        case .home:
            homePreview
        case .lock:
            lockPreview
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - HOME PREVIEW (FULL UI)
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    var homePreview: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // MARK: Weather and Photos Widgets
                HStack(spacing: 16) {
                    // Weather Widget
                    Image("weather_ic")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 140)
                        .cornerRadius(20)
                    
                    // Photos Widget
                    Image("photos_ic")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 140)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // MARK: App Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 24) {
                    
                    appIcon("FaceTime_ic", "FaceTime", size: geometry.size.width * 0.12)
                    appIcon("Calendar_ic", "Calendar", size: geometry.size.width * 0.12)
                    appIcon("Gallery_ic", "Photos", size: geometry.size.width * 0.12)
                    appIcon("Camera_ic", "Camera", size: geometry.size.width * 0.12)
                    appIcon("Mail_ic", "Mail", size: geometry.size.width * 0.12)
                    appIcon("Note_ic", "Notes", size: geometry.size.width * 0.12)
                    appIcon("Reminders_ic", "Reminders", size: geometry.size.width * 0.12)
                    appIcon("Clock_ic", "Clock", size: geometry.size.width * 0.12)
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
                
                Spacer(minLength: 0)
                
                // MARK: Bottom Dock with Glass Background
                HStack(spacing: getDockSpacing(for: geometry.size.width)) {
                    dockIcon("Call_ic", size: geometry.size.width * 0.12)
                    dockIcon("Safari_ic", size: geometry.size.width * 0.12)
                    dockIcon("Message_ic", size: geometry.size.width * 0.12)
                    dockIcon("Music_ic", size: geometry.size.width * 0.12)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(
                    Image("Glass_bg")
                        .resizable()
                        .scaledToFill()
                )
                .cornerRadius(30)
                .padding(.horizontal, 20)
                .padding(.bottom, getSafeAreaBottom() + 10)
            }
        }
        .ignoresSafeArea()
    }
    
    func appIcon(_ image: String, _ title: String, size: CGFloat) -> some View {
        VStack(spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white)
                .shadow(radius: 1)
        }
    }
    
    func dockIcon(_ image: String, size: CGFloat) -> some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
    
    func getDockSpacing(for width: CGFloat) -> CGFloat {
        if width >= 1024 { // iPad
            return 40
        } else if width >= 768 { // iPad Mini
            return 30
        } else if width >= 414 { // iPhone Plus/Max
            return 25
        } else { // iPhone
            return 20
        }
    }
    
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
    
    func getSafeAreaTop() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets.top ?? 0
        }
        return 0
    }
    
    func getSafeAreaBottom() -> CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets.bottom ?? 0
        }
        return 0
    }
}

////////////////////////////////////////////////////////////
// MARK: - LOCK PREVIEW
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    var lockPreview: some View {
        VStack(spacing: 10) {
            
            Spacer()
            
            Text(currentDate)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Text(currentTime)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Bottom indicator
            Capsule()
                .fill(Color.white.opacity(0.7))
                .frame(width: 140, height: 5)
                .padding(.bottom, 20)
        }
    }
    
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: Date())
    }
}

////////////////////////////////////////////////////////////
// MARK: - DOWNLOAD
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let loading = UIAlertController(title: "Downloading...", message: nil, preferredStyle: .alert)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(loading, animated: true)
        }
        
        URLSession.shared.downloadTask(with: url) { localURL, _, _ in
            DispatchQueue.main.async {
                
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    root.dismiss(animated: true)
                }
                
                guard let localURL = localURL,
                      let data = try? Data(contentsOf: localURL),
                      let image = UIImage(data: data) else { return }
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }.resume()
    }
}
