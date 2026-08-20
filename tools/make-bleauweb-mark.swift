// Draws the BleauWeb mark: the umbrella brand for the apps hub.
//
// A rounded square in the site's violet carrying three quiet ripples — bleu,
// water, calm — the same restraint the apps practice, in one glyph that stays
// legible at favicon size. Drawn, not exported, like every mark here.
//
//   swift tools/make-bleauweb-mark.swift
//
// Writes icon.png (360x360, transparent rounded corners) at the repo root.

import AppKit

let S: CGFloat = 360

func color(_ hex: UInt32) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
}

let violet = color(0x6D3DF0)
let deep = color(0x5A2FD0)

let image = NSImage(size: NSSize(width: S, height: S))
image.lockFocus()

// The tile, with the corner radius iOS gives icons.
let tile = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: S, height: S),
                        xRadius: S * 0.22, yRadius: S * 0.22)
let gradient = NSGradient(starting: violet, ending: deep)!
gradient.draw(in: tile, angle: -90)

// Three ripples, the middle one widest: water settling, not waving.
func ripple(y: CGFloat, inset: CGFloat, alpha: CGFloat) {
    let path = NSBezierPath()
    path.lineWidth = 26
    path.lineCapStyle = .round
    let left = 70 + inset, right = S - 70 - inset
    path.move(to: NSPoint(x: left, y: y))
    path.curve(to: NSPoint(x: (left + right) / 2, y: y),
               controlPoint1: NSPoint(x: left + (right - left) * 0.22, y: y + 22),
               controlPoint2: NSPoint(x: (left + right) / 2 - (right - left) * 0.14, y: y + 22))
    path.curve(to: NSPoint(x: right, y: y),
               controlPoint1: NSPoint(x: (left + right) / 2 + (right - left) * 0.14, y: y - 22),
               controlPoint2: NSPoint(x: right - (right - left) * 0.22, y: y - 22))
    NSColor.white.withAlphaComponent(alpha).setStroke()
    path.stroke()
}

ripple(y: 236, inset: 26, alpha: 1.0)
ripple(y: 172, inset: 0, alpha: 0.55)
ripple(y: 110, inset: 40, alpha: 0.32)

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else {
    fputs("could not encode\n", stderr)
    exit(1)
}
let out = FileManager.default.currentDirectoryPath + "/icon.png"
try! png.write(to: URL(fileURLWithPath: out))
print("wrote icon.png (\(png.count / 1024) KB)")
