// Draws the link-preview card (Open Graph image) for NeuRoutine.
//
// 1200x630, the size iMessage, Slack and the rest expect. Generated, not
// exported from a design tool, for the same reason the app icon is: a card
// that is drawn by a script can be redrawn when the brand changes.
//
//   swift tools/make-og-image.swift
//
// Reads  neuroutine/icon.png  (the app icon the site already serves)
// Writes neuroutine/og.png

import AppKit

let W: CGFloat = 1200, H: CGFloat = 630

func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
}

// The site's light palette: previews render on light and dark chat bubbles
// alike, and a light card reads in both.
let bg = color(0xF7F6FB)
let ink = color(0x1C1B22)
let muted = color(0x5C5966)
let accent = color(0x6D3DF0)

let cwd = FileManager.default.currentDirectoryPath
guard let icon = NSImage(contentsOfFile: cwd + "/neuroutine/icon.png") else {
    fputs("run from the repo root: neuroutine/icon.png not found\n", stderr)
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
draw("NeuRoutine", at: NSPoint(x: textX, y: 340),
     font: .systemFont(ofSize: 96, weight: .semibold), color: ink)
draw("A planner that stays calm.", at: NSPoint(x: textX, y: 262),
     font: .systemFont(ofSize: 44, weight: .regular), color: muted)
draw("One thing at a time · energy, not hustle", at: NSPoint(x: textX, y: 196),
     font: .systemFont(ofSize: 34, weight: .regular), color: muted)
draw("never notifies", at: NSPoint(x: textX, y: 142),
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
try! png.write(to: URL(fileURLWithPath: cwd + "/neuroutine/og.png"))
print("wrote neuroutine/og.png (\(png.count / 1024) KB)")
