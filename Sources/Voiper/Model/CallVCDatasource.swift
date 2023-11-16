
import UIKit

public protocol EndCallVCDatasource: UIViewController {
    var endAction: (() -> Void)? { get set }
    
    func callWasStarted()
    func callWasEnded(callModel: CallModel)
}


public protocol CallVCDatasource: UIViewController {
    var durationTimer: Timer? { get set }
    var contact: Contact? { get set }
    func updateUI()
    
    func configure(callModel: CallModel)
}
