//
//  VideoTrimmingComponent.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 06/03/26.
//

import SwiftUI

struct VideoTrimmingComponent: View {
    
    @Binding var startTime: Double
    @Binding var endTime: Double
    
    let videoDuration: Double
    let speedMultiplier: Double
    let isFinalDurationValid: Bool
    
    let formatTime: (Double)->String
    let onStartChanged: ()->Void
    let onEndChanged: ()->Void
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            HStack{
                Text("Trim Video".localized(language))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Max 5 Seconds".localized(language))
                    .font(.caption)
                    .foregroundColor(Color(red: 153/255, green: 147/255, blue: 177/255))
            }
            
            HStack(spacing:10){
                
                TrimInfoBox(
                    title: "Start".localized(language),
                    value: formatTime(startTime),
                    color: .orange
                )
                
                TrimInfoBox(
                    title: "Duration".localized(language),
                    value: formatTime(endTime-startTime),
                    color: .blue
                )
                
                TrimInfoBox(
                    title: "End".localized(language),
                    value: formatTime(endTime),
                    color: .purple
                )
            }
            
            if videoDuration > 0 {
                RangeSlider(
                    lowerValue: $startTime,
                    upperValue: $endTime,
                    minimumValue: 0,
                    maximumValue: videoDuration,
                    step: 0.1,
                    maxRange: min(5.0 * speedMultiplier, videoDuration)
                )
                .frame(height:40)
                .onChange(of: startTime){_,_ in onStartChanged()}
                .onChange(of: endTime){_,_ in onEndChanged()}
            }
            
            if !isFinalDurationValid {
                Text("Max Duration Reached".localized(language))
                    .font(.caption)
                    .padding(.horizontal,16)
                    .padding(.vertical,6)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
            
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
