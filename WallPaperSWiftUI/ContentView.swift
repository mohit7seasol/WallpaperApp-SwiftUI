//
//  ContentView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/02/26.
//

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
////        WallpaperListView()
//        HomeView()
//    }
//}
//
//#Preview {
//    ContentView()
//}
import SwiftUI

struct ContentView: View {
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .dark
    }

    var body: some View {
        NavigationStack {
            SplashView()
        }
    }
}

#Preview {
    ContentView()
}
