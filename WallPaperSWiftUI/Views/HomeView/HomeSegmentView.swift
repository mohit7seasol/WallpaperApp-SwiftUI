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
                    EditedPhotoListView()
                }
            }
            .ignoresSafeArea()
            
            // MARK: Bottom Segment
            VStack {
                Spacer()
                
                CustomSegmentBar(selectedIndex: $selectedIndex)
                    .padding(.bottom, 20)
            }
        }
    }
}
// MARK: - CustomSegmentBar
struct CustomSegmentBar: View {
    
    @Binding var selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 0) {
            
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
        .background(
            Group {
                if AppVersion.isIOS26 {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial) // Liquid glass
                } else {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.15))
                        .background(.ultraThinMaterial)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 24)
    }
    
    // MARK: Segment Item
    func segmentItem(index: Int, title: String, selectedIcon: String, unselectedIcon: String) -> some View {
        
        let isSelected = selectedIndex == index
        
        return Button {
            withAnimation {
                selectedIndex = index
            }
        } label: {
            HStack(spacing: 8) {
                Image(isSelected ? selectedIcon : unselectedIcon)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "#4F4FC2") : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                    }
                }
            )
        }
    }
}
