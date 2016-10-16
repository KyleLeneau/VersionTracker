//
//  VersionTracker.swift
//  VersionTracker
//
//  Created by Kyle LeNeau on 4/2/16.
//  Copyright © 2016 Kyle LeNeau. All rights reserved.
//

import Foundation

private let kUserDefaultsVersionHistory = "kVTVersionHistory"
private let kVersionsKey = "kVTVersions"
private let kBuildsKey = "kVTBuilds"

public struct VersionTracking {
    
    public typealias FirstLaunch = () -> Void
    
    static var sharedInstance = VersionTracking()
    
    // MARK: Private
    
    fileprivate var versions: [String: [String]]
    fileprivate var firstLaunchEver: Bool = false
    fileprivate var firstLaunchForVersion: Bool = false
    fileprivate var firstLaunchForBuild: Bool = false
    
    fileprivate init() {
        if let versionHistory = UserDefaults.standard.dictionary(forKey: kUserDefaultsVersionHistory) as? [String: [String]] {
            versions = versionHistory
        } else {
            versions = [kVersionsKey: [String](), kBuildsKey: [String]()]
            firstLaunchEver = true
        }
    }
    
    // MARK: - Tracker
    
    public static func track() {
        sharedInstance.startTracking()
    }
    
    public static func isFirstLaunchEver() -> Bool {
        return sharedInstance.firstLaunchEver
    }
    
    public static func isFirstLaunchForVersion(_ version: String = "", firstLaunch: FirstLaunch? = nil) -> Bool {
        var isFirstVersion = sharedInstance.firstLaunchForVersion
        if version != "" {
            isFirstVersion = sharedInstance.historyContainsVersion(version)
        }
        
        if let closure = firstLaunch , isFirstVersion == true{
            closure()
        }
        return isFirstVersion
    }
    
    public static func isFirstLaunchForBuild(_ build: String = "", firstLaunch: FirstLaunch? = nil) -> Bool {
        var isFirstBuild = sharedInstance.firstLaunchForBuild
        if build != "" {
            isFirstBuild = sharedInstance.historyContainsBuild(build)
        }
        
        if let closure = firstLaunch , isFirstBuild == true {
            closure()
        }
        return isFirstBuild
    }
    
    // MARK: - Version
    
    public static func currentVersion() -> String {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        if let version = currentVersion as? String {
            return version
        }
        return ""
    }
    
    public static func previousVersion() -> String? {
        return sharedInstance.previousVersion()
    }
    
    public static func versionHistory() -> [String] {
        guard let versionHistory = sharedInstance.versions[kVersionsKey] else {
            return []
        }
        return versionHistory
    }
    
    // MARK: - Build
    
    public static func currentBuild() -> String {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
        if let version = currentVersion as? String {
            return version
        }
        return ""
    }
    
    public static func previousBuild() -> String? {
        return sharedInstance.previousBuild()
    }
    
    public static func buildHistory() -> [String] {
        guard let buildHistory = sharedInstance.versions[kBuildsKey] else {
            return []
        }
        return buildHistory
    }
    
}

private extension VersionTracking {
    
    // MARK: - Initializer
    
    mutating func startTracking() {
        updateFirstLaunchForVersion()
        updateFirstLaunchForBuild()
        if firstLaunchForVersion || firstLaunchForBuild {
            UserDefaults.standard.set(versions, forKey: kUserDefaultsVersionHistory)
            UserDefaults.standard.synchronize()
        }
    }
    
    mutating func updateFirstLaunchForVersion() {
        let currentVersion = VersionTracking.currentVersion()
        if versions[kVersionsKey]?.contains(currentVersion) == false {
            versions[kVersionsKey]?.append(currentVersion)
            firstLaunchForVersion = true
        }
    }
    
    mutating func updateFirstLaunchForBuild() {
        let currentBuild = VersionTracking.currentBuild()
        if versions[kBuildsKey]?.contains(currentBuild) == false {
            versions[kBuildsKey]?.append(currentBuild)
            firstLaunchForBuild = true
        }
    }
    
    // MARK: - Helper
    
    func historyContainsVersion(_ version: String) -> Bool {
        guard let versionsHistory = versions[kVersionsKey] else {
            return false
        }
        return versionsHistory.contains(version)
    }
    
    func historyContainsBuild(_ build: String) -> Bool {
        guard let buildHistory = versions[kBuildsKey] else {
            return false
        }
        return buildHistory.contains(build)
    }
    
    func previousBuild() -> String? {
        guard let versionsHistory = versions[kVersionsKey] , versionsHistory.count >= 2 else {
            return nil
        }
        return versionsHistory[versionsHistory.count - 2]
    }
    
    func previousVersion() -> String? {
        guard let buildsHistory = versions[kBuildsKey] , buildsHistory.count >= 2 else {
            return nil
        }
        return buildsHistory[buildsHistory.count - 2]
    }
    
}
