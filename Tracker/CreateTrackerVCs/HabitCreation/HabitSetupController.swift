//
//  HabitSetupController.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//

protocol HabitEmojiSelectionDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}

protocol HabitColorSelectionDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

import UIKit

final class HabitSetupController: UIViewController, UITextFieldDelegate {
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    
    private var group: TrackerGroup = TrackerGroup(name: "Ежедневные цели", entries: [])
    private var activeDays: Set<WeekDay> = []
    private var category: TrackerGroup = TrackerGroup(name: "Уборка", entries: [])
    weak var delegate: EntryCreationDelegate?
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓",
        "🥇", "🎸", "🏝️", "😪"
    ]
    private let colors: [UIColor] = [
        UIColor(named: "Selection 1"),
        UIColor(named: "Selection 2"),
        UIColor(named: "Selection 3"),
        UIColor(named: "Selection 4"),
        UIColor(named: "Selection 5"),
        UIColor(named: "Selection 6"),
        UIColor(named: "Selection 7"),
        UIColor(named: "Selection 8"),
        UIColor(named: "Selection 9"),
        UIColor(named: "Selection 10"),
        UIColor(named: "Selection 11"),
        UIColor(named: "Selection 12"),
        UIColor(named: "Selection 13"),
        UIColor(named: "Selection 14"),
        UIColor(named: "Selection 15"),
        UIColor(named: "Selection 16"),
        UIColor(named: "Selection 17"),
        UIColor(named: "Selection 18"),
    ].compactMap { $0 }
    
    private lazy var nameField: UITextField = {
        let field = UITextField()
        field.backgroundColor = UIColor(named: "CustomBackgroundDay")
        field.placeholder = "Введите название привычки"
        field.layer.cornerRadius = 16
        field.clearButtonMode = .whileEditing
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: field.frame.height))
        field.leftViewMode = .always
        field.delegate = self // Устанавливаем делегат
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
    
    private lazy var emojiCollectionView: HabitEmojiCollection = {
        let collectionView = HabitEmojiCollection(emojies: emojis)
        collectionView.selectionDelegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var emojiHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont(name: "YS Display Bold", size: 19)
        label.textColor = UIColor(named: "CustomBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorCollectionView: HabitColorCollection = {
        let collectionView = HabitColorCollection(colors: colors)
        collectionView.selectionDelegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var colorHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(named: "CustomBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        setupKeyboardDismissal() // Добавляем настройку для скрытия клавиатуры
        categoryStore.ensureDefaultCategoryExists("Ежедневные цели")
    }
    
    private func setupInterface() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameField)
        contentView.addSubview(optionsTable)
        contentView.addSubview(emojiHeaderLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorHeaderLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(actionStack)
        
        saveButton.isEnabled = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor), // Привязываем к safeArea
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTable.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            optionsTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsTable.heightAnchor.constraint(equalToConstant: 150),
            
            emojiHeaderLabel.topAnchor.constraint(equalTo: optionsTable.bottomAnchor, constant: 32),
            emojiHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiHeaderLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: -26),
            colorHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorHeaderLabel.bottomAnchor, constant: 15),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            actionStack.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 8),
            actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            actionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            actionStack.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            
            let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
            scrollView?.contentInset = contentInsets
            scrollView?.scrollIndicatorInsets = contentInsets
            
            if let scrollView = scrollView {
                let actionStackFrame = actionStack.convert(actionStack.bounds, to: scrollView)
                scrollView.scrollRectToVisible(actionStackFrame, animated: true)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView
        scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func nameFieldChanged() {
        updateSaveButtonState()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameField.text, !name.isEmpty, !activeDays.isEmpty,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor else { return }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: selectedColor,
            icon: selectedEmoji,
            activeDays: activeDays,
            category: group
        )
        
        do {
            try trackerStore.addTracker(tracker, categoryName: group.name)
            delegate?.didCreateNewHabit(
                name: name,
                group: group,
                icon: selectedEmoji,
                color: selectedColor,
                days: activeDays
            )
            presentingViewController?.presentingViewController?.dismiss(animated: true)
        } catch {
            print("Ошибка при сохранении привычки: \(error)")
        }
    }
    
    private func updateSaveButtonState() {
        let isNameValid = !(nameField.text?.isEmpty ?? true)
        let isDaysSelected = !activeDays.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        saveButton.isEnabled = isNameValid && isDaysSelected && isEmojiSelected && isColorSelected
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

extension HabitSetupController: HabitEmojiSelectionDelegate, HabitColorSelectionDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateSaveButtonState()
    }
    
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateSaveButtonState()
    }
}
