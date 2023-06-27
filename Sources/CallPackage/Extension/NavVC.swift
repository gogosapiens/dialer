//
//  File.swift
//  
//
//  Created by Maxim Okolokulak on 26.06.23.
//

import UIKit

public class NavVC: UINavigationController {
    public override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
//        if iphoneX || iphoneXMAX {
            let horizontal = UITraitCollection(horizontalSizeClass: .compact)
            let vertical = UITraitCollection(verticalSizeClass: .regular)
            return UITraitCollection(traitsFrom: [horizontal, vertical])
//        } else {
//            let horizontal = UITraitCollection(horizontalSizeClass: .regular)
//            let vertical = UITraitCollection(verticalSizeClass: .regular)
//            return UITraitCollection(traitsFrom: [horizontal, vertical])
//        }
    }
}
