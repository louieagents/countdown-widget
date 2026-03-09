import AppKit
import SwiftUI

protocol DesktopWindowContextMenuDelegate: AnyObject {
    func contextMenuItems() -> [NSMenuItem]
}

class DesktopWindow: NSWindow {
    private weak var contextMenuDelegate: DesktopWindowContextMenuDelegate?

    init<Content: View>(contentView: Content) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 500),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.isMovableByWindowBackground = false
        self.isReleasedWhenClosed = false

        let hostView = NSHostingView(rootView: contentView)
        hostView.frame = self.frame

        // Add vibrancy background
        let visualEffect = NSVisualEffectView(frame: self.frame)
        visualEffect.material = .hudWindow
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 16
        visualEffect.layer?.masksToBounds = true
        visualEffect.autoresizingMask = [.width, .height]

        hostView.autoresizingMask = [.width, .height]
        visualEffect.addSubview(hostView)

        self.contentView = visualEffect

        // Position in bottom-right area of screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - self.frame.width - 40
            let y = screenFrame.minY + 40
            self.setFrameOrigin(NSPoint(x: x, y: y))
        }

        self.orderFront(nil)
    }

    func makeContextMenu(delegate: DesktopWindowContextMenuDelegate) {
        self.contextMenuDelegate = delegate
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let delegate = contextMenuDelegate else { return }
        let menu = NSMenu()
        for item in delegate.contextMenuItems() {
            menu.addItem(item)
        }
        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }

    // Option+Click to drag
    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(.option) {
            self.performDrag(with: event)
        }
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
