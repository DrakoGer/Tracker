//
//  EventSetupController.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//


import UIKit

final class EventSetupController: UIViewController {
    weak var delegate: EntryCreationDelegate?
    
    private var group: TrackerGroup = TrackerGroup(name: "Домашнее задание", entries: [])
    private var category: TrackerGroup = TrackerGroup(
        name: "Домашнее задание", entries: [])
    
    private lazy var eventNameField: UITextField = {
        let field = UITextField()
        field.backgroundColor = UIColor(named: "CustomBackgroundDay")
        field.placeholder = "Введите название трекера"
        field.layer.cornerRadius = 16
        field.clearButtonMode = .whileEditing
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.addTarget(self, action: #selector(nameFieldChanged), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let options = ["Категория"]
    
    private lazy var optionsTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.layer.cornerRadius = 16
        table.clipsToBounds = true
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(UIColor(named: "CancelButtonRed"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "CancelButtonRed")?.cgColor
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "CustomWhite"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "CustomGray")
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var actionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "CustomWhite")
        navigationItem.title = "Новое событие"
        setupInterface()
    }
    
    private func setupInterface() {
        view.addSubview(eventNameField)
        view.addSubview(optionsTable)
        view.addSubview(actionStack)
        
        saveButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            eventNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            eventNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            eventNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            eventNameField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTable.topAnchor.constraint(equalTo: eventNameField.bottomAnchor, constant: 24),
            optionsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTable.heightAnchor.constraint(equalToConstant: 150),
            
            actionStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            actionStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func nameFieldChanged() {
        updateSaveButtonState()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = eventNameField.text, !name.isEmpty, !group.name.isEmpty else {
            return
        }
        delegate?.didCreateNewEvent(
            name: name, group: group, icon: "❤️", color: UIColor(named: "CustomGreen")!)
        presentingViewController?.presentingViewController?.dismiss(
            animated: true)
    }
    
    private func updateSaveButtonState() {
        let isNameValid = !(eventNameField.text?.isEmpty ?? true)
        saveButton.isEnabled = isNameValid
        saveButton.backgroundColor = saveButton.isEnabled ? UIColor(named: "CustomBlack") : UIColor(named: "CustomGray")
    }
}

extension EventSetupController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = options[indexPath.row]
        cell.detailTextLabel?.text = group.name
        cell.detailTextLabel?.textColor = UIColor(named: "CustomGray")
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "CustomBlack")
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = UIColor(named: "CustomBackgroundDay")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 16
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == options.count - 1
        
        if isFirstCell {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.layer.cornerRadius = cornerRadius
        }
        if isLastCell {
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = cornerRadius
        }
        cell.layer.masksToBounds = true
    }
}
