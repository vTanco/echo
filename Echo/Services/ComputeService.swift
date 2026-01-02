import Foundation
import UIKit
import Combine

/// Service that manages distributed ML inference compute sessions
class ComputeService: ObservableObject {
    static let shared = ComputeService()
    
    // MARK: - Published Properties
    
    @Published var currentTask: MLComputeTask?
    @Published var completedTasksCount: Int = 0
    @Published var sessionEarnings: Double = 0.0
    @Published var isProcessing: Bool = false
    @Published var statusMessage: String = "Idle"
    @Published var lastError: String?
    
    // MARK: - Private Properties
    
    private let coreMLRunner = CoreMLRunner()
    private var workTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    /// Polling interval when no tasks are available (seconds)
    private let pollingInterval: TimeInterval = 5.0
    
    private init() {}
    
    // MARK: - Session Control
    
    /// Start the compute session - begins polling for ML tasks
    func startSession() {
        guard !isProcessing else { return }
        
        isProcessing = true
        sessionEarnings = 0.0
        completedTasksCount = 0
        currentTask = nil
        lastError = nil
        statusMessage = "Starting session..."
        
        print("🚀 Starting ML inference session")
        
        // Start the inference loop
        workTask = Task { [weak self] in
            await self?.runInferenceLoop()
        }
    }
    
    /// Stop the compute session
    func stopSession() {
        print("⏹️ Stopping ML inference session")
        
        isProcessing = false
        workTask?.cancel()
        workTask = nil
        statusMessage = "Session stopped"
    }
    
    // MARK: - Inference Loop
    
    /// Main inference loop - fetches tasks and processes them
    private func runInferenceLoop() async {
        while isProcessing && !Task.isCancelled {
            do {
                // Update status
                await updateStatus("Fetching next task...")
                
                // 1. Fetch next task from backend
                guard let task = try await fetchNextTask() else {
                    await updateStatus("Waiting for tasks...")
                    try await Task.sleep(for: .seconds(pollingInterval))
                    continue
                }
                
                // Update current task on main thread
                await MainActor.run {
                    self.currentTask = task
                    self.statusMessage = "Processing: \(task.description)"
                }
                
                print("📥 Received task: \(task.id)")
                
                // 2. Download and compile the model
                await updateStatus("Downloading model...")
                
                guard let modelURL = URL(string: task.modelUrl) else {
                    throw CoreMLError.invalidModelURL
                }
                
                let compiledModelURL = try await coreMLRunner.downloadAndCompileModel(url: modelURL)
                
                // 3. Run inference
                await updateStatus("Running inference...")
                
                let startTime = CFAbsoluteTimeGetCurrent()
                let output = try await coreMLRunner.predict(
                    compiledModelURL: compiledModelURL,
                    input: task.inputData
                )
                let inferenceTimeMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
                
                print("✅ Inference completed in \(String(format: "%.2f", inferenceTimeMs))ms")
                
                // 4. Submit result to backend
                await updateStatus("Submitting result...")
                
                try await submitTaskResult(
                    taskId: task.id,
                    output: output,
                    inferenceTimeMs: inferenceTimeMs,
                    success: true,
                    errorMessage: nil
                )
                
                // Update stats
                await MainActor.run {
                    self.completedTasksCount += 1
                    self.sessionEarnings += task.reward
                    self.currentTask = nil
                    
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
                
                print("💰 Task completed! Earnings: €\(String(format: "%.4f", task.reward))")
                
            } catch is CancellationError {
                // Task was cancelled, exit gracefully
                break
            } catch {
                // Handle error without crashing
                print("❌ Task error: \(error.localizedDescription)")
                
                // If we have a current task, report the failure
                if let task = await MainActor.run(body: { self.currentTask }) {
                    do {
                        try await submitTaskResult(
                            taskId: task.id,
                            output: [:],
                            inferenceTimeMs: 0,
                            success: false,
                            errorMessage: error.localizedDescription
                        )
                    } catch {
                        print("❌ Failed to report error to backend: \(error)")
                    }
                }
                
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.currentTask = nil
                }
                
                // Brief pause before retrying
                try? await Task.sleep(for: .seconds(2))
            }
        }
        
        // Cleanup when loop exits
        await MainActor.run {
            self.isProcessing = false
            self.statusMessage = "Session ended"
        }
    }
    
    // MARK: - API Methods
    
    /// Fetch the next available ML task from the backend
    private func fetchNextTask() async throws -> MLComputeTask? {
        // Get device ID from MainActor-isolated AuthManager
        let deviceId = await MainActor.run { AuthManager.shared.currentDeviceId }
        
        guard let deviceId = deviceId else {
            throw APIError.unauthorized
        }
        
        do {
            let response: MLTaskAPIResponse? = try await APIClient.shared.get(
                "/tasks/next?device_id=\(deviceId)"
            )
            
            guard let response = response else {
                return nil
            }
            
            return MLComputeTask(
                id: response.id,
                modelUrl: response.modelUrl,
                inputData: response.inputData.asAnyDict,
                expectedOutputType: response.expectedOutputType,
                reward: response.reward,
                clientName: response.clientName,
                description: "ML Inference: \(response.expectedOutputType)"
            )
        } catch APIError.serverError(404, _) {
            // No tasks available
            return nil
        }
    }
    
    /// Submit task result to the backend
    private func submitTaskResult(
        taskId: String,
        output: [String: Any],
        inferenceTimeMs: Double,
        success: Bool,
        errorMessage: String?
    ) async throws {
        let request = TaskResultSubmitRequest(
            outputData: Dictionary<String, AnyCodableValue>.from(output),
            inferenceTimeMs: inferenceTimeMs,
            success: success,
            errorMessage: errorMessage
        )
        
        let _: TaskResponse = try await APIClient.shared.post(
            "/tasks/\(taskId)/submit",
            body: request
        )
    }
    
    // MARK: - Helper Methods
    
    /// Update status message on main thread
    private func updateStatus(_ message: String) async {
        await MainActor.run {
            self.statusMessage = message
        }
    }
    
    // MARK: - Statistics
    
    func getSessionStats() -> SessionStats {
        SessionStats(
            tasksCompleted: completedTasksCount,
            earnings: sessionEarnings,
            activeTasks: currentTask != nil ? 1 : 0
        )
    }
    
    /// Clear the model cache (useful for freeing disk space)
    func clearModelCache() async {
        await coreMLRunner.clearCache()
    }
}

// MARK: - Supporting Types

struct SessionStats {
    let tasksCompleted: Int
    let earnings: Double
    let activeTasks: Int
}

/// Represents an ML inference task received from the backend
struct MLComputeTask: Identifiable {
    let id: String
    let modelUrl: String
    let inputData: [String: Any]
    let expectedOutputType: String
    let reward: Double
    let clientName: String
    let description: String
    
    var formattedReward: String {
        String(format: "€%.4f", reward)
    }
}

