//
//  EditPhotoAnimatedView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 24/03/26.
//

import SwiftUI
import Lottie
import Photos

struct EditPhotoAnimatedView: View {
    
    @State private var openPhotoChooser = false
    
    var body: some View {
        ZStack {
            
            // Glass Background
            RoundedRectangle(cornerRadius: 40)
                .fill(.ultraThinMaterial)
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Lottie Circle View
            ZStack {
                Circle()
                    .fill(Constant.commonBlueGradient)
                    .frame(width: 64, height: 64)
                
                LottieView(name: "Edit")
                    .frame(width: 40, height: 40)
            }
        }
        .onTapGesture {
            openPhotoChooser = true
        }
        .fullScreenCover(isPresented: $openPhotoChooser) {
            PhotoChooseView()
        }
    }
}

// MARK: - Lottie View
struct LottieView: UIViewRepresentable {
    
    var name: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .loop
        animationView.play()
        animationView.contentMode = .scaleAspectFit
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
