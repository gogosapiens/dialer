//
//  TheProduct.swift
//  
//
//  Created by Andrei (Work) on 26/07/2023.
//

import Foundation
import StoreKit

public struct TheProduct: Hashable {
    public let skProduct: SKProduct
    public let type: ProductType
        
    public var localizedPrice: String {
        return priceFormatter(locale: skProduct.priceLocale).string(from: skProduct.price) ?? ""
    }
    
    private func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }

    public var currency: String {
        return skProduct.priceLocale.currencySymbol ?? skProduct.priceLocale.currencyCode ?? ""
    }
    
    public var term: String {
        guard let period = skProduct.subscriptionPeriod else { return "unknown" }
        switch period.unit {
        case .day:
            return period.numberOfUnits == 1 ? .day : "\(period.numberOfUnits) \(String.days)"
        case .week:
            return period.numberOfUnits == 1 ? .week : "\(period.numberOfUnits) \(String.weeks)"
        case .month:
            return period.numberOfUnits == 1 ? .month : "\(period.numberOfUnits) \(String.months)"
        case .year:
            return period.numberOfUnits == 1 ? .year : "\(period.numberOfUnits) \(String.years)"
        @unknown default:
            return "unknown".localized
        }
    }

    public init(with skProduct: SKProduct) {
        self.skProduct = skProduct
        self.type = ProductType(from: skProduct.productIdentifier)
    }
}

extension TheProduct {
    public enum ProductType: Int, CaseIterable {
        case oneNumberWeekly
        case oneNumberWeeklyTrial
        
        case oneNumberMonthly
        case oneNumberMonthlyTrial
        
        case oneNumberThreeMonths
        
        case oneNumberSixMonthsTrial
        
        case oneNumberYearly
        
        case secondNumberWeekly
        
        case coinPack100
        case coinPack200
        case coinPack500
        case coinPack1000
        
        case unknown
        
        private static var bundleId: String {
            if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path), let bundle = dict["CFBundleIdentifier"] as? String {
                return bundle
            } else {
                return ""
            }
        }
        
        init(from id: String) {
            switch id {
            case "\(ProductType.bundleId).weekly":
                self = .oneNumberWeekly
            case "\(ProductType.bundleId).weekly_trial":
                self = .oneNumberWeeklyTrial
            case "\(ProductType.bundleId).monthly":
                self = .oneNumberMonthly
            case "\(ProductType.bundleId).monthly_trial":
                self = .oneNumberMonthlyTrial
            case "\(ProductType.bundleId).3months":
                self = .oneNumberThreeMonths
            case "\(ProductType.bundleId).6months_trial":
                self = .oneNumberSixMonthsTrial
            case "\(ProductType.bundleId).yearly":
                self = .oneNumberYearly
            case "\(ProductType.bundleId).weekly_extra_4.99":
                self = .secondNumberWeekly
            case "\(ProductType.bundleId).creditspack100":
                self = .coinPack100
            case "\(ProductType.bundleId).creditspack200":
                self = .coinPack200
            case "\(ProductType.bundleId).creditspack500":
                self = .coinPack500
            case "\(ProductType.bundleId).creditspack1000":
                self = .coinPack1000
            default:
                self = .unknown
            }
        }
        
        var id: String? {
            
            switch self {
            case .oneNumberWeekly:
                return "\(ProductType.bundleId).weekly"
            case .oneNumberWeeklyTrial:
                return "\(ProductType.bundleId).weekly_trial"
                
            case .oneNumberMonthly:
                return "\(ProductType.bundleId).monthly"
            case .oneNumberMonthlyTrial:
                return "\(ProductType.bundleId).monthly_trial"
            case .oneNumberThreeMonths:
                return "\(ProductType.bundleId).3months"
            case .oneNumberSixMonthsTrial:
                return "\(ProductType.bundleId).6months_trial"
            case .oneNumberYearly:
                return "\(ProductType.bundleId).yearly"
    
            case .secondNumberWeekly:
                return "\(ProductType.bundleId).weekly_extra_4.99"
      
            case .coinPack100:
                return "\(ProductType.bundleId).creditspack100"
            case .coinPack200:
                return "\(ProductType.bundleId).creditspack200"
            case .coinPack500:
                return "\(ProductType.bundleId).creditspack500"
            case .coinPack1000:
                return "\(ProductType.bundleId).creditspack1200"

            default:
                return nil
            }
        }
        
        var isSubscription: Bool {
            switch self {
            case .coinPack100, .coinPack200, .coinPack500, .coinPack1000:
                return false
            default:
                return true
            }
        }
        
        var isFirstNumber: Bool {
            switch self {
            case .oneNumberWeekly, .oneNumberWeeklyTrial,
                 .oneNumberMonthly, .oneNumberMonthlyTrial,
                 .oneNumberThreeMonths,
                 .oneNumberSixMonthsTrial,
                 .oneNumberYearly:
                
                return true
            default:
                return false
            }
        }
        
        var isSecondNumber: Bool {
            switch self {
            case .secondNumberWeekly:
                return true
            default:
                return false
            }
        }
        
        var group: Int {
            switch self {
            case .oneNumberWeekly, .oneNumberWeeklyTrial,
                 .oneNumberMonthly, .oneNumberMonthlyTrial,
                 .oneNumberThreeMonths,
                 .oneNumberSixMonthsTrial,
                 .oneNumberYearly:
                
                return 1
            case .secondNumberWeekly:
                return 2
            case .coinPack100, .coinPack200, .coinPack500, .coinPack1000:
                return 3
            case .unknown:
                return -1
            }
        }
    }
}

extension TheProduct: Comparable {
    public static func < (lhs: TheProduct, rhs: TheProduct) -> Bool {
        lhs.type.rawValue < rhs.type.rawValue
    }
}

fileprivate extension Double {
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
    }
}

fileprivate extension String {
    static var day: String { "day".localized }
    static var days: String { "days".localized }
    static var week: String { "week".localized }
    static var weeks: String { "weeks".localized }
    static var month: String { "month".localized }
    static var months: String { "months".localized }
    static var year: String { "year".localized }
    static var years: String { "years".localized }
}
