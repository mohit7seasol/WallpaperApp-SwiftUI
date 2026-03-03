//
//  MyLottieView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 03/03/26.
//

import Foundation
import Lottie
import SwiftUI


struct MyLottieView: UIViewRepresentable {
    var animationFileName: String
    let loopMode: LottieLoopMode
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        let animationView = LottieAnimationView(name: animationFileName)
        animationView.loopMode = loopMode
        animationView.play()
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        return containerView
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}


struct MyLottie {
    static var languageLottie = "LanguageLottie"
}
