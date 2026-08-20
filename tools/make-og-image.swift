// Draws an app's link-preview card (Open Graph image).
//
// 1200x630, the size iMessage, Slack and the rest expect. Generated, not
// exported from a design tool, for the same reason the app icons are: a card
// that is drawn by a script can be redrawn when the brand changes.
//
//   swift tools/make-og-image.swift                            # NeuRoutine
//   swift tools/make-og-image.swift <dir> <name> <tagline> <line2> <line3> <accentHex>
//   e.g.  swift tools/make-og-image.swift wiederfind Wiederfind \
//           "Learning that stays calm." "lessons at your pace · no timers, no streaks" \
//           "never notifies" 2F5E8F
//
// Reads  <dir>/icon.png  (the app icon the site already serves)
// Writes <dir>/og.png

import AppKit

let W: CGFloat = 1200, H: CGFloat = 630

func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
}

let args = CommandLine.arguments
let dir = args.count > 1 ? args[1] : "neuroutine"
let name = args.count > 2 ? args[2] : "NeuRoutine"
let tagline = args.count > 3 ? args[3] : "A planner that stays calm."
let line2 = args.count > 4 ? args[4] : "One thing at a time · energy, not hustle"
let line3 = args.count > 5 ? args[5] : "never notifies"
let accentHex = args.count > 6 ? UInt32(args[6], radix: 16) ?? 0x6D3DF0 : 0x6D3DF0

// The shared light palette: previews render on light and dark chat bubbles
// alike, and a light card reads in both. Only the accent is per-app.
let bg = color(0xF7F6FB)
let ink = color(0x1C1B22)
let muted = color(0x5C5966)
let accent = color(accentHex)

let cwd = FileManager.default.currentDirectoryPath
guard let icon = NSImage(contentsOfFile: cwd + "/\(dir)/icon.png") else {
    fputs("run from the repo root: \(dir)/icon.png not found\n", stderr)
    exit(1)
}

let image = NSImage(size: NSSize(width: W, height: H))
image.lockFocus()

bg.setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

// A quiet accent rule along the bottom edge — the one brand colour, used once.
accent.setFill()
NSRect(x: 0, y: 0, width: W, height: 14).fill()

// The icon, left, with the corner radius iOS would give it.
let iconSize: CGFloat = 300
let iconRect = NSRect(x: 120, y: (H - iconSize) / 2 + 10, width: iconSize, height: iconSize)
let clip = NSBezierPath(roundedRect: iconRect, xRadius: iconSize * 0.22, yRadius: iconSize * 0.22)
NSGraphicsContext.saveGraphicsState()
clip.addClip()
icon.draw(in: iconRect)
NSGraphicsContext.restoreGraphicsState()

func draw(_ text: String, at point: NSPoint, font: NSFont, color: NSColor) {
    (text as NSString).draw(at: point, withAttributes: [.font: font, .foregroundColor: color])
}

let textX: CGFloat = 490
draw(name, at: NSPoint(x: textX, y: 340),
     font: .systemFont(ofSize: 96, weight: .semibold), color: ink)
draw(tagline, at: NSPoint(x: textX, y: 262),
     font: .systemFont(ofSize: 44, weight: .regular), color: muted)
draw(line2, at: NSPoint(x: textX, y: 196),
     font: .systemFont(ofSize: 34, weight: .regular), color: muted)
draw(line3, at: NSPoint(x: textX, y: 142),
     font: .systemFont(ofSize: 34, weight: .regular), color: muted)

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff) else {
    fputs("could not rasterise\n", stderr)
    exit(1)
}
rep.size = NSSize(width: W, height: H)
guard let png = rep.representation(using: .png, properties: [:]) else {
    fputs("could not encode png\n", stderr)
    exit(1)
}
try! png.write(to: URL(fileURLWithPath: cwd + "/\(dir)/og.png"))
print("wrote \(dir)/og.png (\(png.count / 1024) KB)")
