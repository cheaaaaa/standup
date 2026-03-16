import AppKit
import SwiftUI

@MainActor
final class StandupController: NSObject, ObservableObject {
    static let reminderInterval = 30 * 60
    static let reminderCountdown = 30

    @Published private(set) var secondsUntilReminder = reminderInterval
    @Published private(set) var countdown = reminderCountdown
    @Published private(set) var isReminderVisible = false

    var onStateChange: (() -> Void)?

    var menuStatusText: String {
        if isReminderVisible {
            return "站立提醒中，\(countdown) 秒后自动关闭"
        }

        return "距离下次提醒还有 \(formatted(seconds: secondsUntilReminder))"
    }

    var statusButtonText: String {
        isReminderVisible ? " \(countdown)s" : ""
    }

    private var awakeSince = Date()
    private var ticker: Timer?
    private var reminderPanel: NSPanel?

    override init() {
        super.init()
        startTicker()
    }

    func resetTimer(reason: String) {
        awakeSince = Date()
        secondsUntilReminder = Self.reminderInterval
        countdown = Self.reminderCountdown

        if isReminderVisible {
            reminderPanel?.orderOut(nil)
            isReminderVisible = false
        }

        NSLog("Standup timer reset: %@", reason)
        notifyStateChanged()
    }

    func triggerReminderForTesting() {
        presentReminder()
    }

    func acknowledgeReminder() {
        reminderPanel?.orderOut(nil)
        isReminderVisible = false
        resetTimer(reason: "acknowledged")
    }

    private func startTicker() {
        let ticker = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.handleTick()
            }
        }

        self.ticker = ticker
        RunLoop.main.add(ticker, forMode: .common)
    }

    private func handleTick() {
        if isReminderVisible {
            countdown = max(0, countdown - 1)

            if countdown == 0 {
                reminderPanel?.orderOut(nil)
                isReminderVisible = false
                resetTimer(reason: "countdown-finished")
                return
            }

            notifyStateChanged()
            return
        }

        let elapsed = Int(Date().timeIntervalSince(awakeSince))
        secondsUntilReminder = max(0, Self.reminderInterval - elapsed)

        if secondsUntilReminder == 0 {
            presentReminder()
            return
        }

        notifyStateChanged()
    }

    private func presentReminder() {
        guard !isReminderVisible else {
            return
        }

        countdown = Self.reminderCountdown
        isReminderVisible = true
        ensureReminderPanel()

        if let panel = reminderPanel {
            panel.center()
            NSApp.activate(ignoringOtherApps: true)
            panel.makeKeyAndOrderFront(nil)
        }

        notifyStateChanged()
    }

    private func ensureReminderPanel() {
        guard reminderPanel == nil else {
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 260),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .moveToActiveSpace]
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.contentView = NSHostingView(rootView: ReminderView(controller: self))

        reminderPanel = panel
    }

    private func formatted(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    private func notifyStateChanged() {
        onStateChange?()
    }
}
