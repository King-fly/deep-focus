import SwiftUI

struct FocusTimerView: View {
    @Environment(FocusStore.self) private var store
    @Binding var currentView: AppView
    let duration: Int // Total duration in minutes
    
    @State private var timeRemaining: Int
    @State private var isPaused = false
    @State private var showDistractionModal = false
    @State private var startTime: Date
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(currentView: Binding<AppView>, duration: Int) {
        self._currentView = currentView
        self.duration = duration
        self._timeRemaining = State(initialValue: duration * 60)
        self._startTime = State(initialValue: Date())
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                    Text("专注模式")
                        .font(.system(.caption, design: .rounded)).bold()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppDesign.blue.opacity(0.1))
                .foregroundColor(AppDesign.blue)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppDesign.blue.opacity(0.2), lineWidth: 2))
                
                Spacer()
                
                Button(action: { showDistractionModal = true }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppDesign.textSecondary)
                        .padding(12)
                        .background(AppDesign.surface)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppDesign.border, lineWidth: 2))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            
            Spacer()
            
            // Current Task
            VStack(spacing: 8) {
                Text("当前任务")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(AppDesign.textSecondary)
                    .tracking(2)
                
                Text(currentTaskTitle)
                    .font(.system(.title2, design: .rounded)).bold()
                    .foregroundColor(AppDesign.textMain)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Timer Ring
            ZStack {
                Circle()
                    .stroke(AppDesign.border, lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppDesign.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(AppDesign.blue)
                        .monospacedDigit()
                    Text("剩余时间")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppDesign.textSecondary)
                }
            }
            .frame(width: 300, height: 300)
            
            Spacer()
            
            // Controls
            HStack(spacing: 24) {
                Button(action: {
                    #if os(iOS)
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    #endif
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 64, height: 64)
                        .background(AppDesign.surface)
                        .foregroundColor(AppDesign.blue)
                }
                .buttonStyle(DuolingoGhostButtonStyle())
                
                Button(action: {
                    #if os(iOS)
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    #endif
                    showDistractionModal = true
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("标记分心")
                            .font(.system(.headline, design: .rounded)).bold()
                    }
                    .frame(height: 64)
                    .padding(.horizontal, 24)
                    .foregroundColor(.white)
                }
                .buttonStyle(DuolingoButtonStyle(color: AppDesign.orange, shadowColor: Color(hex: "E08400")))
            }
            .padding(.bottom, 60)
        }
        .onReceive(timer) { _ in
            guard !isPaused, !showDistractionModal else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                handleComplete()
            }
        }
        .sheet(isPresented: $showDistractionModal) {
            DistractionSheet(
                showModal: $showDistractionModal,
                onDistract: handleDistracted
            )
            .presentationDetents([.height(560)])
            .presentationCornerRadius(32)
            .presentationBackground(AppDesign.bgMain)
        }
    }
    
    private var progress: CGFloat {
        let totalSeconds = CGFloat(duration * 60)
        return CGFloat(timeRemaining) / totalSeconds
    }
    
    private var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%d:%02d", m, s)
    }
    
    private var currentTaskTitle: String {
        if let id = store.activeTaskId, let task = store.tasks.first(where: { $0.id == id }) {
            return task.title
        }
        return "自由专注"
    }
    
    private func handleComplete() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        store.addSession(startTime: startTime, duration: duration, isDistracted: false)
        currentView = .rest
    }
    
    private func handleDistracted(type: String) {
        let elapsedMins = (duration * 60 - timeRemaining) / 60
        store.addSession(startTime: startTime, duration: elapsedMins, isDistracted: true, distractionType: type)
        currentView = .home
    }
}

struct DistractionSheet: View {
    @Binding var showModal: Bool
    var onDistract: (String) -> Void
    
    let options = [
        ("phone", "📱 手机消息"),
        ("environment", "🏢 环境干扰"),
        ("thoughts", "💭 思绪飘走"),
        ("other", "❓ 其他原因")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundColor(AppDesign.orange)
            
            VStack(spacing: 8) {
                Text("刚才分心了吗？")
                    .font(.system(.title2, design: .rounded)).bold()
                    .foregroundColor(AppDesign.textMain)
                Text("诚实记录分心原因，帮助我们在复盘时找到改进方向。")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(AppDesign.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                ForEach(options, id: \.0) { id, label in
                    Button(action: {
                        onDistract(id)
                    }) {
                        Text(label)
                            .font(.system(.headline, design: .rounded)).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .frame(height: 56)
                            .foregroundColor(AppDesign.textMain)
                    }
                    .buttonStyle(DuolingoGhostButtonStyle())
                }
            }
            
            Button(action: {
                showModal = false
            }) {
                Text("继续专注")
                    .font(.system(.headline, design: .rounded)).bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundColor(AppDesign.textSecondary)
            }
            .buttonStyle(DuolingoGhostButtonStyle())
            .padding(.top, 8)
        }
        .padding(24)
    }
}
