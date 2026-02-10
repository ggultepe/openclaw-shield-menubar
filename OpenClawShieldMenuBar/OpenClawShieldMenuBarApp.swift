//
//  OpenClawShieldMenuBarApp.swift
//  OpenClawShield MenuBar
//
//  Security monitoring for OpenClaw
//

import SwiftUI
import UserNotifications

@main
struct OpenClawShieldMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, UNUserNotificationCenterDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permission
        UpdateChecker.shared.requestNotificationPermission()
        
        // Setup notification actions
        setupNotificationActions()
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            updateStatusIcon(.unknown)
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView(appDelegate: self))
        
        // Run initial scan
        runSecurityScan()
        
        // Schedule periodic scans (every 30 minutes)
        timer = Timer.scheduledTimer(withTimeInterval: 30 * 60, repeats: true) { [weak self] _ in
            self?.runSecurityScan()
        }
        
        // Start update monitoring
        UpdateChecker.shared.startMonitoring()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up timers to prevent resource leaks
        timer?.invalidate()
        timer = nil
        
        UpdateChecker.shared.stopMonitoring()
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func updateStatusIcon(_ status: SecurityStatus) {
        if let button = statusItem.button {
            switch status {
            case .safe:
                button.image = NSImage(systemSymbolName: "checkmark.shield.fill", accessibilityDescription: "Secure")
                button.image?.isTemplate = true
            case .warning:
                button.image = NSImage(systemSymbolName: "exclamationmark.shield.fill", accessibilityDescription: "Warnings")
                button.image?.isTemplate = true
            case .critical:
                button.image = NSImage(systemSymbolName: "xmark.shield.fill", accessibilityDescription: "Critical Issues")
                button.image?.isTemplate = true
            case .unknown:
                button.image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: "Unknown")
                button.image?.isTemplate = true
            }
        }
    }
    
    func runSecurityScan() {
        Task {
            await SecurityScanner.shared.runScan()
            await MainActor.run {
                updateStatusIcon(SecurityScanner.shared.currentStatus)
            }
        }
    }
    
    // MARK: - Notification Setup
    
    private func setupNotificationActions() {
        let updateAction = UNNotificationAction(
            identifier: "UPDATE_NOW",
            title: "Update Now",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "UPDATE_CATEGORY",
            actions: [updateAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "UPDATE_NOW" {
            // Open popover and trigger update
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
            
            // Trigger update
            Task {
                _ = await UpdateChecker.shared.installUpdate()
            }
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
}

enum SecurityStatus {
    case safe
    case warning
    case critical
    case unknown
}
