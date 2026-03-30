//
//  PhotoFeaturesView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 24/03/26.
//

import SwiftUI
import Photos

struct PhotoFeaturesView: View {
    
    let onTap: (PhotoFeature) -> Void
    
    let icons = ["draw_ic", "crop_ic", "text_ic", "filter_ic", "adjust_ic", "blur_ic"]
    
    // Dynamic square size based on device
    private var squareSize: CGFloat {
        Device.isIpad ? 88 : 64
    }
    
    // Dynamic icon size based on device
    private var iconSize: CGFloat {
        Device.isIpad ? 36 : 26
    }
    
    // Dynamic corner radius based on device
    private var cornerRadius: CGFloat {
        Device.isIpad ? 24 : 18
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Device.isIpad ? 18 : 14) {
                
                ForEach(0..<icons.count, id: \.self) { i in
                    
                    Button {
                        if let feature = PhotoFeature(rawValue: i) {
                            onTap(feature)
                        }
                    } label: {
                        
                        ZStack {
                            
                            // ✅ Rounded Square Background (20% white)
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                            
                            // ✅ Icon
                            Image(icons[i])
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconSize, height: iconSize)
                                .foregroundColor(.white)
                        }
                        .frame(width: squareSize, height: squareSize) // Square
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
}
