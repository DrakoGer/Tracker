//
//  CategoryHeader.swift
//  Tracker
//
//  Created by Yura on 12.04.25.
//


import UIKit

final class CategoryHeader: UICollectionReusableView {
    static let headerID = "CategoryHeader"

    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YS Display Bold", size: 19)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInterface()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupInterface() {
        addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }
}
