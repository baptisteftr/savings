//
//  SavingsApp.swift
//  Savings
//
//  Created by Baptiste Fortier on 24/01/2024.
//

import SwiftUI
import SwiftData

@main
struct SavingsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: MoneyFlow.self)
    }
}
