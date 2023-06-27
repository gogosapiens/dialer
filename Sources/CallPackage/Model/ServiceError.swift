//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 12.06.23.
//

import Foundation

public enum ServiceError: Error {
    case notAuthorized
    case purchaseError(String)
    case undecodable
    case networkError(API, Int, String)
    case networkError_2(String, Int, String)
    case undefined
    case other(Error)
    case restoreUnavailable
    case phoneWithdraw
    case accountPaused
    case phoneRestoring(String)
    case innactiveNumber
}
