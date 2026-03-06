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
                
                // Track - Unselected range in white (background)
                Capsule()
                    .fill(Color.white)  // Changed to white as requested
                    .frame(height: 6)
                
                // Selected Range (indigo color)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.indigo, Color.indigo.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(0, selectedWidth(width)),
                        height: 8  // Slightly taller for better visibility
                    )
                    .offset(x: lowerOffset(width))
                    .shadow(color: .indigo.opacity(0.3), radius: 2, x: 0, y: 1)
                
                // Lower Thumb with enhanced interaction
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Circle()
                        .stroke(Color.indigo, lineWidth: 3)
                        .frame(width: thumbSize - 2, height: thumbSize - 2)
                        .scaleEffect(draggingLower ? 1.2 : 1.0)
                    
                    // Value indicator when dragging
                    if draggingLower {
                        Text(formatTime(lowerValue))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.indigo)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(y: -40)
                    }
                }
                .offset(x: lowerOffset(width) - thumbSize/2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                draggingLower = true
                                moveLower(value.location.x, width: width)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                draggingLower = false
                            }
                        }
                )
                
                // Upper Thumb with enhanced interaction
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Circle()
                        .stroke(Color.indigo, lineWidth: 3)
                        .frame(width: thumbSize - 2, height: thumbSize - 2)
                        .scaleEffect(draggingUpper ? 1.2 : 1.0)
                    
                    // Value indicator when dragging
                    if draggingUpper {
                        Text(formatTime(upperValue))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.indigo)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(y: -40)
                    }
                }
                .offset(x: upperOffset(width) - thumbSize/2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                draggingUpper = true
                                moveUpper(value.location.x, width: width)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                draggingUpper = false
                            }
                        }
                )
                
                // Max range indicator (when near limit)
                if (upperValue - lowerValue) >= maxRange * 0.95 {
                    Text("MAX")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                        .offset(x: (lowerOffset(width) + upperOffset(width)) / 2 - 15, y: -20)
                        .transition(.opacity)
                }
            }
        }
        .frame(height: thumbSize + 20) // Extra space for indicators
    }
    
    // Helper to format time values for tooltips
    private func formatTime(_ value: Double) -> String {
        let minutes = Int(value) / 60
        let seconds = Int(value) % 60
        let milliseconds = Int((value - Double(Int(value))) * 100)
        
        if minutes > 0 {
            return String(format: "%d:%02d.%02d", minutes, seconds, milliseconds)
        } else {
            return String(format: "0:%02d.%02d", seconds, milliseconds)
        }
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

// MARK: - Drag Logic (Enhanced from reference code)

extension RangeSlider {
    
    private func moveLower(_ x: CGFloat, width: CGFloat) {
        // Calculate percentage based on drag position
        let percent = max(0, min(1, x / width))
        let newValue = minimumValue + percent * (maximumValue - minimumValue)
        
        // Round to nearest step
        let steppedValue = round(newValue / step) * step
        
        // Enforce maximum range constraint
        let potentialRange = upperValue - steppedValue
        
        if potentialRange > maxRange {
            // Calculate new upper value to maintain maxRange
            let newUpperValue = steppedValue + maxRange
            if newUpperValue <= maximumValue {
                // If we can move upper thumb within bounds, do it
                upperValue = newUpperValue
            } else {
                // If upper thumb can't move further, limit lower thumb
                lowerValue = upperValue - maxRange
                return
            }
        }
        
        // Constrain and apply lower value
        let constrainedValue = min(max(steppedValue, minimumValue), upperValue - step)
        lowerValue = constrainedValue
    }
    
    private func moveUpper(_ x: CGFloat, width: CGFloat) {
        // Calculate percentage based on drag position
        let percent = max(0, min(1, x / width))
        let newValue = minimumValue + percent * (maximumValue - minimumValue)
        
        // Round to nearest step
        let steppedValue = round(newValue / step) * step
        
        // Enforce maximum range constraint
        let potentialRange = steppedValue - lowerValue
        
        if potentialRange > maxRange {
            // Calculate new lower value to maintain maxRange
            let newLowerValue = steppedValue - maxRange
            if newLowerValue >= minimumValue {
                // If we can move lower thumb within bounds, do it
                lowerValue = newLowerValue
            } else {
                // If lower thumb can't move further, limit upper thumb
                upperValue = lowerValue + maxRange
                return
            }
        }
        
        // Constrain and apply upper value
        let constrainedValue = min(max(steppedValue, lowerValue + step), maximumValue)
        upperValue = constrainedValue
    }
}

#Preview {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
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
}
