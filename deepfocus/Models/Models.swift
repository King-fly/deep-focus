import Foundation

struct Task: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var status: TaskStatus
    var pomodoros: Int
    var completedPomodoros: Int
    var createdAt: Date
    
    enum TaskStatus: String, Codable {
        case todo
        case done
    }
}

struct FocusSession: Identifiable, Codable, Equatable {
    var id: String
    var startTime: Date
    var duration: Int // in minutes
    var taskId: String?
    var isDistracted: Bool
    var distractionType: String?
}

struct DailyStats {
    var date: String
    var totalFocusMinutes: Int
    var completedPomodoros: Int
    var completedTasks: Int
    var distractionCount: Int
}
