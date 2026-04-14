//
//  deepfocusApp.swift
//  deepfocus
//
//  Created by wangwenfei on 2026/4/14.
//

import SwiftUI

@main
struct deepfocusApp: App {
    @State private var store = FocusStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
