//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 21.06.23.
//

import Foundation


extension DateComponentsFormatter {
    static var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        
        return formatter
    }
    
    static var callDurationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        return formatter
    }
}
