//
//  SpeedControlComponent.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 06/03/26.
//

import SwiftUI

struct SpeedControlComponent: View {
    
    @Binding var speedMultiplier: Double
    
    let startTime: Double
    let endTime: Double
    
    let onSpeedChange: (Double) -> Void
    
    private let speeds: [Double] = [1.0, 1.5, 2.0, 2.5]
    
    // MARK: Computed Values
    
    private var originalDuration: Double {
        endTime - startTime
    }
    
    private var finalDuration: Double {
        originalDuration / speedMultiplier
    }
    
    private var isFinalDurationValid: Bool {
        finalDuration <= 5.0
    }
    
    // MARK: Formatter
    
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let secs = seconds.truncatingRemainder(dividingBy: 60)
        
        if minutes > 0 {
            return String(format: "%02d:%04.1f", minutes, secs)
        } else {
            return String(format: "%05.1f", secs)
        }
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            // Header
            HStack {
                Text("Playback Speed")
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Final Duration")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(finalDuration))
                        .font(.caption)
                        .foregroundColor(isFinalDurationValid ? .green : .orange)
                        .fontWeight(.semibold)
                }
            }
            
            // MARK: Speed Buttons
            
            HStack(spacing: 12) {
                ForEach(speeds, id: \.self) { speed in
                    
                    Button {
                        withAnimation(.spring()) {
                            speedMultiplier = speed
                            onSpeedChange(speed)
                        }
                    } label: {
                        
                        VStack(spacing: 4) {
                            
                            Text("\(speed, specifier: "%.1f")x")
                                .font(.headline)
                            
                            Text(speedDescription(speed))
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                            
                            Text(formatTime((endTime - startTime) / speed))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            speedMultiplier == speed
                            ? Color.indigo.opacity(0.25)
                            : Color.gray.opacity(0.15)
                        )
                        .foregroundColor(
                            speedMultiplier == speed ? .white : .primary
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    speedMultiplier == speed
                                    ? Color.indigo
                                    : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                }
            }
            
            // MARK: Preview Info
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Speed Conversion Preview :")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Text("\(formatTime(originalDuration)) at \(speedMultiplier, specifier: "%.1f")x = \(formatTime(finalDuration)) final duration")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    Image(systemName: isFinalDurationValid ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(isFinalDurationValid ? .green : .orange)
                    
                    Text(
                        isFinalDurationValid
                        ? "Perfect! Final duration is within Live Photo limits."
                        : "Final duration exceeds 5 seconds."
                    )
                    .font(.caption)
                    .foregroundColor(isFinalDurationValid ? .green : .orange)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    // MARK: Speed Labels
    
    private func speedDescription(_ speed: Double) -> String {
        switch speed {
        case 1.0: return "Normal\nSpeed"
        case 1.5: return "Smooth\nMotion"
        case 2.0: return "Smooth\nMotion"
        case 2.5: return "Smooth\nMotion"
        default: return ""
        }
    }
}

#Preview {
    SpeedControlComponent(
        speedMultiplier: .constant(1.0),
        startTime: 0,
        endTime: 7.5,
        onSpeedChange: { _ in }
    )
    .padding()
}
