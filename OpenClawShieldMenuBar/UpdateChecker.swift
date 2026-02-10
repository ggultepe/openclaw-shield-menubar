//
//  UpdateChecker.swift
//  OpenClawShield MenuBar
//
//  Checks for OpenClaw updates and manages installation
//

import Foundation
import Combine
import UserNotifications

class UpdateChecker: ObservableObject {
    static let shared = UpdateChecker()
    
    @Published var installedVersion: String = "Unknown"
    @Published var latestVersion: String = "Unknown"
    @Published var isChecking = false
    @Published var isUpdating = false
    @Published var lastCheckTime: Date?
    @Published var errorMessage: String?
    @Published var updateProgress: String = ""
    
    private var timer: Timer?
    private let checkInterval: TimeInterval = 14400 // 4 hours in seconds
    private let userDefaults = UserDefaults.standard
    private let lastCheckKey = "LastUpdateCheckTime"
    private let notificationIdentifier = "com.openclaw.shield.update"
    
    var hasUpdate: Bool {
        guard installedVersion != "Unknown", latestVersion != "Unknown" else { return false }
        return compareVersions(installedVersion, latestVersion) == .orderedAscending
    }
    
    var isGatewayRunning: Bool {
        let result = runShellCommandSync("/usr/bin/pgrep", args: ["-f", "openclaw gateway"])
        return result.exitCode == 0 && !result.output.isEmpty
    }
    
    private init() {
        loadLastCheckTime()
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        // Check on launch if >4 hours since last check
        if shouldCheckForUpdate() {
            Task {
                await checkForUpdates()
            }
        }
        
        // Schedule periodic checks
        timer = Timer.scheduledTimer(withTimeInterval: checkInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.checkForUpdates()
            }
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    func checkForUpdates() async {
        await MainActor.run {
            isChecking = true
            errorMessage = nil
        }
        
        // Check installed version
        let installed = await getInstalledVersion()
        
        // Check latest version
        let latest = await getLatestVersion()
        
        await MainActor.run {
            installedVersion = installed
            latestVersion = latest
            lastCheckTime = Date()
            saveLastCheckTime()
            isChecking = false
            
            // Send notification if update available
            if hasUpdate {
                sendUpdateNotification()
            }
        }
    }
    
    func installUpdate() async -> Bool {
        // Check if npm is available
        guard let npmPath = findNpmPath() else {
            await MainActor.run {
                errorMessage = "npm not found. Install Node.js from nodejs.org or via Homebrew: brew install node"
            }
            return false
        }
        
        await MainActor.run {
            isUpdating = true
            errorMessage = nil
            updateProgress = "Starting update..."
        }
        
        let wasGatewayRunning = isGatewayRunning
        
        // Run npm install
        let result = await runShellCommand(npmPath, args: ["-g", "install", "openclaw@latest"])
        
        await MainActor.run {
            isUpdating = false
            updateProgress = ""
            
            if result.exitCode == 0 {
                installedVersion = latestVersion
                
                if wasGatewayRunning {
                    errorMessage = "Update successful! ⚠️ Gateway was running - restart it to use the new version: openclaw gateway restart"
                } else {
                    errorMessage = nil
                }
            } else {
                // Check if this is a permission error
                let output = result.output.lowercased()
                let isPermissionError = output.contains("eacces") ||
                                       output.contains("permission denied")
                
                if isPermissionError {
                    errorMessage = "Update requires admin access. Run in Terminal:\nsudo npm -g install openclaw@latest"
                } else {
                    // Sanitize error output for display
                    let sanitized = String(result.output
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .prefix(200))
                        .replacingOccurrences(of: "\n", with: " ")
                    errorMessage = "Update failed: \(sanitized)"
                }
            }
        }
        
        // Refresh version after update
        await checkForUpdates()
        
        return result.exitCode == 0
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func shouldCheckForUpdate() -> Bool {
        guard let lastCheck = lastCheckTime else { return true }
        return Date().timeIntervalSince(lastCheck) > checkInterval
    }
    
    private func loadLastCheckTime() {
        if let timestamp = userDefaults.object(forKey: lastCheckKey) as? Date {
            lastCheckTime = timestamp
        }
    }
    
    private func saveLastCheckTime() {
        if let time = lastCheckTime {
            userDefaults.set(time, forKey: lastCheckKey)
        }
    }
    
    private func getInstalledVersion() async -> String {
        // Try openclaw --version
        let result = await runShellCommand("/usr/local/bin/openclaw", args: ["--version"], timeout: 5)
        
        if result.exitCode == 0 {
            let version = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
            return version.isEmpty ? "Unknown" : version
        }
        
        // Try with explicit path search
        for path in ["/usr/local/bin/openclaw", "/opt/homebrew/bin/openclaw", "\(NSHomeDirectory())/.nvm/versions/node/*/bin/openclaw"] {
            if path.contains("*") {
                // Glob pattern - try to find it
                if let found = try? FileManager.default.contentsOfDirectory(atPath: NSHomeDirectory() + "/.nvm/versions/node/") {
                    for nodeVersion in found {
                        let fullPath = "\(NSHomeDirectory())/.nvm/versions/node/\(nodeVersion)/bin/openclaw"
                        if FileManager.default.fileExists(atPath: fullPath) {
                            let result = await runShellCommand(fullPath, args: ["--version"], timeout: 5)
                            if result.exitCode == 0 {
                                return result.output.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }
                    }
                }
            } else if FileManager.default.fileExists(atPath: path) {
                let result = await runShellCommand(path, args: ["--version"], timeout: 5)
                if result.exitCode == 0 {
                    return result.output.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return "Not installed"
    }
    
    private func getLatestVersion() async -> String {
        // Find npm path
        guard let npmPath = findNpmPath() else {
            await MainActor.run {
                if installedVersion == "Not installed" {
                    errorMessage = "npm not found. Install from nodejs.org"
                } else {
                    errorMessage = "Cannot check for updates: npm not found"
                }
            }
            return "Unknown"
        }
        
        // Run npm show openclaw version
        let result = await runShellCommand(npmPath, args: ["show", "openclaw", "version"], timeout: 10)
        
        if result.exitCode == 0 {
            return result.output.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // Network error or timeout
            await MainActor.run {
                errorMessage = "Check failed (offline?)"
            }
            return "Unknown"
        }
    }
    
    private func findNpmPath() -> String? {
        // Common npm locations
        let possiblePaths = [
            "/usr/local/bin/npm",
            "/opt/homebrew/bin/npm",
            "/usr/bin/npm"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        // Check NVM installation (similar to openclaw detection)
        let nvmBasePath = "\(NSHomeDirectory())/.nvm/versions/node/"
        if let nodeVersions = try? FileManager.default.contentsOfDirectory(atPath: nvmBasePath) {
            for nodeVersion in nodeVersions {
                // Validate: must be semantic version format (v22.0.0 or 22.0.0)
                guard nodeVersion.range(of: #"^v?\d+\.\d+\.\d+$"#, options: .regularExpression) != nil else {
                    continue  // Skip non-version directories
                }
                
                let npmPath = "\(nvmBasePath)\(nodeVersion)/bin/npm"
                if FileManager.default.fileExists(atPath: npmPath) {
                    return npmPath
                }
            }
        }
        
        // Try which npm
        let result = runShellCommandSync("/usr/bin/which", args: ["npm"])
        if result.exitCode == 0 {
            let path = result.output.trimmingCharacters(in: .whitespacesAndNewlines)
            if !path.isEmpty {
                return path
            }
        }
        
        return nil
    }
    
    private func sendUpdateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "OpenClaw Update Available"
        content.body = "Version \(latestVersion) is now available (you have \(installedVersion))"
        content.sound = .default
        content.categoryIdentifier = "UPDATE_CATEGORY"
        
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: nil // Immediate
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    private func compareVersions(_ v1: String, _ v2: String) -> ComparisonResult {
        // Extract numeric part only (before first pre-release or build metadata)
        // e.g., "2026.2.6-beta.1" -> "2026.2.6", "2026.2.6+build.123" -> "2026.2.6"
        let cleanV1 = v1.split(separator: "-").first?.split(separator: "+").first.map(String.init) ?? v1
        let cleanV2 = v2.split(separator: "-").first?.split(separator: "+").first.map(String.init) ?? v2
        
        let parts1 = cleanV1.split(separator: ".").compactMap { Int($0) }
        let parts2 = cleanV2.split(separator: ".").compactMap { Int($0) }
        
        // Compare numeric parts
        for i in 0..<max(parts1.count, parts2.count) {
            let p1 = i < parts1.count ? parts1[i] : 0
            let p2 = i < parts2.count ? parts2[i] : 0
            
            if p1 < p2 { return .orderedAscending }
            if p1 > p2 { return .orderedDescending }
        }
        
        // If numeric parts are equal, check for pre-release suffix
        // Pre-release versions (with "-") are considered LESS than release versions
        // e.g., "2026.2.6-beta.1" < "2026.2.6"
        let hasPrerelease1 = v1.contains("-")
        let hasPrerelease2 = v2.contains("-")
        
        if hasPrerelease1 && !hasPrerelease2 {
            return .orderedAscending  // pre-release < release
        } else if !hasPrerelease1 && hasPrerelease2 {
            return .orderedDescending  // release > pre-release
        }
        
        return .orderedSame
    }
    
    // MARK: - Shell Execution
    
    private func runShellCommand(_ path: String, args: [String] = [], timeout: TimeInterval = 30) async -> (output: String, exitCode: Int32) {
        return await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: path)
            process.arguments = args
            
            let pipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = pipe
            process.standardError = errorPipe
            
            var didTimeout = false
            
            // Timeout handler
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if process.isRunning {
                    didTimeout = true
                    process.terminate()
                }
            }
            
            // Progress monitoring for updates
            if args.contains("install") {
                Task { @MainActor in
                    updateProgress = "Installing..."
                }
            }
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                var output = String(data: data, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
                
                if !errorOutput.isEmpty {
                    output += "\n" + errorOutput
                }
                
                if didTimeout {
                    output = "Command timed out after \(Int(timeout)) seconds"
                    continuation.resume(returning: (output, -1))
                } else {
                    continuation.resume(returning: (output, process.terminationStatus))
                }
            } catch {
                continuation.resume(returning: ("Error: \(error.localizedDescription)", -1))
            }
        }
    }
    
    private func runShellCommandSync(_ path: String, args: [String] = []) -> (output: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            return (output, process.terminationStatus)
        } catch {
            return ("Error: \(error.localizedDescription)", -1)
        }
    }
}
