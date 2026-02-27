//
//  CategoryWallpaperViewModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 27/02/26.
//

import Foundation
import Combine
import Alamofire

class CategoryWallpaperViewModel: ObservableObject {
    @Published var wallpapers: [WallpaperData] = []
    @Published var isLoading = false
    @Published var hasMorePages = true
    
    private var currentPage = 1
    private var currentQuery = ""
    private var totalPages = 1
    private var cancellables = Set<AnyCancellable>()
    private var currentRequestUrl: String {
        return "https://wallhaven.cc/api/v1/search?q=\(currentQuery)&ratios=portrait&atleast=1080x1920&page=\(currentPage)"
    }
    
    func fetchWallpapers(for query: String, loadMore: Bool = false) {
        // Cancel any ongoing request
        NetworkManager.cancelRequest(url: currentRequestUrl)
        
        // Prevent multiple simultaneous loads
        guard !isLoading else { return }
        
        // If loading more and no more pages, return
        if loadMore && !hasMorePages {
            return
        }
        
        isLoading = true
        currentQuery = query
        
        // Set page number
        if !loadMore {
            currentPage = 1
            hasMorePages = true
            // Clear existing data when not loading more
            wallpapers.removeAll()
        } else {
            currentPage += 1
        }
        
        NetworkManager.callWebService(
            url: currentRequestUrl,
            httpMethod: .get,
            params: [:],
            encoding: URLEncoding.default,
            headers: [:]
        ) { [weak self] (response: WallpaperModel) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let meta = response.meta {
                    self.totalPages = meta.last_page ?? 1
                    self.hasMorePages = self.currentPage < self.totalPages
                }
                
                let newWallpapers = response.data ?? []
                
                if loadMore {
                    // Append for pagination
                    self.wallpapers.append(contentsOf: newWallpapers)
                } else {
                    // Replace for fresh load
                    self.wallpapers = newWallpapers
                }
                
                self.isLoading = false
            }
        } callbackFailure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadMore() {
        guard !isLoading && hasMorePages else { return }
        fetchWallpapers(for: currentQuery, loadMore: true)
    }
    
    deinit {
        NetworkManager.cancelRequest(url: currentRequestUrl)
        print("🗑️ CategoryWallpaperViewModel deallocated")
    }
}

