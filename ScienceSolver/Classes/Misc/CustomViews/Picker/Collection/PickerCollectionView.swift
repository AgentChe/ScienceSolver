//
//  PickerCollectionView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 03.03.2025.
//

import UIKit

final class PickerCollectionView: UICollectionView {
    enum Constants {
        static let cellHeight = 40.scale
    }
    
    var didSelect: ((Int) -> Void)?
    
    private lazy var elements = [PickerCollectionElement]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PickerCollectionView {
    func setup(elements: [PickerCollectionElement]) {
        self.elements = elements
        
        if let index = elements.firstIndex(where: { $0.selected }) {
            let indexPath = IndexPath(row: index, section: 0)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock { [weak self] in
                self?.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }

            reloadData()

            CATransaction.commit()
        } else {
            reloadData()
        }
    }
}

// MARK: UICollectionViewDataSource
extension PickerCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: PickerCollectionCell.self), for: indexPath) as! PickerCollectionCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PickerCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: bounds.size.width, height: Constants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (bounds.height * 0.5) - (Constants.cellHeight / 2)
        return UIEdgeInsets(vertical: inset)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(
            x: bounds.width / 2,
            y: scrollView.contentOffset.y + bounds.height / 2
        )
        
        guard let indexPath = indexPathForItem(at: centerPoint) else { return }
        
        elements.enumerated().forEach { index, element in
            element.selected = indexPath.row == index
        }
        
        reloadData()
        
        didSelect?(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        elements.enumerated().forEach { index, element in
            element.selected = indexPath.row == index
        }
        
        scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        
        reloadData()
        
        didSelect?(indexPath.row)
    }
}

// MARK: Private
private extension PickerCollectionView {
    func initialize() {
        register(PickerCollectionCell.self, forCellWithReuseIdentifier: String(describing: PickerCollectionCell.self))
        
        dataSource = self
        delegate = self
    }
}
