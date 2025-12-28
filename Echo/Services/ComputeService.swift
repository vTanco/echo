import Foundation
import UIKit
import Combine

class ComputeService: ObservableObject {
    static let shared = ComputeService()
    
    @Published var currentTasks: [ComputeTask] = []
    @Published var completedTasksCount: Int = 0
    @Published var sessionEarnings: Double = 0.0
    @Published var isProcessing: Bool = false
    
    private var taskTimer: Timer?
    private var progressTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Session Control
    func startSession() {
        guard !isProcessing else { return }
        
        isProcessing = true
        sessionEarnings = 0.0
        completedTasksCount = 0
        currentTasks = []
        
        // Spawn initial task
        spawnNewTask()
        
        // Start task spawner timer
        taskTimer = Timer.scheduledTimer(withTimeInterval: Constants.TaskSimulation.taskSpawnInterval, repeats: true) { [weak self] _ in
            self?.spawnNewTask()
        }
        
        // Start progress update timer
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateTaskProgress()
        }
    }
    
    func stopSession() {
        isProcessing = false
        taskTimer?.invalidate()
        progressTimer?.invalidate()
        taskTimer = nil
        progressTimer = nil
    }
    
    // MARK: - Task Management
    private func spawnNewTask() {
        guard isProcessing else { return }
        guard currentTasks.count < 3 else { return } // Max 3 concurrent tasks
        
        let newTask = ComputeTask.generateRandom()
        currentTasks.append(newTask)
    }
    
    private func updateTaskProgress() {
        guard isProcessing else { return }
        
        for index in currentTasks.indices {
            let progressIncrement = Double.random(in: 0.01...0.05)
            currentTasks[index].progress = min(1.0, currentTasks[index].progress + progressIncrement)
        }
        
        // Check for completed tasks
        let completedTasks = currentTasks.filter { $0.isComplete }
        for task in completedTasks {
            completeTask(task)
        }
        
        // Remove completed tasks
        currentTasks.removeAll { $0.isComplete }
    }
    
    private func completeTask(_ task: ComputeTask) {
        completedTasksCount += 1
        sessionEarnings += task.reward
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    // MARK: - Statistics
    func getSessionStats() -> SessionStats {
        SessionStats(
            tasksCompleted: completedTasksCount,
            earnings: sessionEarnings,
            activeTasks: currentTasks.count
        )
    }
}

struct SessionStats {
    let tasksCompleted: Int
    let earnings: Double
    let activeTasks: Int
}
