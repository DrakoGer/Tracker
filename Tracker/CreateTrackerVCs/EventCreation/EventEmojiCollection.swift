//
//  EventEmojiCollection.swift
//  Tracker
//
//  Created by Yura on 22.04.25.
//

import UIKit

final class EventEmojiCollection: UICollectionView {
    weak var selectionDelegate: EventEmojiSelectionDelegate?
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
        register(EventEmojiCell.self, forCellWithReuseIdentifier: "EventEmojiCell")
        delegate = self
        dataSource = self
        backgroundColor = .clear
        isScrollEnabled = false
    }
}

extension EventEmojiCollection: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventEmojiCell", for: indexPath) as? EventEmojiCell else {
            return UICollectionViewCell()
        }
        
        let emoji = emojies[indexPath.item]
        cell.configure(with: emoji)
        
        
        if selectedIndex == indexPath.item {
            let color = UIColor(named: "CustomLightGrey") ?? .lightGray
            cell.setSelectedBackground(color: color)
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
