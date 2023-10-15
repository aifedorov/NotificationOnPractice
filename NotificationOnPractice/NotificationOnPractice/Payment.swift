//
//  Payment.swift
//  NotificationOnPractice
//
//  Created by Aleksandr Fedorov on 15.10.23.
//

import Foundation

struct Payment: Identifiable {
    let id = UUID()
    let name: String
}

extension Payment {
    static func makeSampleData(number: Int) -> [Payment] {
        var result: [Payment] = []
        for _ in 0..<number {
            result.append(Payment(name: "Payment N\(Int.random(in: 1...100))"))
        }
        return result
    }
}
