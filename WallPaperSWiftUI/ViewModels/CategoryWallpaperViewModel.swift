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
    @Published var wallpapers: [PexelWallpaperData] = []
    @Published var isLoading = false
    @Published var hasMorePages = true
    @Published var totalCount = 0
    
    private var currentPage = 1
    private var currentQuery = ""
    private var totalPages = 1
    private var cancellables = Set<AnyCancellable>()
    
    private var currentRequestUrl: String {
        return "\(WebService.apiPrefixUrl)\(currentQuery)"
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
                print("📱 Loaded page \(self.currentPage)/\(self.totalPages) for category: \(query)")
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
