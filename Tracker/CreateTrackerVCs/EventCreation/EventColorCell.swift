//
//  EventColorCell.swift
//  Tracker
//
//  Created by Yura on 22.04.25.
//

import UIKit

final class EventColorCell: UICollectionViewCell {
    private let colorView = UIView()
    private let selectedBorderView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        
        selectedBorderView.layer.cornerRadius = 8
        selectedBorderView.layer.borderWidth = 3
        selectedBorderView.layer.masksToBounds = true
        selectedBorderView.isHidden = true
        selectedBorderView.backgroundColor = .clear
        selectedBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectedBorderView)
        
        NSLayoutConstraint.activate([
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            
            selectedBorderView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectedBorderView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectedBorderView.widthAnchor.constraint(equalToConstant: 52),
            selectedBorderView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
        selectedBorderView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func setSelectedBorder(isSelected: Bool) {
        selectedBorderView.isHidden = !isSelected
    }
}
