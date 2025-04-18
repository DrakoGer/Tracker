//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//


import UIKit

final class ScheduleCell: UITableViewCell {
    static let cellID = "DayPickerCell"

    let daySwitch = UISwitch()
    private let dayLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInterface() {
        backgroundColor = UIColor(named: "CustomBackgroundDay")

        dayLabel.font = .systemFont(ofSize: 16)
        contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(daySwitch)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    func configure(day: String, isSelected: Bool, isLast: Bool = false) {
        dayLabel.text = day
        daySwitch.isOn = isSelected
        layer.cornerRadius = isLast ? 12 : 0
        layer.maskedCorners = isLast ? [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] : []
        layer.masksToBounds = true
    }
}
