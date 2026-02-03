//
//  OpenClawShieldMenuBarApp.swift
//  OpenClawShield MenuBar
//
//  Security monitoring for OpenClaw
//

import SwiftUI

@main
struct OpenClawShieldMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var timer: Timer?
    
    @Published var securityStatus: SecurityStatus = .unknown
    
    func applicationDidFinishLaunching(_ notification: Notification) {
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
        securityStatus = status
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
}

enum SecurityStatus {
    case safe
    case warning
    case critical
    case unknown
}
