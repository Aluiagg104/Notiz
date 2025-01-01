//
//  Notizen_AppApp.swift
//  Notizen App
//
//  Created by Oliver Henkel on 28.09.24.
//

import SwiftUI

@main
struct Notizen_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    loadData()
                }
        }
    }
    
    private func loadData() {
        
    }
}
