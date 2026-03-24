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
    
    let icons = ["pencil", "crop", "textformat", "camera.filters", "slider.horizontal.3", "drop"]
    let labels = ["Draw", "Crop", "Text", "Filter", "Adjust", "Blur"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(0..<icons.count, id: \.self) { i in
                    Button {
                        if let feature = PhotoFeature(rawValue: i) {
                            onTap(feature)
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: icons[i])
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                                .frame(width: 50, height: 50)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(12)
                            
                            Text(labels[i])
                                .font(.custom("Urbanist-Medium", size: 11))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .padding(.bottom, 10)
    }
}
