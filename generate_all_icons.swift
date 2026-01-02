import Cocoa

// Configuration
let sourcePath = "/Users/vicente.tancoedu.uah.es/echo/Echo/Resources/Assets.xcassets/AppIcon.appiconset/Icon-1024.png"
let destFolder = "/Users/vicente.tancoedu.uah.es/echo/Echo/Resources/Assets.xcassets/AppIcon.appiconset"

guard let image = NSImage(contentsOf: URL(fileURLWithPath: sourcePath)) else {
    print("Error: Could not load source image at \(sourcePath)")
    exit(1)
}

struct IconSpec {
    let name: String
    let size: CGFloat
}

let specs: [IconSpec] = [
    // iPhone
    IconSpec(name: "Icon-20@2x.png", size: 40),
    IconSpec(name: "Icon-20@3x.png", size: 60),
    IconSpec(name: "Icon-29@2x.png", size: 58),
    IconSpec(name: "Icon-29@3x.png", size: 87),
    IconSpec(name: "Icon-40@2x.png", size: 80),
    IconSpec(name: "Icon-40@3x.png", size: 120),
    IconSpec(name: "Icon-60@2x.png", size: 120),
    IconSpec(name: "Icon-60@3x.png", size: 180),
    
    // iPad
    IconSpec(name: "Icon-20.png", size: 20),
    IconSpec(name: "Icon-29.png", size: 29),
    IconSpec(name: "Icon-40.png", size: 40),
    IconSpec(name: "Icon-76.png", size: 76),
    IconSpec(name: "Icon-76@2x.png", size: 152),
    IconSpec(name: "Icon-83.5@2x.png", size: 167),
    
    // Marketing
    IconSpec(name: "Icon-1024.png", size: 1024)
]

func resize(image: NSImage, to newSize: CGSize, saveTo path: String) {
    let newImage = NSImage(size: newSize)
    newImage.lockFocus()
    image.draw(in: NSRect(origin: .zero, size: newSize),
               from: NSRect(origin: .zero, size: image.size),
               operation: .copy,
               fraction: 1.0)
    newImage.unlockFocus()
    
    guard let tiffData = newImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Error converting to PNG: \(path)")
        return
    }
    
    try? pngData.write(to: URL(fileURLWithPath: path))
    print("Generated \(path)")
}

for spec in specs {
    let path = destFolder + "/" + spec.name
    // Skip if it's the source itself (1024) and we are just avoiding overwrite issues,
    // although drawing it onto itself is fine in memory.
    if spec.size == 1024 { continue } 
    resize(image: image, to: CGSize(width: spec.size, height: spec.size), saveTo: path)
}

print("Done. Generated all icons.")
