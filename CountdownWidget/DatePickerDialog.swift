import AppKit

class DatePickerDialog {
    private let onDateSelected: (Date) -> Void
    private var window: NSWindow?

    init(onDateSelected: @escaping (Date) -> Void) {
        self.onDateSelected = onDateSelected
    }

    func show() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 160),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Set Start Date"
        window.level = .floating
        window.isReleasedWhenClosed = false
        self.window = window

        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 160))

        // Label
        let label = NSTextField(labelWithString: "Choose Your Start Date")
        label.font = NSFont.systemFont(ofSize: 16, weight: .bold)
        label.frame = NSRect(x: 20, y: 115, width: 260, height: 25)
        label.alignment = .center
        contentView.addSubview(label)

        // Date Picker (native AppKit)
        let datePicker = NSDatePicker()
        datePicker.datePickerStyle = .textFieldAndStepper
        datePicker.datePickerElements = .yearMonthDay
        datePicker.dateValue = Date()
        datePicker.frame = NSRect(x: 60, y: 70, width: 180, height: 30)
        datePicker.tag = 100
        contentView.addSubview(datePicker)

        // Button
        let button = NSButton(frame: NSRect(x: 70, y: 15, width: 160, height: 40))
        button.title = "Start Countdown"
        button.bezelStyle = .rounded
        button.contentTintColor = .systemRed
        button.font = NSFont.systemFont(ofSize: 14, weight: .semibold)
        button.target = self
        button.action = #selector(confirmDate(_:))
        button.tag = 200
        contentView.addSubview(button)

        window.contentView = contentView
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func confirmDate(_ sender: NSButton) {
        guard let contentView = window?.contentView,
              let datePicker = contentView.viewWithTag(100) as? NSDatePicker else { return }
        let selectedDate = datePicker.dateValue
        onDateSelected(selectedDate)
        window?.close()
        window = nil
    }
}
