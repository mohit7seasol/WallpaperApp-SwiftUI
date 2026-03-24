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
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                
                ForEach(0..<icons.count, id: \.self) { i in
                    
                    Button {
                        if let feature = PhotoFeature(rawValue: i) {
                            onTap(feature)
                        }
                    } label: {
                        
                        ZStack {
                            
                            // ✅ Rounded Square Background (20% white)
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                            
                            // ✅ Icon
                            Image(icons[i])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundColor(.white)
                        }
                        .frame(width: 64, height: 64) // Square
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
}
