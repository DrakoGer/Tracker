//
//  EmojiCollection.swift
//  Tracker
//
//  Created by Yura on 18.04.2025.
//

import UIKit

final class HabitEmojiCollection: UICollectionView {
    weak var selectionDelegate: HabitEmojiSelectionDelegate?
    private let emojies: [String]
    private var selectedIndex: Int?
    
    init(emojies: [String]) {
        self.emojies = emojies
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: .zero, collectionViewLayout: layout)
        
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        register(HabitEmojiCell.self, forCellWithReuseIdentifier: "HabitEmojiCell")
        delegate = self
        dataSource = self
        backgroundColor = .clear
        isScrollEnabled = false
    }
}

extension HabitEmojiCollection: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HabitEmojiCell", for: indexPath) as? HabitEmojiCell else {
            return UICollectionViewCell()
        }
        
        let emoji = emojies[indexPath.item]
        cell.configure(with: emoji)
        
        
        if let selectedIndex = selectedIndex, selectedIndex == indexPath.item {
            
            if let selectedColor = UIColor(named: "CustomLightGrey") {
                cell.setSelectedBackground(color: selectedColor)
            } else {
                
                cell.setSelectedBackground(color: .lightGray)
            }
        } else {
            cell.clearSelectedBackground()
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
        
        selectionDelegate?.didSelectEmoji(emojies[indexPath.item])
        
        if let previousIndex = previousIndex {
            collectionView.reloadItems(at: [IndexPath(item: previousIndex, section: 0)])
        }
        collectionView.reloadItems(at: [indexPath])
    }
}
