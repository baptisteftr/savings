//
//  DataModel.swift
//  Savings
//
//  Created by Baptiste Fortier on 24/01/2024.
//

import Foundation
import SwiftUI
import SwiftData

enum MoneyFlowType {
    case expense
    case saving
}

enum MoneyFlowCategory: Int, CaseIterable {
    case food = 0
    case dailyLife = 1
    case house = 2
    case bank = 3
    case vacation = 4
    case hobby = 5
    
    var displayName: String {
        switch self {
        case .food:
            return NSLocalizedString("food", comment: "")
        case .dailyLife:
            return NSLocalizedString("dailyLife", comment: "")
        case .house:
            return NSLocalizedString("house", comment: "")
        case .bank:
            return NSLocalizedString("bank", comment: "")
        case .vacation:
            return NSLocalizedString("vacation", comment: "")
        case .hobby:
            return NSLocalizedString("hobby", comment: "")
        }
    }
    
    var icon: Image {
        switch self {
        case .food:
            return Image(systemName: "fork.knife")
        case .dailyLife:
            return Image(systemName: "fork.knife")
        case .house:
            return Image(systemName: "house")
        case .bank:
            return Image(systemName: "dollarsign")
        case .vacation:
            return Image(systemName: "beach.umbrella")
        case .hobby:
            return Image(systemName: "figure.dance")
        }
    }
    
    var color: Color {
        switch self {
        case .food:
            return Color.orange
        case .dailyLife:
            return Color.purple
        case .house:
            return Color.blue
        case .bank:
            return Color.green
        case .vacation:
            return Color.blue
        case .hobby:
            return Color.pink
        }
    }
}

@Model
class MoneyFlow {
    var name: String
    var date: Date
    var amount: Double
    var isExpense: Bool
    var categoryIntValue: Int
    var isRecurrent: Bool
    
    init(name: String = "", date: Date = Date(), amount: Double = 0.0, isExpense: Bool = true, categoryIntValue: Int = 0, isRecurrent: Bool = true) {
        self.name = name
        self.date = date
        self.amount = amount
        self.isExpense = isExpense
        self.categoryIntValue = categoryIntValue
        self.isRecurrent = isRecurrent
    }
}

extension MoneyFlow {
    var category: MoneyFlowCategory {
        return MoneyFlowCategory(rawValue: self.categoryIntValue) ?? .food
    }
}
