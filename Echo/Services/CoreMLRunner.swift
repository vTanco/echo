import Foundation
import CoreML
import CryptoKit

/// Errors that can occur during CoreML operations
enum CoreMLError: LocalizedError {
    case invalidModelURL
    case downloadFailed(Error)
    case compilationFailed(Error)
    case modelLoadFailed(Error)
    case predictionFailed(Error)
    case unsupportedInputFormat
    case domainNotAllowed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidModelURL:
            return "Invalid model URL"
        case .downloadFailed(let error):
            return "Failed to download model: \(error.localizedDescription)"
        case .compilationFailed(let error):
            return "Failed to compile model: \(error.localizedDescription)"
        case .modelLoadFailed(let error):
            return "Failed to load model: \(error.localizedDescription)"
        case .predictionFailed(let error):
            return "Prediction failed: \(error.localizedDescription)"
        case .unsupportedInputFormat:
            return "Unsupported input format"
        case .domainNotAllowed(let domain):
            return "Model download from '\(domain)' not allowed"
        }
    }
}

/// Actor responsible for downloading, compiling, and executing CoreML models
/// All operations are thread-safe and run on background threads
actor CoreMLRunner {
    
    // MARK: - Properties
    
    /// Cache for compiled model URLs, keyed by SHA256 hash of the original URL
    private var compiledModelCache: [String: URL] = [:]
    
    /// Loaded MLModel instances cache
    private var loadedModels: [String: MLModel] = [:]
    
    /// Allowed domains for model downloads (security measure)
    private let allowedDomains = [
        "docs-assets.developer.apple.com",
        "ml-assets.apple.com",
        "huggingface.co",
        "echocompute.com",
        "localhost"
    ]
    
    /// Directory for storing downloaded/compiled models
    private var modelsDirectory: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return caches.appendingPathComponent("EchoModels", isDirectory: true)
    }
    
    // MARK: - Initialization
    
    init() {
        // Ensure models directory exists
        try? FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    /// Download and compile a CoreML model from URL
    /// - Parameter url: URL to the .mlmodel or .mlpackage file
    /// - Returns: URL to the compiled .mlmodelc directory
    func downloadAndCompileModel(url: URL) async throws -> URL {
        // Validate URL domain
        try validateModelURL(url)
        
        // Check cache first
        let cacheKey = cacheKey(for: url)
        if let cachedURL = compiledModelCache[cacheKey],
           FileManager.default.fileExists(atPath: cachedURL.path) {
            print("📦 Using cached model: \(cachedURL.lastPathComponent)")
            return cachedURL
        }
        
        print("⬇️ Downloading model from: \(url)")
        
        // Download model to temp location
        let downloadedURL = try await downloadModel(from: url)
        
        print("🔧 Compiling model...")
        
        // Compile the model
        let compiledURL = try await compileModel(at: downloadedURL)
        
        // Cache the compiled model URL
        compiledModelCache[cacheKey] = compiledURL
        
        // Clean up downloaded (uncompiled) model
        try? FileManager.default.removeItem(at: downloadedURL)
        
        print("✅ Model ready: \(compiledURL.lastPathComponent)")
        
        return compiledURL
    }
    
    /// Run prediction with a compiled CoreML model
    /// - Parameters:
    ///   - compiledModelURL: URL to the compiled .mlmodelc directory
    ///   - input: Dictionary of input features for the model
    /// - Returns: Dictionary containing the prediction results
    func predict(compiledModelURL: URL, input: [String: Any]) async throws -> [String: Any] {
        let cacheKey = compiledModelURL.lastPathComponent
        
        // Load model (with caching)
        let model: MLModel
        if let cachedModel = loadedModels[cacheKey] {
            model = cachedModel
        } else {
            print("🔄 Loading model...")
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .all // Use Neural Engine when available
                model = try MLModel(contentsOf: compiledModelURL, configuration: config)
                loadedModels[cacheKey] = model
            } catch {
                throw CoreMLError.modelLoadFailed(error)
            }
        }
        
        // Create feature provider from input
        let featureProvider = try createFeatureProvider(from: input, for: model)
        
        // Run prediction
        print("🧠 Running inference...")
        let prediction: MLFeatureProvider
        do {
            prediction = try model.prediction(from: featureProvider)
        } catch {
            throw CoreMLError.predictionFailed(error)
        }
        
        // Convert output to dictionary
        let output = extractOutputFeatures(from: prediction)
        
        print("✅ Inference complete")
        
        return output
    }
    
    /// Clear the model cache (useful for freeing memory)
    func clearCache() {
        compiledModelCache.removeAll()
        loadedModels.removeAll()
        
        // Optionally delete cached files
        try? FileManager.default.removeItem(at: modelsDirectory)
        try? FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Methods
    
    /// Validate that the model URL is from an allowed domain
    private func validateModelURL(_ url: URL) throws {
        guard let host = url.host?.lowercased() else {
            throw CoreMLError.invalidModelURL
        }
        
        let isAllowed = allowedDomains.contains { domain in
            host == domain || host.hasSuffix(".\(domain)")
        }
        
        guard isAllowed else {
            throw CoreMLError.domainNotAllowed(host)
        }
    }
    
    /// Generate a cache key for a URL using SHA256 hash
    private func cacheKey(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Download model from URL to local storage
    private func downloadModel(from url: URL) async throws -> URL {
        let destinationURL = modelsDirectory.appendingPathComponent(url.lastPathComponent)
        
        // Remove existing file if present
        try? FileManager.default.removeItem(at: destinationURL)
        
        do {
            let (tempURL, response) = try await URLSession.shared.download(from: url)
            
            // Check response
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                throw CoreMLError.downloadFailed(
                    NSError(domain: "HTTP", code: httpResponse.statusCode, userInfo: nil)
                )
            }
            
            // Move to models directory
            try FileManager.default.moveItem(at: tempURL, to: destinationURL)
            
            return destinationURL
        } catch let error as CoreMLError {
            throw error
        } catch {
            throw CoreMLError.downloadFailed(error)
        }
    }
    
    /// Compile a downloaded model
    private func compileModel(at url: URL) async throws -> URL {
        do {
            // MLModel.compileModel is synchronous but can be slow
            // We run it on a background thread
            let compiledURL = try await Task.detached(priority: .userInitiated) {
                try MLModel.compileModel(at: url)
            }.value
            
            // Move compiled model to our models directory for persistence
            let persistentURL = self.modelsDirectory.appendingPathComponent(compiledURL.lastPathComponent)
            
            // Remove old compiled model if exists
            try? FileManager.default.removeItem(at: persistentURL)
            
            // Move the compiled model
            try FileManager.default.moveItem(at: compiledURL, to: persistentURL)
            
            return persistentURL
        } catch {
            throw CoreMLError.compilationFailed(error)
        }
    }
    
    /// Create an MLFeatureProvider from input dictionary
    private func createFeatureProvider(from input: [String: Any], for model: MLModel) throws -> MLFeatureProvider {
        // For simple models, we can use MLDictionaryFeatureProvider
        // For image models like MobileNetV2, we'd need to handle image input specifically
        
        var features: [String: MLFeatureValue] = [:]
        
        let inputDescription = model.modelDescription.inputDescriptionsByName
        
        for (name, description) in inputDescription {
            if let value = input[name] {
                if let featureValue = try? createFeatureValue(from: value, type: description.type) {
                    features[name] = featureValue
                }
            }
        }
        
        // If no matching inputs found, this might be an image model
        // For MobileNetV2 demo, create a dummy image input
        if features.isEmpty && inputDescription.values.first?.type == .image {
            if let imageInput = try createDummyImageInput(for: model) {
                return imageInput
            }
        }
        
        guard !features.isEmpty else {
            throw CoreMLError.unsupportedInputFormat
        }
        
        return try MLDictionaryFeatureProvider(dictionary: features)
    }
    
    /// Create an MLFeatureValue from a generic value
    private func createFeatureValue(from value: Any, type: MLFeatureType) throws -> MLFeatureValue? {
        switch type {
        case .double:
            if let doubleValue = value as? Double {
                return MLFeatureValue(double: doubleValue)
            } else if let intValue = value as? Int {
                return MLFeatureValue(double: Double(intValue))
            }
        case .int64:
            if let intValue = value as? Int {
                return MLFeatureValue(int64: Int64(intValue))
            }
        case .string:
            if let stringValue = value as? String {
                return MLFeatureValue(string: stringValue)
            }
        case .dictionary:
            if let dictValue = value as? [String: Double] {
                return try? MLFeatureValue(dictionary: dictValue as [NSObject: NSNumber])
            }
        default:
            break
        }
        return nil
    }
    
    /// Create a dummy image input for image classification models (for testing)
    private func createDummyImageInput(for model: MLModel) throws -> MLFeatureProvider? {
        guard let inputName = model.modelDescription.inputDescriptionsByName.keys.first,
              let inputDesc = model.modelDescription.inputDescriptionsByName[inputName],
              let imageConstraint = inputDesc.imageConstraint else {
            return nil
        }
        
        let width = imageConstraint.pixelsWide
        let height = imageConstraint.pixelsHigh
        
        // Create a simple gradient image for testing
        guard let cgImage = createTestImage(width: width, height: height) else {
            return nil
        }
        
        let featureValue = try MLFeatureValue(cgImage: cgImage, constraint: imageConstraint)
        return try MLDictionaryFeatureProvider(dictionary: [inputName: featureValue])
    }
    
    /// Create a test image for demo purposes
    private func createTestImage(width: Int, height: Int) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            return nil
        }
        
        // Draw a gradient for testing
        let colors = [CGColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0),
                      CGColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0)]
        
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) {
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: CGFloat(width), y: CGFloat(height)),
                options: []
            )
        }
        
        return context.makeImage()
    }
    
    /// Extract output features from prediction result
    private func extractOutputFeatures(from prediction: MLFeatureProvider) -> [String: Any] {
        var output: [String: Any] = [:]
        
        for name in prediction.featureNames {
            if let featureValue = prediction.featureValue(for: name) {
                switch featureValue.type {
                case .string:
                    output[name] = featureValue.stringValue
                case .double:
                    output[name] = featureValue.doubleValue
                case .int64:
                    output[name] = featureValue.int64Value
                case .dictionary:
                    if let dict = featureValue.dictionaryValue as? [String: Double] {
                        // For classification, get top prediction
                        let sorted = dict.sorted { $0.value > $1.value }
                        if let top = sorted.first {
                            output["topPrediction"] = top.key
                            output["confidence"] = top.value
                        }
                        // Include top 5 predictions
                        let top5 = Array(sorted.prefix(5))
                        output["top5"] = top5.map { ["label": $0.key, "confidence": $0.value] }
                    }
                case .multiArray:
                    // Convert to array of numbers
                    if let multiArray = featureValue.multiArrayValue {
                        var array: [Double] = []
                        for i in 0..<multiArray.count {
                            array.append(multiArray[i].doubleValue)
                        }
                        output[name] = array
                    }
                default:
                    output[name] = "unsupported_type"
                }
            }
        }
        
        return output
    }
}
