import Foundation

struct ComputeTask: Identifiable {
    let id: UUID
    let type: TaskType
    var progress: Double
    let reward: Double
    let clientName: String
    let clientLogo: String
    let description: String
    let startTime: Date
    
    enum TaskType: String, CaseIterable {
        case aiTraining = "AI Training"
        case rendering = "3D Rendering"
        case research = "Scientific Research"
        case cryptography = "Cryptography"
        case dataProcessing = "Data Processing"
        
        var icon: String {
            switch self {
            case .aiTraining: return "brain"
            case .rendering: return "cube.transparent"
            case .research: return "atom"
            case .cryptography: return "lock.shield"
            case .dataProcessing: return "chart.bar.doc.horizontal"
            }
        }
        
        var color: String {
            switch self {
            case .aiTraining: return "AccentMagenta"
            case .rendering: return "AccentCyan"
            case .research: return "AccentViolet"
            case .cryptography: return "AccentGreen"
            case .dataProcessing: return "AccentOrange"
            }
        }
        
        var baseReward: Double {
            switch self {
            case .aiTraining: return 0.025
            case .rendering: return 0.035
            case .research: return 0.020
            case .cryptography: return 0.030
            case .dataProcessing: return 0.015
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        type: TaskType = .aiTraining,
        progress: Double = 0.0,
        reward: Double? = nil,
        clientName: String = "OpenAI Labs",
        clientLogo: String = "building.2",
        description: String = "Training language model",
        startTime: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.progress = progress
        self.reward = reward ?? type.baseReward
        self.clientName = clientName
        self.clientLogo = clientLogo
        self.description = description
        self.startTime = startTime
    }
    
    var isComplete: Bool {
        progress >= 1.0
    }
    
    var formattedReward: String {
        String(format: "€%.4f", reward)
    }
    
    static let mockClients: [(name: String, logo: String)] = [
        ("OpenAI Labs", "brain.head.profile"),
        ("DeepMind Research", "waveform"),
        ("Stanford University", "graduationcap"),
        ("MIT Media Lab", "lightbulb"),
        ("CERN", "atom"),
        ("Pixar Animation", "cube.transparent"),
        ("Anthropic", "sparkles"),
        ("NASA", "moon.stars"),
        ("Tesla AI", "car.side"),
        ("Blender Foundation", "cube")
    ]
    
    static func generateRandom() -> ComputeTask {
        let type = TaskType.allCases.randomElement() ?? .aiTraining
        let client = mockClients.randomElement() ?? mockClients[0]
        
        let descriptions: [TaskType: [String]] = [
            .aiTraining: [
                "Training language model parameters",
                "Fine-tuning neural network weights",
                "Optimizing transformer architecture",
                "Processing training batch"
            ],
            .rendering: [
                "Rendering animated sequence",
                "Computing global illumination",
                "Processing ray tracing pass",
                "Generating texture maps"
            ],
            .research: [
                "Simulating protein folding",
                "Analyzing genomic sequences",
                "Computing climate models",
                "Processing astronomical data"
            ],
            .cryptography: [
                "Generating encryption keys",
                "Verifying blockchain transactions",
                "Computing hash functions",
                "Processing secure protocols"
            ],
            .dataProcessing: [
                "Analyzing dataset patterns",
                "Compressing data streams",
                "Processing ETL pipeline",
                "Indexing search database"
            ]
        ]
        
        let description = descriptions[type]?.randomElement() ?? "Processing task"
        
        return ComputeTask(
            type: type,
            clientName: client.name,
            clientLogo: client.logo,
            description: description
        )
    }
}
