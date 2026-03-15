import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var desktopWindow: DesktopWindow?
    private var countdownManager = CountdownManager()
    private var datePickerWindow: NSWindow?
    private var datePicker: NSDatePicker?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()

        if countdownManager.startDate == nil {
            showDatePicker()
        } else {
            showDesktopWidget()
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.title = "🔴"
        }

        let menu = NSMenu()

        let dayItem = NSMenuItem(title: dayString(), action: nil, keyEquivalent: "")
        dayItem.isEnabled = false
        dayItem.tag = 999
        menu.addItem(dayItem)

        menu.addItem(.separator())

        let setDate = NSMenuItem(title: "Set Start Date…", action: #selector(setStartDate), keyEquivalent: "")
        setDate.target = self
        menu.addItem(setDate)

        let reset = NSMenuItem(title: "Reset", action: #selector(resetCountdown), keyEquivalent: "")
        reset.target = self
        menu.addItem(reset)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem?.menu = menu
    }

    private func dayString() -> String {
        let day = countdownManager.currentDay
        if day <= 0 { return "Starts soon" }
        if day > 100 { return "✅ Completed!" }
        return "Day \(day) of 100"
    }

    private func showDatePicker() {
        NSApp.setActivationPolicy(.regular)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Set Start Date"
        window.level = .floating
        window.isReleasedWhenClosed = false

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 160))

        let label = NSTextField(labelWithString: "Choose Your Start Date")
        label.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        label.frame = NSRect(x: 20, y: 115, width: 260, height: 25)
        label.alignment = .center
        contentView.addSubview(label)

        let dp = NSDatePicker()
        dp.datePickerStyle = .textFieldAndStepper
        dp.datePickerElements = .yearMonthDay
        dp.dateValue = Date()
        dp.frame = NSRect(x: 60, y: 70, width: 180, height: 30)
        contentView.addSubview(dp)
        self.datePicker = dp

        let button = NSButton(frame: NSRect(x: 70, y: 15, width: 160, height: 40))
        button.title = "Start Countdown"
        button.bezelStyle = .rounded
        button.contentTintColor = .systemRed
        button.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        button.target = self
        button.action = #selector(confirmDateClicked)
        contentView.addSubview(button)

        window.contentView = contentView
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.datePickerWindow = window

        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func confirmDateClicked() {
        guard let dp = self.datePicker else { return }
        countdownManager.startDate = dp.dateValue
        datePickerWindow?.close()
        datePickerWindow = nil
        datePicker = nil
        showDesktopWidget()
    }

    private func showDesktopWidget() {
        NSApp.setActivationPolicy(.accessory)
        desktopWindow?.close()
        let contentView = ContentView(manager: countdownManager)
        let window = DesktopWindow(contentView: contentView)
        window.makeContextMenu(delegate: self)
        desktopWindow = window

        // Update menubar day count
        if let menu = statusItem?.menu, let dayItem = menu.item(withTag: 999) {
            dayItem.title = dayString()
        }
    }

    @objc private func setStartDate() {
        showDatePicker()
    }

    @objc private func resetCountdown() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "Reset Countdown?"
        alert.informativeText = "This will clear your start date and reset all progress."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")

        if alert.runModal() == .alertFirstButtonReturn {
            countdownManager.startDate = nil
            desktopWindow?.close()
            desktopWindow = nil
            showDatePicker()
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}

extension AppDelegate: DesktopWindowContextMenuDelegate {
    func contextMenuItems() -> [NSMenuItem] {
        let setDate = NSMenuItem(title: "Set Start Date…", action: #selector(setStartDate), keyEquivalent: "")
        setDate.target = self

        let reset = NSMenuItem(title: "Reset", action: #selector(resetCountdown), keyEquivalent: "")
        reset.target = self

        let quit = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self

        return [setDate, reset, .separator(), quit]
    }
}
