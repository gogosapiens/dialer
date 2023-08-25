
import UIKit

public protocol CallVCDatasource: UIViewController {
    var durationTimer: Timer? {get set}
    var contact: Contact? {get set}
    func updateUI()
    
    func configure(callModel: CallModel)
}
