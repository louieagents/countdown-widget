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

        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.isMovableByWindowBackground = false
        self.isReleasedWhenClosed = false
        self.acceptsMouseMovedEvents = true

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
        guard let delegate = contextMenuDelegate else {
            super.rightMouseDown(with: event)
            return
        }
        let menu = NSMenu()
        for item in delegate.contextMenuItems() {
            menu.addItem(item)
        }
        NSMenu.popUpContextMenu(menu, with: event, for: self.contentView!)
    }

    // Click to drag (no modifier needed)
    override func mouseDown(with event: NSEvent) {
        self.performDrag(with: event)
    }

    // Desktop windows need to accept mouse events
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
