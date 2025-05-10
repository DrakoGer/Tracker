//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Yura on 29.03.25.
//

import UIKit

protocol EntryCreationDelegate: AnyObject {
    func didCreateNewHabit(name: String, group: TrackerGroup, icon: String, color: UIColor, days: Set<WeekDay>)
    func didCreateNewEvent(name: String, group: TrackerGroup, icon: String, color: UIColor)
}

final class TrackersViewController: UIViewController {
    private let dateSelector = UIDatePicker()
    private let titleLabel = UILabel()
    private let searchField = UISearchBar()
    private let emptyIcon = UIImageView()
    private let emptyMessage = UILabel()

    private let edgePadding: CGFloat = 20
    private let itemSpacing: CGFloat = 12
    private let itemHeight: CGFloat = 160
    private lazy var itemWidth = (UIScreen.main.bounds.width - edgePadding * 2 - itemSpacing) / 2

    private var entryGroups: [TrackerGroup] = []
    private var hiddenGroups: [TrackerGroup] = []
    private var completedEntries: [TrackerRecord] = []
    private var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        print("TrackersViewController: viewDidLoad called")
        view.backgroundColor = UIColor(named: "CustomWhite")
        entryGroups = DataManager.shared.entryGroups
        print("TrackersViewController: entryGroups loaded - \(entryGroups)")
        filterEntries(for: selectedDate)
        print("TrackersViewController: entries filtered - \(entryGroups)")
        setupInterface()
        print("TrackersViewController: setupInterface completed")
    }

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var entryGrid: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let grid = UICollectionView(frame: .zero, collectionViewLayout: layout)
        grid.backgroundColor = .clear
        grid.dataSource = self
        grid.delegate = self
        grid.showsVerticalScrollIndicator = false
        grid.register(EntryCell.self, forCellWithReuseIdentifier: EntryCell.cellID)
        grid.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeader.headerID)
        return grid
    }()

    private func setupInterface() {
        setupNavigationBar()
        setupTitleLabel()
        setupSearchField()
        setupEmptyIcon()
        setupEmptyMessage()
        setupEntryGrid()

        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        updateEmptyStateVisibility()
    }

    private func setupEntryGrid() {
        entryGrid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(entryGrid)
        NSLayoutConstraint.activate([
            entryGrid.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 15),
            entryGrid.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            entryGrid.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            entryGrid.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupNavigationBar() {
        let createButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(createEntryTapped))
        createButton.tintColor = UIColor(named: "CustomBlack")
        navigationItem.leftBarButtonItem = createButton

        dateSelector.tintColor = UIColor(named: "CustomBlack")
        dateSelector.datePickerMode = .date
        dateSelector.preferredDatePickerStyle = .compact
        dateSelector.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dateSelector)
    }

    private func setupTitleLabel() {
        titleLabel.text = "Трекеры"
        titleLabel.textColor = UIColor(named: "CustomBlack")
        titleLabel.font = UIFont(name: "YS Display Bold", size: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgePadding),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
        ])
    }

    private func setupSearchField() {
        searchField.placeholder = "Поиск"
        searchField.searchBarStyle = .minimal
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)

        if let textField = searchField.value(forKey: "searchField") as? UITextField {
            textField.layer.cornerRadius = 12
            textField.layer.masksToBounds = true
            textField.backgroundColor = UIColor(named: "CustomWhite")
            textField.font = UIFont(name: "YS Display Medium", size: 17)
            textField.attributedPlaceholder = NSAttributedString(
                string: "Поиск",
                attributes: [.foregroundColor: UIColor.lightGray, .font: UIFont.systemFont(ofSize: 16)]
            )
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.heightAnchor.constraint(equalToConstant: 40),
                textField.leadingAnchor.constraint(equalTo: searchField.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
                textField.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            ])
        }

        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgePadding),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgePadding),
            searchField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func setupEmptyIcon() {
        emptyIcon.image = UIImage(named: "placeHolder")
        emptyIcon.tintColor = .gray
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyIcon)
        NSLayoutConstraint.activate([
            emptyIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 90),
            emptyIcon.heightAnchor.constraint(equalToConstant: 90),
        ])
    }

    private func setupEmptyMessage() {
        emptyMessage.text = "Что будем отслеживать?"
        emptyMessage.font = UIFont(name: "YS Display Medium", size: 17)
        emptyMessage.textColor = UIColor(named: "CustomBlack")
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.addSubview(emptyMessage)
        NSLayoutConstraint.activate([
            emptyMessage.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 10),
            emptyMessage.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyMessage.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),
        ])
    }

    private func updateEmptyStateVisibility() {
        let hasEntries = entryGroups.contains { !$0.entries.isEmpty }
        emptyStateView.isHidden = hasEntries
        entryGrid.isHidden = !hasEntries
    }

    @objc private func createEntryTapped() {
        let typeSelector = EntryTypeSelector()
        typeSelector.delegate = self
        let navController = UINavigationController(rootViewController: typeSelector)
        present(navController, animated: true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        dateSelector.date = selectedDate
        filterEntries(for: selectedDate)
        updateEmptyStateVisibility()
        entryGrid.reloadData()
    }

    private func filterEntries(for date: Date) {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        let today = Date()
        let isToday = calendar.isDate(date, inSameDayAs: today)

        entryGroups = DataManager.shared.entryGroups.compactMap { group in
            let filteredEntries = group.entries.filter { entry in
                if entry.activeDays.isEmpty {
                    return isToday
                }
                return entry.activeDays.contains { $0.dayNumber == dayOfWeek }
            }
            return filteredEntries.isEmpty ? nil : TrackerGroup(name: group.name, entries: filteredEntries)
        }
    }

    private func markEntryComplete(id: UUID, on date: Date) {
        let log = TrackerRecord(entryId: id, date: date)
        completedEntries.append(log)
    }

    private func unmarkEntryComplete(id: UUID, on date: Date) {
        completedEntries.removeAll {
            $0.entryId == id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let activeGroups = entryGroups.filter { !$0.entries.isEmpty }
        return activeGroups[section].entries.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return entryGroups.filter { !$0.entries.isEmpty }.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EntryCell.cellID, for: indexPath) as? EntryCell else {
            fatalError("Failed to dequeue EntryCell")
        }

        let entry = entryGroups[indexPath.section].entries[indexPath.item]
        let isCompleted = completedEntries.contains { log in
            log.entryId == entry.id && Calendar.current.isDate(log.date, inSameDayAs: dateSelector.date)
        }
        let today = Calendar.current.startOfDay(for: Date())
        let cellDate = Calendar.current.startOfDay(for: selectedDate)
        let isActive = cellDate <= today

        cell.configure(
            title: entry.name,
            color: UIColor(named: "CustomGreen")!,
            icon: entry.icon,
            completionCount: completedEntries.filter { $0.entryId == entry.id }.count,
            entryId: entry.id,
            isCompleted: isCompleted,
            isActive: isActive
        )
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeader.headerID, for: indexPath) as? CategoryHeader else {
            return UICollectionReusableView()
        }
        let activeGroups = entryGroups.filter { !$0.entries.isEmpty }
        header.headerLabel.text = activeGroups[indexPath.section].name
        return header
    }
}

extension TrackersViewController: EntryCellDelegate {
    func updateEntryCount(cell: EntryCell) {
        guard let entryId = cell.entryId else { return }
        let selectedDate = dateSelector.date
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let cellDate = calendar.startOfDay(for: selectedDate)

        guard cellDate <= today else { return }

        if let index = completedEntries.firstIndex(where: { $0.entryId == entryId && calendar.isDate($0.date, inSameDayAs: selectedDate) }) {
            completedEntries.remove(at: index)
        } else {
            completedEntries.append(TrackerRecord(entryId: entryId, date: selectedDate))
        }

        if let indexPath = entryGrid.indexPath(for: cell) {
            entryGrid.reloadItems(at: [indexPath])
        }
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return DataManager.shared.entryGroups.isEmpty ? .zero : CGSize(width: collectionView.frame.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: edgePadding, bottom: 0, right: edgePadding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
}

extension TrackersViewController: EntryCreationDelegate {
    func didCreateNewEvent(name: String, group: TrackerGroup, icon: String, color: UIColor) {
        let newEntry = Tracker(
            id: UUID(),
            name: name,
            color: color, // Используем переданный color
            icon: icon,   // icon уже строка, преобразование не нужно
            activeDays: [],
            category: group // Передаем группу как category
        )
        DataManager.shared.addEntry(newEntry, toGroupWithName: group.name)
        refreshInterfaceAfterCreation()
    }

    func didCreateNewHabit(name: String, group: TrackerGroup, icon: String, color: UIColor, days: Set<WeekDay>) {
        let newEntry = Tracker(
            id: UUID(),
            name: name,
            color: color, // Используем переданный color
            icon: icon,   // icon уже строка, преобразование не нужно
            activeDays: days,
            category: group // Передаем группу как category
        )
        DataManager.shared.addEntry(newEntry, toGroupWithName: group.name)
        refreshInterfaceAfterCreation()
    }

    private func refreshInterfaceAfterCreation() {
        entryGroups = DataManager.shared.entryGroups
        filterEntries(for: selectedDate)
        updateEmptyStateVisibility()
        entryGrid.reloadData()
    }
}
