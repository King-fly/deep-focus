import SwiftUI

struct RestView: View {
    @Binding var currentView: AppView
    
    @State private var timeRemaining = 5 * 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppDesign.green.opacity(0.1))
                        .frame(width: 96, height: 96)
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppDesign.green)
                }
                
                VStack(spacing: 8) {
                    Text("休息一下")
                        .font(.system(.largeTitle, design: .rounded)).bold()
                        .foregroundColor(AppDesign.textMain)
                    
                    Text("专注完成，深呼吸，放松大脑")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(AppDesign.textSecondary)
                }
            }
            
            Spacer()
                .frame(height: 60)
            
            Text(timeString)
                .font(.system(size: 104, weight: .heavy, design: .rounded))
                .foregroundColor(AppDesign.green)
                .monospacedDigit()
            
            Spacer()
            
            Button(action: {
                currentView = .home
            }) {
                Text("结束休息")
                    .font(.system(.title3, design: .rounded)).bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .foregroundColor(.white)
            }
            .buttonStyle(DuolingoButtonStyle(color: AppDesign.green, shadowColor: AppDesign.greenShadow))
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
                currentView = .home
            }
        }
    }
    
    private var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }
}
