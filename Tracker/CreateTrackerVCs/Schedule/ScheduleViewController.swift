//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//

import UIKit

protocol ScheduleViewController: AnyObject {
    func didSelectDays(_ days: Set<WeekDay>)
}

final class DayPickerController: UIViewController {
    weak var delegate: ScheduleViewController?
    var selectedDays: Set<WeekDay> = []

    private lazy var dayTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.layer.cornerRadius = 12
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.cellID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ScheduleViewController: viewDidLoad called")
        view.backgroundColor = UIColor(named: "CustomWhite")
        navigationItem.title = "Расписание"
        setupInterface()
    }

    private func setupInterface() {
        view.addSubview(dayTable)
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            dayTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dayTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dayTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dayTable.heightAnchor.constraint(equalToConstant: 420),

            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc private func confirmTapped() {
        delegate?.didSelectDays(selectedDays)
        dismiss(animated: true)
    }
}

extension DayPickerController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.cellID, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        let day = WeekDay.allCases[indexPath.row]
        let isLast = indexPath.row == WeekDay.allCases.count - 1
        cell.configure(day: day.rawValue, isSelected: selectedDays.contains(day), isLast: isLast)
        cell.daySwitch.tag = indexPath.row
        cell.daySwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    @objc private func switchToggled(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}
