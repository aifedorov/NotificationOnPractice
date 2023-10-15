//
//  ViewController.swift
//  NotificationOnPractice
//
//  Created by Aleksandr Fedorov on 15.10.23.
//

import UIKit

struct Payment: Identifiable {
    let id = UUID()
    let name: String
}

extension Payment {
    static func makeSampleData(number: Int) -> [Payment] {
        var result: [Payment] = []
        for _ in 0..<number {
            result.append(Payment(name: "Payment N\(Int.random(in: 1...100))"))
        }
        return result
    }
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Payments"
        navigationController?.navigationBar.prefersLargeTitles = true
                
        setupDataSource()
        setupTableView()
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        updateSnapshot()
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
        paymentReceiptViewController.title = payments[indexPath.row].name
        
        cell.setSelected(false, animated: true)
        navigationController?.pushViewController(paymentReceiptViewController, animated: true)
    }
}
