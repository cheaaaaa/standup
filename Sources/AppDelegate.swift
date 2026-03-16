import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let controller = StandupController()

    private var statusItem: NSStatusItem!
    private let statusMenu = NSMenu()
    private let statusLineItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private lazy var resetItem = NSMenuItem(
        title: "立即重新计时",
        action: #selector(resetTimer),
        keyEquivalent: "r"
    )
    private lazy var showReminderItem = NSMenuItem(
        title: "立即显示提醒",
        action: #selector(showReminderNow),
        keyEquivalent: "s"
    )
    private lazy var quitItem = NSMenuItem(
        title: "退出 Standup",
        action: #selector(quitApp),
        keyEquivalent: "q"
    )

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setUpStatusItem()
        setUpLifecycleObservers()

        controller.onStateChange = { [weak self] in
            self?.refreshStatusMenu()
        }

        refreshStatusMenu()
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
    }

    private func setUpStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else {
            return
        }

        if let image = NSImage(systemSymbolName: "figure.stand", accessibilityDescription: "Standup") {
            image.isTemplate = true
            button.image = image
            button.imagePosition = .imageLeading
        } else {
            button.title = "站"
        }

        button.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        statusMenu.autoenablesItems = false
        statusLineItem.isEnabled = false
        statusMenu.addItem(statusLineItem)
        statusMenu.addItem(.separator())
        statusMenu.addItem(resetItem)
        statusMenu.addItem(showReminderItem)
        statusMenu.addItem(.separator())
        statusMenu.addItem(quitItem)

        statusItem.menu = statusMenu
    }

    private func setUpLifecycleObservers() {
        let workspaceCenter = NSWorkspace.shared.notificationCenter

        workspaceCenter.addObserver(
            self,
            selector: #selector(handleLifecycleReset(_:)),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleLifecycleReset(_:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleLifecycleReset(_:)),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleLifecycleReset(_:)),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )

        let distributedCenter = DistributedNotificationCenter.default()
        distributedCenter.addObserver(
            self,
            selector: #selector(handleLifecycleReset(_:)),
            name: .screenLocked,
            object: nil
        )
        distributedCenter.addObserver(
            self,
            selector: #selector(handleLifecycleReset(_:)),
            name: .screenUnlocked,
            object: nil
        )
    }

    private func refreshStatusMenu() {
        statusLineItem.title = controller.menuStatusText
        showReminderItem.isEnabled = !controller.isReminderVisible

        guard let button = statusItem.button else {
            return
        }

        button.toolTip = controller.menuStatusText
        button.title = controller.statusButtonText
    }

    @objc
    private func resetTimer() {
        controller.resetTimer(reason: "manual")
    }

    @objc
    private func showReminderNow() {
        controller.triggerReminderForTesting()
    }

    @objc
    private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc
    private func handleLifecycleReset(_ notification: Notification) {
        controller.resetTimer(reason: notification.name.rawValue)
    }
}

private extension Notification.Name {
    static let screenLocked = Notification.Name("com.apple.screenIsLocked")
    static let screenUnlocked = Notification.Name("com.apple.screenIsUnlocked")
}
