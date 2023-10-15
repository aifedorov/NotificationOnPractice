//
//  PaymentReceiptViewController.swift
//  NotificationOnPractice
//
//  Created by Aleksandr Fedorov on 15.10.23.
//

import UIKit

final class PaymentReceiptViewController: UIViewController {
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(configuration: .borderedProminent())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            saveButton.heightAnchor.constraint(equalToConstant: 64),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
