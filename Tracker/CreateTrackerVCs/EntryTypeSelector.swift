//
//  EntryTypeSelector.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//

import UIKit

final class EntryTypeSelector: UIViewController {
    weak var delegate: EntryCreationDelegate?

    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 16)
        button.setTitleColor(UIColor(resource: .customWhite), for: .normal)
        button.backgroundColor = UIColor(resource: .customBlack)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var eventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = UIFont(name: "YS Display Medium", size: 16)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.backgroundColor = UIColor(named: "CustomBlack")
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(eventButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [habitButton, eventButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "CustomWhite")
        navigationItem.title = "Создание трекера"
        setupInterface()
    }

    private func setupInterface() {
        view.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            eventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func habitButtonTapped() {
        let habitSetupVC = HabitSetupController()
        habitSetupVC.delegate = delegate
        let navController = UINavigationController(rootViewController: habitSetupVC)
        present(navController, animated: true)
    }

    @objc private func eventButtonTapped() {
        let eventSetupVC = EventSetupController()
        eventSetupVC.delegate = delegate
        let navController = UINavigationController(rootViewController: eventSetupVC)
        present(navController, animated: true)
    }
}
