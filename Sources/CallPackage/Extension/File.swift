
import Foundation

extension Double {
    func delay(_ handler: @escaping () -> ()) {
        let time = DispatchTime.now() + Double(Int64(self * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: handler)
    }
}

