//
//  ImageEditorView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/03/26.
//

import SwiftUI

struct ImageEditorView: View {
    
    @State private var showPicker = false
    @State private var showEditedList = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                
                // MARK: Top Bar
                HStack {
                    Text("Image Editor")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        showEditedList = true
                    } label: {
                        Image("editer_photo_ic")
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // MARK: Dotted Box
                VStack(spacing: 12) {
                    
                    Text("Select Your Image")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Choose any image and customize it with editing tools.")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#838391"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // MARK: Browse Button
                    Button {
                        showPicker = true
                    } label: {
                        Text("Browse Image")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: 220)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color("gradientOne"),
                                        Color("gradientTwo")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        .foregroundColor(Color("gradientOne"))
                )
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        .navigationDestination(isPresented: $showPicker) {
            PhotoChooseView()
        }
        .navigationDestination(isPresented: $showEditedList) {
            EditedPhotoListView()
        }
    }
}
