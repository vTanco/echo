import Cocoa

// Configuration
let size = 1024.0
let rect = CGRect(x: 0, y: 0, width: size, height: size)
let image = NSImage(size: NSSize(width: size, height: size))

image.lockFocus()

// 1. Background (Dark Gradient)
let bgPath = NSBezierPath(rect: rect)
let bgGradient = NSGradient(colors: [
    NSColor(red: 0.05, green: 0.02, blue: 0.10, alpha: 1.0), // Deep Dark Violet
    NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)     // Black
])
bgGradient?.draw(in: bgPath, angle: -45)

// 2. Main Orb Glow
let center = NSPoint(x: size/2, y: size/2)
let orbRadius = size * 0.35

let glowGradient = NSGradient(colors: [
    NSColor(red: 0.0, green: 0.9, blue: 0.97, alpha: 0.3), // Cyan Glow
    NSColor.clear
])
let glowRect = CGRect(x: center.x - orbRadius * 1.5, y: center.y - orbRadius * 1.5, width: orbRadius * 3, height: orbRadius * 3)
glowGradient?.draw(in: NSBezierPath(ovalIn: glowRect), relativeCenterPosition: .zero)

// 3. The Orb (Gradient Circle)
let orbPath = NSBezierPath(ovalIn: CGRect(x: center.x - orbRadius, y: center.y - orbRadius, width: orbRadius * 2, height: orbRadius * 2))
let orbGradient = NSGradient(colors: [
    NSColor(red: 0.0, green: 0.9, blue: 0.97, alpha: 1.0), // Accent Cyan
    NSColor(red: 1.0, green: 0.0, blue: 0.88, alpha: 1.0)  // Accent Magenta
])
orbGradient?.draw(in: orbPath, angle: 45)

// 4. Inner Ring (White/Energy)
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

image.unlockFocus()

// Save to PNG
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: "Icon-1024.png")
    try? pngData.write(to: url)
    print("Logo generated details: saved to Icon-1024.png")
}
