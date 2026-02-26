//
//  WallpaperListView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/02/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct WallpaperListView: View {
    @StateObject private var viewModel = WallpaperViewModel()
    @State private var selectedWallpaper: Wallpaper?
    @State private var scrollOffset: CGFloat = 0
    @State private var columnHeights: [Int: CGFloat] = [:]
    
    let numberOfColumns = 3
    let cellSpacing: CGFloat = 8
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.1),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading && viewModel.wallpapers.isEmpty {
                    // Loading state
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Loading Wallpapers...")
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 20)
                            .font(.system(size: 16, weight: .medium))
                    }
                } else if let errorMessage = viewModel.errorMessage, viewModel.wallpapers.isEmpty {
                    // Error state
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .font(.system(size: 16, weight: .medium))
                        
                        Button(action: {
                            viewModel.refreshWallpapers()
                        }) {
                            Text("Try Again")
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                )
                        }
                    }
                } else {
                    // Dynamic Wallpaper grid
                    ScrollView {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                        }
                        .frame(height: 0)
                        
                        DynamicGridLayout(
                            items: viewModel.wallpapers,
                            numberOfColumns: numberOfColumns,
                            spacing: cellSpacing
                        ) { wallpaper in
                            WallpaperCell(wallpaper: wallpaper)
                                .onTapGesture {
                                    selectedWallpaper = wallpaper
                                }
                        }
                        .padding(.horizontal, cellSpacing)
                        .padding(.top, 10)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                    .refreshable {
                        viewModel.refreshWallpapers()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Wallpapers")
                            .font(.system(size: scrollOffset < -20 ? 24 : 28, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: scrollOffset)
                        
                        if scrollOffset < -20 {
                            Text("\(viewModel.wallpapers.count) amazing wallpapers")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .transition(.opacity)
                        }
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.9),
                        Color.black.opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(item: $selectedWallpaper) { wallpaper in
                FullScreenImageView(wallpaper: wallpaper)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if viewModel.wallpapers.isEmpty {
                viewModel.fetchWallpapers()
            }
        }
    }
}

// MARK: - Dynamic Grid Layout
struct DynamicGridLayout<Content: View, Item: Identifiable>: View where Item.ID == UUID {
    let items: [Item]
    let numberOfColumns: Int
    let spacing: CGFloat
    let content: (Item) -> Content
    
    @State private var columnHeights: [Int: CGFloat] = [:]
    @State private var itemFrames: [UUID: CGRect] = [:]
    
    init(items: [Item], numberOfColumns: Int, spacing: CGFloat, @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.numberOfColumns = max(1, numberOfColumns)
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let columnWidth = (geometry.size.width - (CGFloat(numberOfColumns - 1) * spacing)) / CGFloat(numberOfColumns)
            
            HStack(alignment: .top, spacing: spacing) {
                ForEach(0..<numberOfColumns, id: \.self) { columnIndex in
                    VStack(spacing: spacing) {
                        ForEach(itemsForColumn(columnIndex)) { item in
                            content(item)
                                .frame(width: columnWidth)
                                .background(
                                    GeometryReader { itemGeometry in
                                        Color.clear
                                            .preference(
                                                key: ItemFramePreferenceKey.self,
                                                value: [item.id: itemGeometry.frame(in: .named("grid"))]
                                            )
                                    }
                                )
                        }
                    }
                }
            }
            .coordinateSpace(name: "grid")
            .onPreferenceChange(ItemFramePreferenceKey.self) { frames in
                for (id, frame) in frames {
                    itemFrames[id] = frame
                }
                updateColumnHeights()
            }
        }
        .frame(height: totalHeight)
    }
    
    private func itemsForColumn(_ columnIndex: Int) -> [Item] {
        let itemsPerColumn = items.enumerated().filter { $0.offset % numberOfColumns == columnIndex }.map { $0.element }
        return itemsPerColumn
    }
    
    private func updateColumnHeights() {
        var heights: [Int: CGFloat] = [:]
        
        for (index, item) in items.enumerated() {
            let columnIndex = index % numberOfColumns
            if let frame = itemFrames[item.id] {
                heights[columnIndex] = max(heights[columnIndex] ?? 0, frame.maxY)
            }
        }
        
        columnHeights = heights
    }
    
    private var totalHeight: CGFloat {
        columnHeights.values.max() ?? 0
    }
}

// MARK: - Preference Keys
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ItemFramePreferenceKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - Wallpaper Cell
struct WallpaperCell: View {
    let wallpaper: Wallpaper
    @State private var imageHeight: CGFloat = 200 // Default height
    
    var body: some View {
        WebImage(url: URL(string: wallpaper.url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    ProgressView()
                        .tint(.white)
                )
        }
        .onSuccess { image, data, cacheType in
            // Calculate height based on image aspect ratio
            let aspectRatio = image.size.height / image.size.width
            let screenWidth = UIScreen.main.bounds.width
            let columnWidth = (screenWidth - (CGFloat(16) * 2) - (CGFloat(2) * 8)) / 3 // Approximate calculation
            imageHeight = columnWidth * aspectRatio
        }
        .frame(height: imageHeight)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(0.3),
                            .white.opacity(0.1),
                            .clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Full Screen Image View
struct FullScreenImageView: View {
    let wallpaper: Wallpaper
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showSaveConfirmation = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            WebImage(url: URL(string: wallpaper.url)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 1), 4)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                if scale > 1 {
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                    .simultaneousGesture(
                        TapGesture(count: 2)
                            .onEnded {
                                withAnimation(.spring()) {
                                    if scale > 1 {
                                        scale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        scale = 2
                                    }
                                }
                            }
                    )
            } placeholder: {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
            
            // Close button
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Download button
                    Button(action: {
                        saveImageToPhotos()
                        showSaveConfirmation = true
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
                    }
                    .padding()
                    .alert("Success", isPresented: $showSaveConfirmation) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Image saved to photos successfully!")
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func saveImageToPhotos() {
        guard let url = URL(string: wallpaper.url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                
                DispatchQueue.main.async {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
        }.resume()
    }
}
