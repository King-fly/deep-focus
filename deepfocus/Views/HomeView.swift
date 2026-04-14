import SwiftUI

struct HomeView: View {
    @Environment(FocusStore.self) private var store
    @Binding var currentView: AppView
    
    @State private var showTaskInput = false
    @State private var newTaskTitle = ""
    @State private var selectedDuration = 25
    
    let durations = [15, 25, 45]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DeepFocus")
                        .font(.system(.title2, design: .rounded)).bold()
                        .foregroundColor(AppDesign.textMain)
                    Text(currentDateString())
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(AppDesign.textSecondary)
                        .fontWeight(.bold)
                }
                Spacer()
                Button(action: { currentView = .stats }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppDesign.blue)
                        .padding(14)
                }
                .buttonStyle(DuolingoGhostButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Stats Card
                    statsCard
                    
                    // Tasks Section
                    tasksSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 150) // Space for bottom button
            }
        }
        .overlay(alignment: .bottom) {
            bottomStartSection
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
        }
        .sheet(isPresented: $showTaskInput) {
            TaskInputSheet(newTaskTitle: $newTaskTitle, showTaskInput: $showTaskInput)
                .presentationDetents([.height(280)])
                .presentationCornerRadius(32)
                .presentationBackground(AppDesign.bgMain)
        }
    }
    
    private var statsCard: some View {
        let stats = store.getDailyStats()
        let progress = min(Double(stats.totalFocusMinutes) / 120.0, 1.0)
        
        return VStack(spacing: 24) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日专注")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppDesign.textSecondary)
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(stats.totalFocusMinutes)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(AppDesign.textMain)
                        Text("min")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppDesign.textSecondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("目标 120min")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppDesign.orange)
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AppDesign.border)
                            Capsule()
                                .fill(AppDesign.orange)
                                .frame(width: geo.size.width * CGFloat(progress))
                                .animation(.spring(), value: progress)
                        }
                    }
                    .frame(width: 120, height: 16)
                }
            }
            
            Divider().background(AppDesign.border)
            
            HStack {
                statItem(value: "\(stats.completedPomodoros)", label: "番茄", color: AppDesign.green)
                Spacer()
                statItem(value: "\(stats.completedTasks)", label: "任务", color: AppDesign.blue)
                Spacer()
                statItem(value: "\(stats.distractionCount)", label: "分心", color: AppDesign.red)
            }
        }
        .padding(24)
        .duolingoCard()
    }
    
    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded)).bold()
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(AppDesign.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("今日核心任务 (\(store.tasks.count)/3)")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(AppDesign.textMain)
                Spacer()
                if store.tasks.count < 3 {
                    Button(action: { showTaskInput = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppDesign.blue)
                            .padding(8)
                            .background(AppDesign.surface)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if store.tasks.isEmpty {
                VStack {
                    Text("还没有任务，点击右上角添加")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(AppDesign.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [8]))
                        .foregroundColor(AppDesign.border)
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(store.tasks) { task in
                        TaskRow(task: task)
                    }
                }
            }
        }
    }
    
    private var bottomStartSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(durations, id: \.self) { d in
                    Button(action: { selectedDuration = d }) {
                        Text("\(d) m")
                            .font(.system(.headline, design: .rounded)).bold()
                            .padding(.horizontal, 4)
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoGhostButtonStyle())
                    // Override the ghost style selected state with blue highlight
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedDuration == d ? AppDesign.blue : Color.clear, lineWidth: 3)
                    )
                }
            }
            
            Button(action: {
                #if os(iOS)
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                #endif
                currentView = .focus(duration: selectedDuration)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(.title2, design: .rounded))
                    Text("开始专注")
                        .font(.system(.title3, design: .rounded)).bold()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .foregroundColor(.white)
            }
            .buttonStyle(DuolingoButtonStyle(color: AppDesign.green, shadowColor: AppDesign.greenShadow))
        }
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

struct TaskRow: View {
    @Environment(FocusStore.self) private var store
    let task: Task
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                #endif
                store.toggleTaskDone(id: task.id)
            }) {
                Image(systemName: task.status == .done ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.status == .done ? AppDesign.green : AppDesign.border)
                    .font(.system(size: 32, weight: .bold))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .strikethrough(task.status == .done)
                    .foregroundColor(task.status == .done ? AppDesign.textSecondary : AppDesign.textMain)
                
                HStack(spacing: 6) {
                    ForEach(0..<task.pomodoros, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(i < task.completedPomodoros ? AppDesign.green : AppDesign.border)
                            .frame(width: 16, height: 8)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                #endif
                store.deleteTask(id: task.id)
            }) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppDesign.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(store.activeTaskId == task.id ? AppDesign.blue.opacity(0.1) : AppDesign.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(store.activeTaskId == task.id ? AppDesign.blue : AppDesign.border, lineWidth: store.activeTaskId == task.id ? 3 : 2)
        )
        .shadow(color: store.activeTaskId == task.id ? AppDesign.blue.opacity(0.3) : AppDesign.border, radius: 0, x: 0, y: 3)
        .contentShape(Rectangle())
        .onTapGesture {
            if task.status != .done {
                store.activeTaskId = task.id
            }
        }
    }
}

struct TaskInputSheet: View {
    @Environment(FocusStore.self) private var store
    @Binding var newTaskTitle: String
    @Binding var showTaskInput: Bool
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("添加核心任务")
                .font(.system(.title3, design: .rounded)).bold()
                .foregroundColor(AppDesign.textMain)
            
            TextField("输入任务标题 (≤20字)", text: $newTaskTitle)
                .textFieldStyle(.plain)
                .font(.system(.body, design: .rounded).bold())
                .foregroundColor(AppDesign.textMain)
                .padding()
                .background(AppDesign.surface)
                .cornerRadius(16)
                .focused($isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFocused ? AppDesign.blue : AppDesign.border, lineWidth: isFocused ? 3 : 2)
                )
                .onSubmit { submit() }
                .onAppear {
                    isFocused = true
                }
            
            HStack(spacing: 16) {
                Button(action: { showTaskInput = false }) {
                    Text("取消")
                        .font(.system(.title3, design: .rounded)).bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(AppDesign.textSecondary)
                }
                .buttonStyle(DuolingoGhostButtonStyle())
                
                Button(action: { submit() }) {
                    Text("确定")
                        .font(.system(.title3, design: .rounded)).bold()
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                }
                .buttonStyle(DuolingoButtonStyle(color: AppDesign.blue, shadowColor: AppDesign.blueShadow))
            }
        }
        .padding(24)
    }
    
    private func submit() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            store.addTask(title: String(trimmed.prefix(20)))
            newTaskTitle = ""
            showTaskInput = false
        }
    }
}
