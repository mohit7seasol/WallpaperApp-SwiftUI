//
//  HomeSegmentView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 25/03/26.
//

import SwiftUI

struct HomeSegmentView: View {
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        ZStack {
            
            // MARK: Content Switching
            Group {
                if selectedIndex == 0 {
                    HomeView()
                } else {
                    ImageEditorView()
                }
            }
            .ignoresSafeArea()
            
            // MARK: Bottom Segment
            VStack {
                Spacer()
                
                CustomSegmentBar(selectedIndex: $selectedIndex)
                    .padding(.bottom, Device.bottomSafeArea)
            }
        }
    }
}
// MARK: - CustomSegmentBar
struct CustomSegmentBar: View {
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 6) {
            
            segmentItem(
                index: 0,
                title: "Home",
                selectedIcon: "home_selected_ic",
                unselectedIcon: "home_unselected_ic"
            )
            
            segmentItem(
                index: 1,
                title: "Editor",
                selectedIcon: "editor_seg_selected_ic",
                unselectedIcon: "editor_seg_unselected_ic"
            )
        }
        .padding(6)
        .frame(height: 60) // ✅ exact height
        .background(
            Group {
                if AppVersion.isIOS26 {
                    Capsule()
                        .fill(.ultraThinMaterial)
                } else {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial)
                }
            }
        )
        .clipShape(Capsule())
        .padding(.horizontal, 25) // ✅ exact padding
    }
    
    // MARK: Segment Item
    func segmentItem(index: Int, title: String, selectedIcon: String, unselectedIcon: String) -> some View {
        
        let isSelected = selectedIndex == index
        
        return Button {
            withAnimation(.easeInOut) {
                selectedIndex = index
            }
        } label: {
            HStack(spacing: 8) {
                
                Image(isSelected ? selectedIcon : unselectedIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(
                        isSelected ? Color(hex: "#4F4FC2") : .white.opacity(0.9)
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                ZStack {
                    
                    if isSelected {
                        // ✅ Selected (white pill)
                        Capsule()
                            .fill(Color.white)
                    } else {
                        // ✅ Unselected (glass dark effect like screenshot)
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
            )
        }
    }
}
