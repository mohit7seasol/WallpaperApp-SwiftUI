//
//  TrendingWallpaperViewModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 27/02/26.
//

import Foundation
import Combine
import Alamofire

class TrendingWallpaperViewModel: ObservableObject {
    @Published var wallpapers: [PexelWallpaperData] = []
    @Published var isLoading = false
    @Published var hasMorePages = true
    @Published var totalCount = 0
    
    private var currentPage = 1
    private var totalPages = 1
    private var currentCategory = "trending"
    
    private var currentRequestUrl: String {
        return "\(WebService.apiPrefixUrl)\(currentCategory)"
    }
    
    func fetchTrendingWallpapers(loadMore: Bool = false) {
        // Cancel any ongoing request
        NetworkManager.cancelRequest(url: currentRequestUrl)
        
        // Prevent multiple simultaneous loads
        guard !isLoading else { return }
        
        // If loading more and no more pages, return
        if loadMore && !hasMorePages {
            return
        }
        
        isLoading = true
        
        // Set page number
        if !loadMore {
            currentPage = 1
            hasMorePages = true
            // Clear existing data when not loading more
            wallpapers.removeAll()
        } else {
            currentPage += 1
        }
        
        var parameters: Parameters = [:]
        parameters["page"] = currentPage
        parameters["limit"] = 20
        
        NetworkManager.callWebService(
            url: currentRequestUrl,
            httpMethod: .get,
            params: parameters,
            encoding: URLEncoding.default,
            headers: [:] // Empty headers since bearer token is not needed
        ) { [weak self] (response: PexelWallpaperResponse) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.totalPages = response.totalPages
                self.totalCount = response.total
                self.hasMorePages = self.currentPage < self.totalPages
                
                if loadMore {
                    // Append for pagination
                    self.wallpapers.append(contentsOf: response.data)
                } else {
                    // Replace for fresh load
                    self.wallpapers = response.data
                }
                
                self.isLoading = false
                print("📱 Loaded page \(self.currentPage)/\(self.totalPages) - Total: \(self.totalCount) images")
            }
        } callbackFailure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                print("❌ Error loading trending: \(error.localizedDescription)")
            }
        }
    }
    
    func loadMore() {
        guard !isLoading && hasMorePages else { return }
        fetchTrendingWallpapers(loadMore: true)
    }
    
    func refresh() {
        wallpapers.removeAll()
        fetchTrendingWallpapers(loadMore: false)
    }
    
    deinit {
        NetworkManager.cancelRequest(url: currentRequestUrl)
        print("🗑️ TrendingWallpaperViewModel deallocated")
    }
}
