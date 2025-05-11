//
//  EventSetupController.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//

protocol EventEmojiSelectionDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}

protocol EventColorSelectionDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

import UIKit

final class EventSetupController: UIViewController {
    weak var delegate: EntryCreationDelegate?
    
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    
    private var group: TrackerGroup = TrackerGroup(name: "Домашнее задание", entries: [])
    private var category: TrackerGroup = TrackerGroup(name: "Домашнее задание", entries: [])
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓",
        "🥇", "🎸", "🏝️", "😪",
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
    
    private lazy var emojiCollectionView: EventEmojiCollection = {
        let collectionView = EventEmojiCollection(emojies: emojies)
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
    
    private lazy var colorCollectionView: EventColorCollection = {
        let collectionView = EventColorCollection(colors: colors)
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
        navigationItem.title = "Новое событие"
        setupInterface()
        
        categoryStore.ensureDefaultCategoryExists("Домашнее задание")
    }
    
    private func setupInterface() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(eventNameField)
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
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            eventNameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            eventNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            eventNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            eventNameField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTable.topAnchor.constraint(equalTo: eventNameField.bottomAnchor, constant: 24),
            optionsTable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsTable.heightAnchor.constraint(equalToConstant: 75),
            
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
    }
    
    @objc private func nameFieldChanged() {
        updateSaveButtonState()
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard
                let name = eventNameField.text, !name.isEmpty,
                let selectedEmoji = selectedEmoji,
                let selectedColor = selectedColor
            else {
                return
            }
            
            let tracker = Tracker(
                id: UUID(),
                name: name,
                color: selectedColor,
                icon: selectedEmoji,
                activeDays: [],
                category: group
            )
            
            do {
                try trackerStore.addTracker(tracker, categoryName: group.name)
                delegate?.didCreateNewEvent(
                    name: name,
                    group: group,
                    icon: selectedEmoji,
                    color: selectedColor
                )
                presentingViewController?.presentingViewController?.dismiss(animated: true)
            } catch {
                print("Ошибка при сохранении события: \(error)")
            }
    }
    
    private func updateSaveButtonState() {
        let isNameValid = !(eventNameField.text?.isEmpty ?? true)
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil

        saveButton.isEnabled = isNameValid && isEmojiSelected && isColorSelected
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

extension EventSetupController: EventEmojiSelectionDelegate, EventColorSelectionDelegate {
    func didSelectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateSaveButtonState()
    }
    
    func didSelectColor(_ color: UIColor) {
        selectedColor = color
        updateSaveButtonState()
    }
}
