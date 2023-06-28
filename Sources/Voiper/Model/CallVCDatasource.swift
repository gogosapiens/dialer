
import Foundation

public protocol CallVCDatasource {
    var durationTimer: Timer? {get set}
    var contact: Contact? {get set}
    func updateUI()
}
