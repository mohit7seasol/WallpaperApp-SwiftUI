//
//  VideoProcessingActions.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 06/03/26.
//

import SwiftUI
import AVFoundation

struct VideoProcessingActions: View {
    
    @Binding var speedMultiplier: Double
    @Binding var isProcessing: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    let asset: AVAsset?
    let startTime: Double
    let endTime: Double
    let canProcess: Bool
    let trimmedVideoURL: URL?
    
    let onCreateWallpaper: () -> Void
    let onPreview: () -> Void
    
    // MARK: Computed
    
    private var duration: Double {
        endTime - startTime
    }
    
    private var finalDuration: Double {
        duration / speedMultiplier
    }
    
    private var isValid: Bool {
        duration > 0 && finalDuration <= 5.0
    }
    
    private var buttonTitle: String {
        trimmedVideoURL == nil ? "Trim Video First".localized(language) : "Create Live Wallpaper".localized(language)
    }
    
    private var canExecute: Bool {
        trimmedVideoURL == nil ? isValid : true
    }
    
    // MARK: UI
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            // MARK: Main Button
            
            Button {
                onCreateWallpaper()
            } label: {
                
                HStack(spacing: 10) {
                    
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        // Changed from "scissors" to "scissors.circle.fill" as requested
                        Image(systemName: trimmedVideoURL == nil ? "scissors.circle.fill" : "sparkles")
                            .font(.title3)
                    }
                    
                    Text(isProcessing ? "Processing...".localized(language) : buttonTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    canExecute && !isProcessing
                    ? Color.indigo
                    : Color.gray
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!canExecute || isProcessing)
        }
    }
}
