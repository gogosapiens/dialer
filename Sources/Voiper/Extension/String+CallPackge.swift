

import UIKit


extension String {
    var reuseId: String {
        return self
    }
    
    var nib: UINib {
        return UINib(nibName: self, bundle: nil)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func replacePlaceholders(with values: String...) -> String {
        return String(format: self, arguments: values)
    }
    
    var phoneNumberClean: String {
        return self.replacingOccurrences(of: "[^+0-9]", with: "", options: .regularExpression)
    }
    
    
    // Returns true if the String starts with a substring matching to the prefix-parameter.
    // If isCaseSensitive-parameter is true, the function returns false,
    // if you search "sA" from "San Antonio", but if the isCaseSensitive-parameter is false,
    // the function returns true, if you search "sA" from "San Antonio"
    
    func hasPrefixCheck(prefix: String, isCaseSensitive: Bool) -> Bool {
        
        if isCaseSensitive == true {
            return self.hasPrefix(prefix)
        } else {
            var thePrefix: String = prefix, theString: String = self
            
            while thePrefix.count != 0 {
                if theString.count == 0 { return false }
                if theString.lowercased().first != thePrefix.lowercased().first { return false }
                theString = String(theString.dropFirst())
                thePrefix = String(thePrefix.dropFirst())
            }; return true
        }
    }
    // Returns true if the String ends with a substring matching to the prefix-parameter.
    // If isCaseSensitive-parameter is true, the function returns false,
    // if you search "Nio" from "San Antonio", but if the isCaseSensitive-parameter is false,
    // the function returns true, if you search "Nio" from "San Antonio"
    func hasSuffixCheck(suffix: String, isCaseSensitive: Bool) -> Bool {
        
        if isCaseSensitive == true {
            return self.hasSuffix(suffix)
        } else {
            var theSuffix: String = suffix, theString: String = self
            
            while theSuffix.count != 0 {
                if theString.count == 0 { return false }
                if theString.lowercased().last != theSuffix.lowercased().last { return false }
                theString = String(theString.dropLast())
                theSuffix = String(theSuffix.dropLast())
            }; return true
        }
    }
    // Returns true if the String contains a substring matching to the prefix-parameter.
    // If isCaseSensitive-parameter is true, the function returns false,
    // if you search "aN" from "San Antonio", but if the isCaseSensitive-parameter is false,
    // the function returns true, if you search "aN" from "San Antonio"
    func containsSubString(theSubString: String, isCaseSensitive: Bool) -> Bool {
        
        if isCaseSensitive == true {
            return self.range(of: theSubString) != nil
        } else {
            return self.range(of: theSubString, options: .caseInsensitive) != nil
        }
    }
}
