//
//  Kata2_PricingSwitch.swift
//  DesignPatternsShowCase
//
//  Created by Alex.personal on 12/9/25.
//

//
//  Kata2_PricingSwitch.swift
//  Anti-ejemplo para refactorizar (viola OCP, mezcla pricing y red)
//

import Foundation

enum PromoKind {
    case none
    case percentage(Double)
    case twoForOne
    case blackFriday
    case coupon(String)
    case freeShippingIfOver(Double)
}

struct Money {
    var amount: Double
    var currency: String
}

final class PriceCalculatorBad {
    // Conversión de divisa incrustada + switch creciente (mal)
    func finalPrice(base: Money, promo: PromoKind, toCurrency: String) -> Money {
        var working = base
        // Convertimos primero de forma BLOQUEANTE (semaforo) (mal diseño)
        if working.currency != toCurrency {
            working = convertSync(working, to: toCurrency) ?? working
        }
        switch promo {
        case .none:
            return working
        case .percentage(let pct):
            return Money(amount: working.amount * (1 - pct), currency: working.currency)
        case .twoForOne:
            return Money(amount: working.amount / 2.0, currency: working.currency)
        case .blackFriday:
            return Money(amount: max(0, working.amount - 20), currency: working.currency)
        case .coupon(let code):
            if code.uppercased() == "SAVE10" {
                return Money(amount: working.amount - 10, currency: working.currency)
            } else if code.uppercased() == "VIP5" {
                return Money(amount: working.amount - 5, currency: working.currency)
            } else {
                return working
            }
        case .freeShippingIfOver(let threshold):
            if working.amount >= threshold {
                return Money(amount: working.amount, currency: working.currency) // se ignora el envío por simplicidad
            } else {
                return Money(amount: working.amount + 4.99, currency: working.currency)
            }
        }
    }

    // Bloqueante con semáforo, sin inyección (mal)
    private func convertSync(_ money: Money, to: String) -> Money? {
        let url = URL(string: "https://api.frankfurter.dev/latest?from=\(money.currency)&to=\(to)")!
        var result: Money? = nil
        let sem = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { sem.signal() }
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let rates = json["rates"] as? [String: Double],
                let rate = rates[to]
            else { return }
            result = Money(amount: money.amount * rate, currency: to)
        }.resume()
        _ = sem.wait(timeout: .now() + 5)
        return result
    }
}
