//
//  RangeSlider.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 06/03/26.
//

import SwiftUI

struct RangeSlider: View {
    
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    
    let minimumValue: Double
    let maximumValue: Double
    let step: Double
    let maxRange: Double
    
    @State private var draggingLower = false
    @State private var draggingUpper = false
    
    private let thumbSize: CGFloat = 26
    
    var body: some View {
        
        GeometryReader { geo in
            
            let width = geo.size.width
            
            ZStack(alignment: .leading) {
                
                // Track
                Capsule()
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 6)
                
                // Selected Range
                Capsule()
                    .fill(Color.indigo)
                    .frame(
                        width: selectedWidth(width),
                        height: 6
                    )
                    .offset(x: lowerOffset(width))
                
                // Lower Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(radius: 3)
                    .overlay(
                        Circle()
                            .stroke(Color.indigo, lineWidth: 3)
                    )
                    .offset(x: lowerOffset(width) - thumbSize/2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                draggingLower = true
                                moveLower(value.location.x, width: width)
                            }
                            .onEnded { _ in
                                draggingLower = false
                            }
                    )
                
                // Upper Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(radius: 3)
                    .overlay(
                        Circle()
                            .stroke(Color.indigo, lineWidth: 3)
                    )
                    .offset(x: upperOffset(width) - thumbSize/2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                draggingUpper = true
                                moveUpper(value.location.x, width: width)
                            }
                            .onEnded { _ in
                                draggingUpper = false
                            }
                    )
            }
        }
        .frame(height: 40)
    }
}

// MARK: - Calculations

extension RangeSlider {
    
    private func percentage(_ value: Double) -> Double {
        (value - minimumValue) / (maximumValue - minimumValue)
    }
    
    private func lowerOffset(_ width: CGFloat) -> CGFloat {
        CGFloat(percentage(lowerValue)) * width
    }
    
    private func upperOffset(_ width: CGFloat) -> CGFloat {
        CGFloat(percentage(upperValue)) * width
    }
    
    private func selectedWidth(_ width: CGFloat) -> CGFloat {
        upperOffset(width) - lowerOffset(width)
    }
}

// MARK: - Drag Logic

extension RangeSlider {
    
    private func moveLower(_ x: CGFloat, width: CGFloat) {
        
        let percent = max(0, min(1, x / width))
        let newValue = minimumValue + percent * (maximumValue - minimumValue)
        let stepped = round(newValue / step) * step
        
        let limited = min(stepped, upperValue - step)
        
        if upperValue - limited > maxRange {
            lowerValue = upperValue - maxRange
        } else {
            lowerValue = max(minimumValue, limited)
        }
    }
    
    private func moveUpper(_ x: CGFloat, width: CGFloat) {
        
        let percent = max(0, min(1, x / width))
        let newValue = minimumValue + percent * (maximumValue - minimumValue)
        let stepped = round(newValue / step) * step
        
        let limited = max(stepped, lowerValue + step)
        
        if limited - lowerValue > maxRange {
            upperValue = lowerValue + maxRange
        } else {
            upperValue = min(maximumValue, limited)
        }
    }
}

#Preview {
    
    RangeSlider(
        lowerValue: .constant(2),
        upperValue: .constant(6),
        minimumValue: 0,
        maximumValue: 10,
        step: 0.1,
        maxRange: 5
    )
    .padding()
}
