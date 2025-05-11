//
//  EventColorCollection.swift.swift
//  Tracker
//
//  Created by Yura on 22.04.25.
//

import UIKit

final class EventColorCollection: UICollectionView {
    
    weak var selectionDelegate: EventColorSelectionDelegate?
    
    private var selectedIndex: Int?
    private let colors: [UIColor]
    
    init(colors: [UIColor]) {
        self.colors = colors
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        register(EventColorCell.self, forCellWithReuseIdentifier: "EventColorCell")
        delegate = self
        dataSource = self
        backgroundColor = .clear
        isScrollEnabled = false
    }
}

extension EventColorCollection: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventColorCell", for: indexPath) as? EventColorCell else {
            return UICollectionViewCell()
        }
        let color = colors[indexPath.item]
        cell.configure(with: color)
        
        if let selectedIndex = selectedIndex, selectedIndex == indexPath.item {
            cell.setSelectedBorder(isSelected: true)
        } else {
            cell.setSelectedBorder(isSelected: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let previousIndex = selectedIndex
        
        selectedIndex = indexPath.item
        
        selectionDelegate?.didSelectColor(colors[indexPath.item])
        
        if let previousIndex = previousIndex {
            collectionView.reloadItems(at: [IndexPath(item: previousIndex, section: 0)])
        }
        collectionView.reloadItems(at: [indexPath])
    }
}
