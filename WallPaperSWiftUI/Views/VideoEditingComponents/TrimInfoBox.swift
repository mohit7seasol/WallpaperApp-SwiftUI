//
//  TrimInfoBox.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 06/03/26.
//

import SwiftUI

struct TrimInfoBox: View {
    
    let title:String
    let value:String
    let color:Color
    
    var body: some View {
        VStack(spacing:6){
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth:.infinity)
        .padding()
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius:12))
    }
}
