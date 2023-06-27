import UIKit

extension UINavigationController {
    public static func customNavigaiton(with rootViewController: UIViewController) -> UINavigationController {
        let controller = NavVC(rootViewController: rootViewController)
        controller.navigationBar.prefersLargeTitles = true
        controller.navigationBar.isTranslucent = true
        controller.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "ic_chat_back_button")
        controller.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "ic_chat_back_button")
        controller.navigationBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        controller.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        controller.navigationBar.layer.shadowRadius = 1.0
        controller.navigationBar.layer.shadowOpacity = 0
        controller.navigationBar.layer.masksToBounds = false
        return controller
    }
}
