//
//  ContentView.swift
//  OpenClawShield MenuBar
//
//  Main UI for security report
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appDelegate: AppDelegate
    @StateObject private var scanner = SecurityScanner.shared
    @StateObject private var updateChecker = UpdateChecker.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: statusIcon)
                    .font(.title2)
                    .foregroundColor(statusColor)
                Text("OpenClaw Shield")
                    .font(.headline)
                Spacer()
                Button(action: {
                    appDelegate.runSecurityScan()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .help("Refresh scan")
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if scanner.isScanning {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Scanning...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        // Status summary
                        StatusSummaryView(scanner: scanner)
                        
                        // Update checker section
                        UpdateSectionView(updateChecker: updateChecker)
                        
                        // Issues list
                        if !scanner.criticalIssues.isEmpty {
                            IssuesSectionView(title: "Critical Issues", issues: scanner.criticalIssues, color: .red)
                        }
                        
                        if !scanner.warningIssues.isEmpty {
                            IssuesSectionView(title: "Warnings", issues: scanner.warningIssues, color: .orange)
                        }
                        
                        if scanner.criticalIssues.isEmpty && scanner.warningIssues.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.green)
                                Text("All checks passed!")
                                    .font(.headline)
                                Text("Last scan: \(scanner.lastScanTime)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer
            HStack {
                Text("Skills: \(scanner.skillsTracked) tracked")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 400, height: 500)
    }
    
    private var statusIcon: String {
        switch scanner.currentStatus {
        case .safe: return "checkmark.shield.fill"
        case .warning: return "exclamationmark.shield.fill"
        case .critical: return "xmark.shield.fill"
        case .unknown: return "questionmark.circle"
        }
    }
    
    private var statusColor: Color {
        switch scanner.currentStatus {
        case .safe: return .green
        case .warning: return .orange
        case .critical: return .red
        case .unknown: return .gray
        }
    }
}

struct UpdateSectionView: View {
    @ObservedObject var updateChecker: UpdateChecker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("OpenClaw Version")
                    .font(.headline)
                Spacer()
                if updateChecker.hasUpdate {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.blue)
                        Text("Update Available")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Version info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Installed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(updateChecker.installedVersion)
                        .font(.system(.body, design: .monospaced))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text(updateChecker.latestVersion)
                            .font(.system(.body, design: .monospaced))
                        if updateChecker.hasUpdate {
                            Image(systemName: "sparkles")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Last check time
            if let lastCheck = updateChecker.lastCheckTime {
                Text("Last checked: \(formatDate(lastCheck))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Error message
            if let error = updateChecker.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(error.contains("successful") ? .green : .orange)
                    .padding(.top, 4)
            }
            
            // Update progress
            if !updateChecker.updateProgress.isEmpty {
                HStack {
                    ProgressView()
                        .scaleEffect(0.6)
                    Text(updateChecker.updateProgress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: {
                    Task {
                        await updateChecker.checkForUpdates()
                    }
                }) {
                    HStack(spacing: 4) {
                        if updateChecker.isChecking {
                            ProgressView()
                                .scaleEffect(0.5)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Check Now")
                    }
                }
                .disabled(updateChecker.isChecking || updateChecker.isUpdating)
                
                Spacer()
                
                Button(action: {
                    Task {
                        _ = await updateChecker.installUpdate()
                    }
                }) {
                    HStack(spacing: 4) {
                        if updateChecker.isUpdating {
                            ProgressView()
                                .scaleEffect(0.5)
                        } else {
                            Image(systemName: "arrow.down.circle")
                        }
                        Text("Update Now")
                    }
                }
                .disabled(!updateChecker.hasUpdate || updateChecker.isChecking || updateChecker.isUpdating)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct StatusSummaryView: View {
    let scanner: SecurityScanner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Security Status")
                    .font(.headline)
                Spacer()
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 16) {
                StatusBadge(count: scanner.criticalIssues.count, label: "Critical", color: .red)
                StatusBadge(count: scanner.warningIssues.count, label: "Warnings", color: .orange)
                StatusBadge(count: scanner.skillsTracked, label: "Skills", color: .blue)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
    
    private var statusText: String {
        switch scanner.currentStatus {
        case .safe: return "Secure"
        case .warning: return "Review Needed"
        case .critical: return "Action Required"
        case .unknown: return "Unknown"
        }
    }
}

struct StatusBadge: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct IssuesSectionView: View {
    let title: String
    let issues: [SecurityIssue]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            ForEach(issues) { issue in
                IssueRowView(issue: issue, color: color)
            }
        }
    }
}

struct IssueRowView: View {
    let issue: SecurityIssue
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(color)
                    .font(.caption)
                Text(issue.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            if let description = issue.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 20)
            }
            
            if let fix = issue.suggestedFix {
                Text(fix)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.leading, 20)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
}
