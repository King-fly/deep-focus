import SwiftUI
import Observation

@Observable
class FocusStore {
    var tasks: [Task] = []
    var sessions: [FocusSession] = []
    var activeTaskId: String?
    
    init() {
        loadData()
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "df_tasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            
            // Auto-clear tasks from previous days
            let calendar = Calendar.current
            self.tasks = decoded.filter { calendar.isDateInToday($0.createdAt) }
        }
        
        if let data = UserDefaults.standard.data(forKey: "df_sessions"),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            self.sessions = decoded
        }
    }
    
    private func saveData() {
        if let encodedTasks = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encodedTasks, forKey: "df_tasks")
        }
        if let encodedSessions = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encodedSessions, forKey: "df_sessions")
        }
    }
    
    func addTask(title: String) {
        guard tasks.count < 3 else { return }
        let newTask = Task(
            id: UUID().uuidString,
            title: title,
            status: .todo,
            pomodoros: 1,
            completedPomodoros: 0,
            createdAt: Date()
        )
        tasks.append(newTask)
        saveData()
    }
    
    func toggleTaskDone(id: String) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].status = tasks[index].status == .done ? .todo : .done
            saveData()
        }
    }
    
    func deleteTask(id: String) {
        tasks.removeAll(where: { $0.id == id })
        if activeTaskId == id {
            activeTaskId = nil
        }
        saveData()
    }
    
    func addSession(startTime: Date, duration: Int, isDistracted: Bool, distractionType: String? = nil) {
        let newSession = FocusSession(
            id: UUID().uuidString,
            startTime: startTime,
            duration: duration,
            taskId: activeTaskId,
            isDistracted: isDistracted,
            distractionType: distractionType
        )
        sessions.append(newSession)
        
        if let taskId = activeTaskId, !isDistracted {
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                tasks[index].completedPomodoros += 1
            }
        }
        
        saveData()
    }
    
    func getDailyStats(date: Date = Date()) -> DailyStats {
        let calendar = Calendar.current
        
        let daySessions = sessions.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
        let dayTasks = tasks.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
        
        let focusMinutes = daySessions.filter { !$0.isDistracted }.reduce(0) { $0 + $1.duration }
        let pomodoros = daySessions.filter { !$0.isDistracted }.count
        let tasksDone = dayTasks.filter { $0.status == .done }.count
        let distractions = daySessions.filter { $0.isDistracted }.count
        
        // Simple date formatting
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return DailyStats(
            date: formatter.string(from: date),
            totalFocusMinutes: focusMinutes,
            completedPomodoros: pomodoros,
            completedTasks: tasksDone,
            distractionCount: distractions
        )
    }
    
    func getWeeklyStats() -> [(name: String, minutes: Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        // Find the start of the week (assuming Monday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        
        guard let startOfWeek = calendar.date(from: components) else { return [] }
        
        var weeklyData: [(String, Int)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let daySessions = sessions.filter { calendar.isDate($0.startTime, inSameDayAs: day) && !$0.isDistracted }
                let minutes = daySessions.reduce(0) { $0 + $1.duration }
                weeklyData.append((formatter.string(from: day), minutes))
            }
        }
        
        return weeklyData
    }
}
