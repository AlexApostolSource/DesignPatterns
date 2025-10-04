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
import NetworkLayer


struct Money: Decodable {
    var amount: Double
    var currency: String
}

protocol PromoProcessorProtocol {
    func finalPrice(from: Money, currency: String) -> Money
}

enum PriceCalculatorError: Error {
    case noProcessForPromo
}

struct PercentagePromo: PromoProcessorProtocol {
    private let pct: Double
    init(pct: Double) {
        self.pct = pct
    }
    func finalPrice(from: Money, currency: String) -> Money {
        return Money(amount: from.amount * (1 - pct), currency: currency)
    }
}

struct TwoForOne: PromoProcessorProtocol {
    func finalPrice(from: Money, currency: String) -> Money {
        return Money(amount: from.amount / 2.0, currency: currency)
    }
}

struct BlackFriday: PromoProcessorProtocol {
    func finalPrice(from: Money, currency: String) -> Money {
        return Money(amount: from.amount / 2.0, currency: currency)
    }
}

struct FreeShippingIfOverPromo: PromoProcessorProtocol {
    private let threshold: Double

    init(threshold: Double) {
        self.threshold = threshold
    }

    func finalPrice(from: Money, currency: String) -> Money {
        if from.amount >= threshold {
            return Money(amount: from.amount, currency: currency)
        } else {
            return Money(amount: from.amount + 4.99, currency: currency)
        }
    }

}

struct CuponPromo: PromoProcessorProtocol {
    private let code: String
    init(code: String) {
        self.code = code
    }
    func finalPrice(from: Money, currency: String) -> Money {
        if code.uppercased() == "SAVE10" {
            return Money(amount: from.amount - 10, currency: currency)
        } else if code.uppercased() == "VIP5" {
            return Money(amount: from.amount - 5, currency: currency)
        } else {
            return from
        }
    }
}

struct PricingRules {
    let threshold: Double
    let cupon: String
    let percentage: Double
}

final class PriceCalculatorFactoryMethod {
    static func makePriceCalculator(rules: PricingRules) -> PriceCalculator {
        NetworkLayerConfig.config(host: "api.frankfurter.dev")
        let requestProvider: RequestProviderProtocol = RequestProvider.basic
        let remoteDataSource = MoneyConverterRemoteDataSource(requestProvider: requestProvider)
        let localDataSource = MoneyConverterLocalDataSource()
        let repository = MoneyConverterRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource
        )
        let useCase = MoneyConverterUseCase(repository: repository)
        return PriceCalculator(
            moneyConverter: useCase,
            promoProcessor: [
                "blackFriday": BlackFriday(),
                "cupon": CuponPromo(code: rules.cupon),
                "freeShippingIfOver": FreeShippingIfOverPromo(
                    threshold: rules.threshold
                ),
                "twoForOne": TwoForOne(),
                "percentage": PercentagePromo(
                    pct: rules
                        .percentage)
            ]
        )
    }
}


final class PriceCalculator {
    private let moneyConverter: MoneyConverterUseCaseProtocol
    private let promoProcessor: [String: PromoProcessorProtocol]
    init(moneyConverter: MoneyConverterUseCaseProtocol, promoProcessor: [String: PromoProcessorProtocol] ) {
        self.moneyConverter = moneyConverter
        self.promoProcessor = promoProcessor
    }
    
    func finalPrice(base: Money, promo: String, toCurrency: String) async throws -> Money {
        var working = base
        if working.currency != toCurrency {
            working = try await convert(working, to: toCurrency) ?? working
        }
        if let promo = promoProcessor[promo] {
            return promo.finalPrice(from: working, currency: working.currency)
        } else {
            throw PriceCalculatorError.noProcessForPromo
        }
    }

    private func convert(_ money: Money, to: String) async throws -> Money? {
        return try await moneyConverter.convert(money, to: to)
    }
}

protocol MoneyConverterRemoteDataSourceProtocol {
    func convert(_ money: Money, to: String) async throws -> Money?
}

protocol MoneyConverterLocalDataSourceProtocol {
    func convert(_ money: Money, to: String) async throws -> Money?
    func save(from: String?, to: String) async
}

actor MoneyConverterLocalDataSource: MoneyConverterLocalDataSourceProtocol {
    private var cache: [String: String] = [:]
    func convert(_ money: Money, to: String) async throws -> Money? {
        if let currencyCache = cache[money.currency] {
            return Money(amount: money.amount, currency: currencyCache)
        } else {
            return nil
        }
    }

    func save(from: String?, to: String) {
        if let from = from {
            cache[from] = to
        }
    }
}

final class MoneyConverterRemoteDataSource: MoneyConverterRemoteDataSourceProtocol {
    private let requestProvider: RequestProviderProtocol

    init(requestProvider: RequestProviderProtocol) {
        self.requestProvider = requestProvider
    }

    func convert(_ money: Money, to: String) async throws -> Money? {
        let endpoint = MoneySyncEndpoint(currency: money.currency, to: to)
        let money: Money? = try await requestProvider.execute(endpoint: endpoint)
        return money
    }
}

protocol MoneyConverterRepositoryProtocol {
    func convert(_ money: Money, to: String) async throws -> Money?
}

final class MoneyConverterRepository: MoneyConverterRepositoryProtocol {
    private let remoteDataSource: MoneyConverterRemoteDataSourceProtocol
    private let localDataSource: MoneyConverterLocalDataSourceProtocol

    init(remoteDataSource: MoneyConverterRemoteDataSourceProtocol, localDataSource: MoneyConverterLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func convert(_ money: Money, to: String) async throws -> Money? {
        if let currencyCache = try await localDataSource.convert(money, to: to) {
            return currencyCache
        } else {
            let money = try await remoteDataSource.convert(money, to: to)
            await localDataSource.save(from: money?.currency, to: to)
            return money
        }
    }
}

struct MoneySyncEndpoint: NetworkLayerEndpoint {
    private let currency: String
    private let to: String

    init(currency: String, to: String) {
        self.currency = currency
        self.to = to
    }

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "from", value: currency),
            URLQueryItem(name: "to", value: to)
        ]
    }

    var path: String = "/latest"

    var method: URLRequestMethod = .GET
}

protocol MoneyConverterUseCaseProtocol {
    func convert(_ money: Money, to: String) async throws -> Money?
}

struct MoneyConverterUseCase: MoneyConverterUseCaseProtocol {
    private let repository: MoneyConverterRepositoryProtocol

    init(repository: MoneyConverterRepositoryProtocol) {
        self.repository = repository
    }

    func convert(_ money: Money, to: String) async throws -> Money? {
        return try await repository.convert(money, to: to)
    }
}

