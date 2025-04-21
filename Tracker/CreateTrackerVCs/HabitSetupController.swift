//
//  HabitSetupController.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//


import UIKit

final class HabitSetupController: UIViewController {
    
    private var group: TrackerGroup = TrackerGroup(name: "Ежедневные цели", entries: [])
    private var activeDays: Set<WeekDay> = []
    private var category: TrackerGroup = TrackerGroup(name: "Уборка", entries: [])
    weak var delegate: EntryCreationDelegate?
    
    private lazy var nameField: UITextField = {
        let field = UITextField()
        field.backgroundColor = UIColor(named: "CustomBackgroundDay")
        field.placeholder = "Введите название привычки"
        field.layer.cornerRadius = 16
        field.clearButtonMode = .whileEditing
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.addTarget(self, action: #selector(nameFieldChanged), for: .editingChanged)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let options = ["Категория", "Расписание"]
    
    private lazy var optionsTable: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.layer.cornerRadius = 16
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
        navigationItem.title = "Новая привычка"
        setupInterface()
    }
    
    private func setupInterface() {
        view.addSubview(nameField)
        view.addSubview(optionsTable)
        view.addSubview(actionStack)
        
        saveButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTable.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
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
        guard let name = nameField.text, !name.isEmpty, !activeDays.isEmpty else { return }
        delegate?.didCreateNewHabit(name: name, group: group, icon: "🌟", color: UIColor(named: "CustomGreen")!, days: activeDays)
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
    
    private func updateSaveButtonState() {
        let isNameValid = !(nameField.text?.isEmpty ?? true)
        let isDaysSelected = !activeDays.isEmpty
        saveButton.isEnabled = isNameValid && isDaysSelected
        saveButton.backgroundColor = saveButton.isEnabled ? UIColor(named: "CustomBlack") : UIColor(named: "CustomGray")
    }
}

extension HabitSetupController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = options[indexPath.row]
        cell.detailTextLabel?.text = indexPath.row == 0 ? group.name : formatDaysText(days: activeDays)
        cell.detailTextLabel?.textColor = UIColor(named: "CustomGray")
        cell.textLabel?.font = .systemFont(ofSize: 16)
        cell.textLabel?.textColor = UIColor(named: "CustomBlack")
        cell.detailTextLabel?.font = .systemFont(ofSize: 16)
        cell.backgroundColor = UIColor(named: "CustomBackgroundDay")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let dayPickerVC = DayPickerController()
            dayPickerVC.delegate = self
            dayPickerVC.selectedDays = activeDays
            let navController = UINavigationController(rootViewController: dayPickerVC)
            present(navController, animated: true)
        }
    }
}

extension HabitSetupController: ScheduleViewController {
    func didSelectDays(_ days: Set<WeekDay>) {
        activeDays = days
        if let cell = optionsTable.cellForRow(at: IndexPath(row: 1, section: 0)) {
            cell.detailTextLabel?.text = formatDaysText(days: days)
        }
        updateSaveButtonState()
    }
    
    private func formatDaysText(days: Set<WeekDay>) -> String {
        guard !days.isEmpty else { return "" }
        if days.count == WeekDay.allCases.count {
            return "Каждый день"
        }
        let sortedDays = WeekDay.allCases.filter { days.contains($0) }
        return sortedDays.map { $0.abbreviation }.joined(separator: ", ")
    }
}
