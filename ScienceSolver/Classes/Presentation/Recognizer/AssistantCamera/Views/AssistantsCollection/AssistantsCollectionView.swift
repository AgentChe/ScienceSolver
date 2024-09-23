//
//  AssistantsCollectionView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class AssistantsCollectionView: UICollectionView {
    lazy var elements = [AssistantsCollectionElement]()
    
    private lazy var didSelectTrigger = PublishRelay<AssistantsCollectionElement.Assistant>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AssistantsCollectionView {
    func setup(elements: [AssistantsCollectionElement]) {
        self.elements = elements
        
        if let index = elements.firstIndex(where: { $0.marked }) {
            let indexPath = IndexPath(row: index, section: 0)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock { [weak self] in
                self?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            }

            reloadData()

            CATransaction.commit()
        } else {
            reloadData()
        }
    }
    
    var didSelect: Signal<AssistantsCollectionElement.Assistant> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UICollectionViewDataSource
extension AssistantsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: AssistantsCollectionCell.self), for: indexPath) as! AssistantsCollectionCell
        cell.setup(element: elements[indexPath.row])
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension AssistantsCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        elements.enumerated().forEach { index, element in
            element.marked = indexPath.row == index
        }
        
        CATransaction.begin()
        
        CATransaction.setCompletionBlock { [weak self] in
            self?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            if let assistant = self?.elements.first(where: { $0.marked })?.assistant {
                self?.didSelectTrigger.accept(assistant)
            }
        }

        reloadData()

        CATransaction.commit()
    }
}

// MARK: Private
private extension AssistantsCollectionView {
    func initialize() {
        register(AssistantsCollectionCell.self, forCellWithReuseIdentifier: String(describing: AssistantsCollectionCell.self))
        
        dataSource = self
        delegate = self
    }
}
