//
//  UIViewController+Ext.swift
//  NotificationOnPractice
//
//  Created by Aleksandr Fedorov on 15.10.23.
//

import UIKit

extension UIViewController {
    func presentAlert(withTitle title: String, message: String, actionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: { _ in
            actionHandler()
        }))
        present(alert, animated: true)
    }
}
