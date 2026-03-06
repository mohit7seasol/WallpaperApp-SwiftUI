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
        trimmedVideoURL == nil ? "Trim Video First" : "Create Live Wallpaper"
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
                        Image(systemName: trimmedVideoURL == nil ? "scissors" : "sparkles")
                    }
                    
                    Text(isProcessing ? "Processing..." : buttonTitle)
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
            
            
            // MARK: Preview Button
            
            Button {
                onPreview()
            } label: {
                
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text("Preview Selection")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white.opacity(0.08))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(asset == nil || isProcessing)
            .opacity(asset == nil ? 0.5 : 1)
        }
    }
}
