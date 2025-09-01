//
//  Decorator.swift
//  DesignPatterns
//
//  Created by Alex.personal on 1/9/25.
//

import Foundation
import Playgrounds

protocol Notifier: Sendable {
    func send(_ message: String)
}

// Decorador base
protocol BaseNotifier: Notifier {
    var wrappee: Notifier { get }
}

// Decoradores concretos
struct SMSDecorator: BaseNotifier {
    let wrappee: Notifier
    func send(_ message: String) {
        print("📱 Sending SMS: \(message)")
        wrappee.send(message)
    }
}

struct EmailDecorator: BaseNotifier {
    let wrappee: Notifier
    func send(_ message: String) {
        print("📧 Sending Email: \(message)")
        wrappee.send(message)
    }
}

struct SlackDecorator: BaseNotifier {
    let wrappee: Notifier
    func send(_ message: String) {
        print("💬 Sending Slack: \(message)")
        wrappee.send(message)
    }
}

// Componente concreto
struct BasicNotifier: Notifier {
    func send(_ message: String) {
        print("➡️ Base notification: \(message)")
    }
}




#Playground {
    // Uso
    let notifier: Notifier = SlackDecorator(
        wrappee: EmailDecorator(
            wrappee: SMSDecorator(
                wrappee: BasicNotifier()
            )
        )
    )
    notifier.send("Hello, this is a test!")
}


