//
//  EntryCellDelegate.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//


import UIKit

protocol EntryCellDelegate: AnyObject {
    func updateEntryCount(cell: EntryCell)
}

final class EntryCell: UICollectionViewCell {
    static let cellID = "EntryCell"
    private(set) var entryId: UUID?

    weak var delegate: EntryCellDelegate?

    private lazy var entryView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        contentView.addSubview(view)
        return view
    }()

    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Medium", size: 16)
        label.textAlignment = .center
        entryView.addSubview(label)
        return label
    }()

    private lazy var iconBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(named: "EmojiCircle")
        entryView.addSubview(view)
        return view
    }()

    private lazy var entryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Medium", size: 12)
        label.textColor = UIColor(named: "CustomWhite")
        label.numberOfLines = 2
        entryView.addSubview(label)
        return label
    }()

    private lazy var countContainer: UIView = {
        let view = UIView()
        contentView.addSubview(view)
        return view
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Medium", size: 12)
        label.textColor = UIColor(named: "CustomBlack")
        countContainer.addSubview(label)
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        button.layer.cornerRadius = 15
        countContainer.addSubview(button)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInterface() {
        [entryView, iconLabel, iconBackground, entryLabel, countContainer, countLabel, actionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            entryView.topAnchor.constraint(equalTo: topAnchor),
            entryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            entryView.trailingAnchor.constraint(equalTo: trailingAnchor),
            entryView.heightAnchor.constraint(equalToConstant: 100),

            iconBackground.topAnchor.constraint(equalTo: entryView.topAnchor, constant: 10),
            iconBackground.leadingAnchor.constraint(equalTo: entryView.leadingAnchor, constant: 10),
            iconBackground.widthAnchor.constraint(equalToConstant: 20),
            iconBackground.heightAnchor.constraint(equalToConstant: 20),

            iconLabel.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),

            entryLabel.topAnchor.constraint(equalTo: iconBackground.bottomAnchor, constant: 10),
            entryLabel.leadingAnchor.constraint(equalTo: entryView.leadingAnchor, constant: 10),
            entryLabel.trailingAnchor.constraint(equalTo: entryView.trailingAnchor, constant: -10),
            entryLabel.bottomAnchor.constraint(equalTo: entryView.bottomAnchor, constant: -10),

            countContainer.topAnchor.constraint(equalTo: entryView.bottomAnchor),
            countContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            countContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            countContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            countContainer.heightAnchor.constraint(equalToConstant: 60),

            countLabel.centerYAnchor.constraint(equalTo: countContainer.centerYAnchor),
            countLabel.leadingAnchor.constraint(equalTo: countContainer.leadingAnchor, constant: 10),

            actionButton.centerYAnchor.constraint(equalTo: countContainer.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: countContainer.trailingAnchor, constant: -10),
            actionButton.widthAnchor.constraint(equalToConstant: 30),
            actionButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }

    func configure(title: String, color: UIColor, icon: String, completionCount: Int, entryId: UUID, isCompleted: Bool, isActive: Bool = true) {
        actionButton.backgroundColor = color
        entryView.backgroundColor = color
        iconLabel.text = icon
        entryLabel.text = title
        self.entryId = entryId
        countLabel.text = completionCount.days()
        updateCompletionState(isCompleted: isCompleted, isActive: isActive)
    }

    func updateCompletionState(isCompleted: Bool, isActive: Bool = true) {
        let image = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        actionButton.setImage(image, for: .normal)
        actionButton.tintColor = .white
        actionButton.alpha = isCompleted ? 0.5 : 1.0
        actionButton.isEnabled = isActive
    }

    @objc private func actionTapped() {
        delegate?.updateEntryCount(cell: self)
    }
}

extension Int {
    func days() -> String {
        let mod100 = self % 100
        let mod10 = self % 10

        if (11...14).contains(mod100) {
            return "\(self) дней"
        }

        switch mod10 {
        case 1: return "\(self) день"
        case 2...4: return "\(self) дня"
        default: return "\(self) дней"
        }
    }
}
