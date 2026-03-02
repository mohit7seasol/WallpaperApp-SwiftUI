import SwiftUI
import Combine

struct CustomAlertHandler<AlertContent, AlertActions>: ViewModifier where AlertContent: View, AlertActions: View {
    @Environment(\.self) private var environment
    
    var title: Text?
    @Binding var isPresented: Bool
    var windowScene: UIWindowScene
    var alertContent: () -> AlertContent
    var alertActions: () -> AlertActions
    
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content
                .disabled(isPresented)
                .onChange(of: isPresented) { value in
                    if value {
                        AlertWindow.present(on: windowScene) {
                            CustomAlert(title: title, isPresented: $isPresented, content: alertContent, actions: alertActions)
                                .environment(\.self, environment)
                        }
                    } else {
                        AlertWindow.dismiss(on: windowScene)
                    }
                }
                .onAppear {
                    guard isPresented else { return }
                    AlertWindow.present(on: windowScene) {
                        CustomAlert(title: title, isPresented: $isPresented, content: alertContent, actions: alertActions)
                            .environment(\.self, environment)
                    }
                }
                .onDisappear {
                    AlertWindow.dismiss(on: windowScene)
                }
        } else {
            content
                .disabled(isPresented)
                .onReceive(Just(isPresented)) { value in
                    if value {
                        AlertWindow.present(on: windowScene) {
                            CustomAlert(title: title, isPresented: $isPresented, content: alertContent, actions: alertActions)
                                .environment(\.self, environment)
                        }
                    } else {
                        // Cannot use this to hide the alert on iOS 13 because `onReceive`
                        // will get called for all alerts if there are multiple on a single view
                        // causing all alerts to be hidden immediately after appearing
                    }
                }
                .onDisappear {
                    AlertWindow.dismiss(on: windowScene)
                }
        }
    }
}
// MARK: - Toast View Modifier
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.bottom, 30)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(1)
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, message: message))
    }
}
