//
//  VideoPickerSheet.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 05/03/26.
//

import SwiftUI
import PhotosUI

struct VideoPickerSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .videos
                ) {
                    Text("Select Video")
                        .font(.title3)
                }
            }
            .navigationTitle("Choose Video")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
