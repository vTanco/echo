import Cocoa

// Configuration
let destFolder = "/Users/vicente.tancoedu.uah.es/echo/Echo/Resources/Assets.xcassets/AppIcon.appiconset"

// Create master icon at EXACT 1024x1024 pixels
let masterSize: CGFloat = 1024
let masterImage = NSImage(size: NSSize(width: masterSize, height: masterSize))

masterImage.lockFocusFlipped(false)

// 1. Background (Dark Gradient)
let bgPath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: masterSize, height: masterSize))
let bgGradient = NSGradient(colors: [
    NSColor(red: 0.05, green: 0.02, blue: 0.10, alpha: 1.0),
    NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
])
bgGradient?.draw(in: bgPath, angle: -45)

// 2. Main Orb Glow
let center = NSPoint(x: masterSize/2, y: masterSize/2)
let orbRadius = masterSize * 0.35

let glowGradient = NSGradient(colors: [
    NSColor(red: 0.0, green: 0.9, blue: 0.97, alpha: 0.3),
    NSColor.clear
])
let glowRect = CGRect(x: center.x - orbRadius * 1.5, y: center.y - orbRadius * 1.5, width: orbRadius * 3, height: orbRadius * 3)
glowGradient?.draw(in: NSBezierPath(ovalIn: glowRect), relativeCenterPosition: .zero)

// 3. The Orb
let orbPath = NSBezierPath(ovalIn: CGRect(x: center.x - orbRadius, y: center.y - orbRadius, width: orbRadius * 2, height: orbRadius * 2))
let orbGradient = NSGradient(colors: [
    NSColor(red: 0.0, green: 0.9, blue: 0.97, alpha: 1.0),
    NSColor(red: 1.0, green: 0.0, blue: 0.88, alpha: 1.0)
])
orbGradient?.draw(in: orbPath, angle: 45)

// 4. Inner Ring
let innerRadius = orbRadius * 0.7
let innerPath = NSBezierPath(ovalIn: CGRect(x: center.x - innerRadius, y: center.y - innerRadius, width: innerRadius * 2, height: innerRadius * 2))
NSColor.white.withAlphaComponent(0.2).setStroke()
innerPath.lineWidth = 20
innerPath.stroke()

// 5. Core
let coreRadius = orbRadius * 0.4
let corePath = NSBezierPath(ovalIn: CGRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2))
NSColor.white.withAlphaComponent(0.9).setFill()
corePath.fill()

masterImage.unlockFocus()

// Function to save at exact pixel size
func saveIcon(from source: NSImage, pixelSize: Int, filename: String) {
    let size = NSSize(width: pixelSize, height: pixelSize)
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = size
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    source.draw(in: NSRect(origin: .zero, size: size),
                from: NSRect(origin: .zero, size: source.size),
                operation: .copy,
                fraction: 1.0)
    NSGraphicsContext.restoreGraphicsState()
    
    guard let pngData = rep.representation(using: .png, properties: [:]) else {
        print("Error creating PNG for \(filename)")
        return
    }
    
    let path = destFolder + "/" + filename
    try? pngData.write(to: URL(fileURLWithPath: path))
    print("Generated \(filename) at \(pixelSize)x\(pixelSize)")
}

// Icon specifications: (filename, exact pixel size)
let specs: [(String, Int)] = [
    // iPhone
    ("Icon-20@2x.png", 40),
    ("Icon-20@3x.png", 60),
    ("Icon-29@2x.png", 58),
    ("Icon-29@3x.png", 87),
    ("Icon-40@2x.png", 80),
    ("Icon-40@3x.png", 120),
    ("Icon-60@2x.png", 120),
    ("Icon-60@3x.png", 180),
    
    // iPad
    ("Icon-20.png", 20),
    ("Icon-29.png", 29),
    ("Icon-40.png", 40),
    ("Icon-76.png", 76),
    ("Icon-76@2x.png", 152),
    ("Icon-83.5@2x.png", 167),
    
    // Marketing
    ("Icon-1024.png", 1024)
]

for (filename, size) in specs {
    saveIcon(from: masterImage, pixelSize: size, filename: filename)
}

print("Done! All icons generated with correct pixel sizes.")
