//
//  ViewController.swift
//  NotificationOnPractice
//
//  Created by Aleksandr Fedorov on 15.10.23.
//

import UIKit
import Combine

final class PaymentsListViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, UUID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UUID>
    
    private var dataSource: DataSource!
    private var payments: [Payment] = Payment.makeSampleData(number: 20)
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        return tableView
    }()
        
    #if useCombineV1
    private var cancellableSet: Set<AnyCancellable> = []
    @Published private var savedPayment: Payment?
    #elseif useCombineV2
    private var cancellableSet: Set<AnyCancellable> = []
    private var savedPayment: Payment?
    #else
    private var notificationObserver: Any?
    private var savedPayment: Payment?
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupDataSource()
        setupTableView()
        updateSnapshot()
        
        #if useCombineV1
        // Combine version with @Published
        NotificationCenter.default.publisher(for: .paymentSaved, object: nil)
            .compactMap { (notification) -> Payment?  in
                return notification.object as? Payment
            }
            .assign(to: \.savedPayment, on: self)
            .store(in: &cancellableSet)
        
        #elseif useCombineV2
        // Combine version without @Published
        NotificationCenter.default.publisher(for: .paymentSaved, object: nil)
            .compactMap { (notification) -> Payment?  in
                return notification.object as? Payment
            }
            .sink { [weak self] payment in
                guard let self else { return }
                self.savedPayment = payment
            }
            .store(in: &cancellableSet)
        #else
        notificationObserver = NotificationCenter.default.addObserver(self, selector: #selector(paymentSaved(_:)), name: .paymentSaved, object: nil)
        #endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let savedPayment {
            presentAlert(withTitle: "Payment is saved", message: "Payment \(savedPayment.name) is saved") { [unowned self] in
                self.savedPayment = nil
            }
        }
    }
    
    deinit {
        #if useCombineV1 || useCombineV2
        cancellableSet.forEach { $0.cancel() }
        #else
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        #endif
    }
    
    @objc private func paymentSaved(_ notification: Notification) {
        guard let savedPayment = notification.object as? Payment else { return }
        self.savedPayment = savedPayment
    }
    
    private func setupView() {
        title = "Payments"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.dataSource = dataSource
    }
    
    private func setupDataSource() {
        dataSource = DataSource(tableView: tableView) { [unowned self]
            (tableView: UITableView, indexPath: IndexPath, itemIdentifier: UUID) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            let payment = self.payments[indexPath.row]
            cell.textLabel?.text = payment.name
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    private func updateSnapshot() {
        var snapshot = Snapshot()

        snapshot.appendSections([.main])
        snapshot.appendItems(payments.map { $0.id })

        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension PaymentsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let paymentReceiptViewController = PaymentReceiptViewController()
        let payment = payments[indexPath.row]
        
        paymentReceiptViewController.title = payment.name
        paymentReceiptViewController.payment = payment
        
        cell.setSelected(false, animated: true)
        navigationController?.pushViewController(paymentReceiptViewController, animated: true)
    }
}
