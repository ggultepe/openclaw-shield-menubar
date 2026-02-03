//
//  SecurityScanner.swift
//  OpenClawShield MenuBar
//
//  Runs security scans and parses results
//

import Foundation
import Combine

class SecurityScanner: ObservableObject {
    static let shared = SecurityScanner()
    
    @Published var isScanning = false
    @Published var currentStatus: SecurityStatus = .unknown
    @Published var criticalIssues: [SecurityIssue] = []
    @Published var warningIssues: [SecurityIssue] = []
    @Published var skillsTracked: Int = 0
    @Published var lastScanTime: String = "Never"
    
    private let scriptsPath = "\(NSHomeDirectory())/clawd/scripts"
    
    private init() {}
    
    func runScan() async {
        await MainActor.run {
            isScanning = true
        }
        
        // Run monitor-skills.sh --check
        await checkSkillChanges()
        
        // Update last scan time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: Date())
        
        await MainActor.run {
            lastScanTime = timeString
            isScanning = false
            updateOverallStatus()
        }
    }
    
    private func checkSkillChanges() async {
        let scriptPath = "\(scriptsPath)/monitor-skills.sh"
        
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            await MainActor.run {
                criticalIssues.append(SecurityIssue(
                    title: "Monitor script not found",
                    description: "monitor-skills.sh not found at \(scriptPath)",
                    severity: .critical,
                    suggestedFix: nil,
                    canAutoFix: false
                ))
            }
            return
        }
        
        let result = await runShellCommand(scriptPath, args: ["--check"])
        
        await MainActor.run {
            parseMonitorOutput(result.output, exitCode: result.exitCode)
        }
    }
    
    private func parseMonitorOutput(_ output: String, exitCode: Int32) {
        // Parse the monitor-skills.sh output
        
        // Count tracked skills from baseline
        let baselinePath = "\(NSHomeDirectory())/clawd/memory/skills-baseline.txt"
        if let baselineContent = try? String(contentsOfFile: baselinePath) {
            skillsTracked = baselineContent.components(separatedBy: "\n").filter { !$0.isEmpty }.count
        }
        
        // Check exit code
        if exitCode == 0 {
            // No changes detected
            return
        } else if exitCode == 1 {
            // Changes detected - parse them
            var issues: [SecurityIssue] = []
            
            let lines = output.components(separatedBy: "\n")
            for line in lines {
                if line.contains("New skills detected:") || line.contains("+ ") {
                    if line.contains("+ ") {
                        let skillName = line.replacingOccurrences(of: "+ ", with: "").trimmingCharacters(in: .whitespaces)
                        issues.append(SecurityIssue(
                            title: "New skill detected: \(skillName)",
                            description: "A new skill was added since last baseline",
                            severity: .warning,
                            suggestedFix: "Run: ~/clawd/scripts/monitor-skills.sh --init",
                            canAutoFix: false
                        ))
                    }
                } else if line.contains("Removed skills:") || line.contains("- ") {
                    if line.contains("- ") {
                        let skillName = line.replacingOccurrences(of: "- ", with: "").trimmingCharacters(in: .whitespaces)
                        issues.append(SecurityIssue(
                            title: "Skill removed: \(skillName)",
                            description: "A skill was removed since last baseline",
                            severity: .warning,
                            suggestedFix: "Run: ~/clawd/scripts/monitor-skills.sh --init",
                            canAutoFix: false
                        ))
                    }
                } else if line.contains("Modified skill:") {
                    let skillName = line.replacingOccurrences(of: "✏️  Modified skill:", with: "")
                        .replacingOccurrences(of: "Modified skill:", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    issues.append(SecurityIssue(
                        title: "Modified skill: \(skillName)",
                        description: "Skill content changed since last baseline",
                        severity: .critical,
                        suggestedFix: "Investigate changes, then update baseline",
                        canAutoFix: false
                    ))
                }
            }
            
            warningIssues.append(contentsOf: issues.filter { $0.severity == .warning })
            criticalIssues.append(contentsOf: issues.filter { $0.severity == .critical })
        }
    }
    
    private func updateOverallStatus() {
        if !criticalIssues.isEmpty {
            currentStatus = .critical
        } else if !warningIssues.isEmpty {
            currentStatus = .warning
        } else {
            currentStatus = .safe
        }
    }
    
    private func runShellCommand(_ path: String, args: [String] = []) async -> (output: String, exitCode: Int32) {
        return await withCheckedContinuation { continuation in
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
                
                continuation.resume(returning: (output, process.terminationStatus))
            } catch {
                continuation.resume(returning: ("Error: \(error.localizedDescription)", -1))
            }
        }
    }
}

struct SecurityIssue: Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let severity: IssueSeverity
    let suggestedFix: String?
    let canAutoFix: Bool
    
    init(title: String, description: String?, severity: IssueSeverity, suggestedFix: String?, canAutoFix: Bool) {
        self.title = title
        self.description = description
        self.severity = severity
        self.suggestedFix = suggestedFix
        self.canAutoFix = canAutoFix
    }
}

enum IssueSeverity {
    case critical
    case warning
    case info
}
