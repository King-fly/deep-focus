import SwiftUI

enum AppView {
    case home
    case focus(duration: Int)
    case rest
    case stats
}

struct ContentView: View {
    @Environment(FocusStore.self) private var store
    @State private var currentView: AppView = .home
    
    var body: some View {
        ZStack {
            AppDesign.bgMain.edgesIgnoringSafeArea(.all)
            
            Group {
                switch currentView {
                case .home:
                    HomeView(currentView: $currentView)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                case .focus(let duration):
                    FocusTimerView(currentView: $currentView, duration: duration)
                        .transition(.opacity.combined(with: .scale(scale: 1.05)))
                case .rest:
                    RestView(currentView: $currentView)
                        .transition(.opacity)
                case .stats:
                    StatsView(currentView: $currentView)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentView)
        }
    }
}

extension AppView: Equatable {
    static func == (lhs: AppView, rhs: AppView) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home): return true
        case (.rest, .rest): return true
        case (.stats, .stats): return true
        case (.focus(let l), .focus(let r)): return l == r
        default: return false
        }
    }
}

