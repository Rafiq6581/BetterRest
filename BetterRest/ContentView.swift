//
//  ContentView.swift
//  BetterRest
//
//  Created by Rafiq Rifhan Rosman on 2024/07/21.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    let coffeeAmounts = Array(1...20)
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    var body: some View {
        
            NavigationStack {
                
                Form {
                    VStack(alignment: .leading , spacing: 5) {
                        Text("What time do you want to wake up?")
                            .font(.headline)
                        
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        //                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    VStack(alignment: .leading , spacing: 5) {
                        Text("Desired amount of sleep:")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    VStack(alignment: .leading , spacing: 0) {
                        Text("Daily coffee intake:")
                            .font(.headline)
                        Text("^[\(coffeeAmount) cup](inflect: true)")
                            .foregroundStyle(.blue)
                        Picker("", selection: $coffeeAmount) {
                            ForEach(coffeeAmounts, id:\.self) { amount in
                                Text("^[\(amount) cup](inflect: true)")
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        //                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                    }
                    
                    Section("Your ideal bedtime is...") {
                        VStack {
//                            Text("Your ideal bedtime is...")
                            Text(calculateBedTime())
                                .font(.largeTitle.bold())
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .center)
                        }
                    }
                }
                .navigationTitle("🌙 BetterRest")
//                .toolbar {
//                    Button("Calculate", action: calculateBedTime)
//                }
//                .alert(alertTitle, isPresented: $showingAlert) {
//                    Button("OK") {}
//                } message: {
//                    Text(alertMessage)
//                }
                
            }
            
    }
    
    
    func calculateBedTime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(sleepAmount), coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
//            alertTitle = "Your ideal bedtime is..."
//            alertMessage = " \(sleepTime.formatted(date: .omitted, time: .shortened))"
            
            return "\(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            // something went wrong!
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
//        showingAlert = true
       return "Calculating..."
    }
}



#Preview {
    ContentView()
}
