//
//  DashboardView.swift
//  Savings
//
//  Created by Baptiste Fortier on 25/01/2024.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query var moneyFlows: [MoneyFlow]
    @Environment(\.modelContext) var modelContext
    
    @State var expenseAmount: Double = 0.0
    @State var savingsAmount: Double = 0.0

    @State var showSheet: Bool = false
    
    let cornerRadius: Double = 25.0

    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    MoneyCircleCard(amount: $savingsAmount, total: $savingsAmount, isExpense: false)
                    MoneyCircleCard(amount: $expenseAmount, total: $savingsAmount, isExpense: true)
                }
                .padding(.horizontal)
                VStack {
                    ForEach(moneyFlows) { flow in
                        if !flow.isExpense {
                            MoneyFlowRow(flow: flow)
                            if flow != moneyFlows.last(where: { $0.isExpense == false}) {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(Material.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
                .padding(.horizontal)
                VStack {
                    ForEach(moneyFlows) { flow in
                        if flow.isExpense {
                            MoneyFlowRow(flow: flow)
                            if flow != moneyFlows.last(where: { $0.isExpense == true}) {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(Material.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
                .padding(.horizontal)
            }
            .navigationTitle("Savings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSheet) {
                NewMoneyFlow()
                    .presentationDetents([.medium])
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    calculate()
                }
            }
        }
        .onChange(of: moneyFlows) {
            withAnimation {
                calculate()
            }
        }
    }
    
    func addSamples() {
        withAnimation {
            let sample = MoneyFlow(name: "Test", date: Date(), amount: Double.random(in: 1.0...100.0), isExpense: Bool.random(),categoryIntValue: Int.random(in: 0...5), isRecurrent: Bool.random())
            modelContext.insert(sample)
            calculate()
        }
    }
    
    func calculate() {
        expenseAmount = 0
        savingsAmount = 0
        for flow in moneyFlows {
            if flow.isExpense {
                expenseAmount += flow.amount
            } else {
                savingsAmount += flow.amount
            }
        }
    }
}

#Preview {
    DashboardView()
}

struct MoneyFlowRow: View {
    @Environment(\.modelContext) var modelContext
    @State var flow: MoneyFlow
    
    let iconSize: Double = 20.0
    let cornerRadius: Double = 25.0
    
    var body: some View {
        HStack {
            flow.category.icon
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize, alignment: .center)
                .padding(10)
                .background(flow.category.color, in: Circle())
            VStack {
                Text(flow.date.formatted())
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(flow.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
            Text(String(format: "%.2f", flow.amount) + " €")
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .contextMenu {
            Button(role: .destructive) {
                withAnimation {
                    modelContext.delete(flow)
                }
            } label: {
                Label("delete", systemImage: "trash")
            }
        }
//        .padding()
//        .background(Material.regular, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    MoneyFlowRow(flow: MoneyFlow())
}

struct MoneyCircleCard: View {
    @Binding var amount: Double
    @Binding var total: Double
    
    @State var isExpense: Bool
    @State var trimed: Double = 0.0
    
    let cornerRadius: Double = 25.0
    
    var body: some View {
        ZStack {
            VStack {
                Text(amount == 0.0 ? "--" : String(format: "%.2f€", amount))
                    .padding(.horizontal)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(isExpense == false ? "earning" : "expense")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top)
            Circle()
                .stroke(
                    Material.regular,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
            Circle()
                .trim(from: 0, to: trimed)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(180))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
        .background(isExpense ? Material.ultraThick : Material.ultraThin, in: RoundedRectangle(cornerRadius: cornerRadius))
        .onChange(of: amount) {
            withAnimation {
                calculeTrim()
            }
        }
        .onChange(of: total) {
            withAnimation {
                calculeTrim()
            }
        }
    }
    
    func calculeTrim() {
        print("amount: \(amount)")
        print("total: \(total)")
        print("trim: \(amount * 100 / total)")
        trimed = (amount * 100 / total) / 100
    }
}

#Preview {
    MoneyCircleCard(amount: .constant(0.0), total: .constant(1.0), isExpense: true)
}

struct NewMoneyFlow: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @State var date: Date = Date()
    @State var amount: Double = 0.0
    @State var isExpense: Bool = false
    @State var moneyFlowCategory: MoneyFlowCategory = .dailyLife
    @State var isRecurrent: Bool = false
    
    var isEverythingSet: Bool {
        if !name.isEmpty, amount != 0.0 {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("name", text: $name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("amount", value: $amount, formatter: NumberFormatter())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Section {
                    Menu {
                        Button {
                            isExpense = true
                        } label: {
                            HStack {
                                Text("expense")
                                Spacer()
                                if isExpense == true {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        Button {
                            isExpense = false
                        } label: {
                            HStack {
                                Text("earning")
                                Spacer()
                                if isExpense == false {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("flowType")
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Text(isExpense ? "expense" : "earning")
                        }
                    }
                    Menu {
                        ForEach(MoneyFlowCategory.allCases, id: \.self) { category in
                            Button {
                                moneyFlowCategory = category
                            } label: {
                                HStack {
                                    Text(category.displayName)
                                    Spacer()
                                    if moneyFlowCategory == category {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("flowCategory")
                                .foregroundStyle(Color.primary)
                            Spacer()
                            Text(moneyFlowCategory.displayName)
                        }
                    }
                }
                Section {
                    Toggle("isRecurrent", isOn: $isRecurrent)
                }
            }
            .navigationTitle("newMoneyFlow")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                        modelContext.insert(MoneyFlow(name: name, date: date, amount: amount, isExpense: isExpense, categoryIntValue: moneyFlowCategory.rawValue, isRecurrent: isRecurrent))
                    } label: {
                        Text("save")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(!isEverythingSet)
                }
            }
        }
    }
}

#Preview {
    NewMoneyFlow()
}
