//
//  PickerView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 03.03.2025.
//

import UIKit

protocol PickerViewElement {
    var title: String { get }
}

final class PickerView<T: PickerViewElement>: UIView {
    lazy var collectionView = makeCollectionView()
    lazy var topGradientView = makeGradiendView()
    lazy var centeredView = makeCenteredView()
    lazy var bottomGradientView = makeGradiendView()
    
    private(set) var selected: T?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PickerView {
    func setup(elements: [T], initialIndex: Int?) {
        let collectionElements = elements
            .enumerated()
            .map { index, element -> PickerCollectionElement in
                PickerCollectionElement(
                    title: element.title,
                    selected: index == initialIndex
                )
            }
        collectionView.setup(elements: collectionElements)
        
        collectionView.didSelect = { [weak self] selectedIndex in
            self?.selected = elements[safe: selectedIndex]
        }
        
        selected = {
            guard let index = collectionElements.firstIndex(where: { $0.selected }) else { return nil }
            return elements[safe: index]
        }()
    }
}

// MARK: Private
private extension PickerView {
    func initialize() {
        backgroundColor = UIColor.clear
        
        topGradientView.gradientLayer.colors = [
            Appearance.main100.cgColor,
            Appearance.main100.withAlphaComponent(0).cgColor
        ]
        bottomGradientView.gradientLayer.colors = [
            Appearance.main100.withAlphaComponent(0).cgColor,
            Appearance.main100.cgColor
        ]
    }
}

// MARK: Make constraints
private extension PickerView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topGradientView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.24),
            topGradientView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            centeredView.leadingAnchor.constraint(equalTo: leadingAnchor),
            centeredView.trailingAnchor.constraint(equalTo: trailingAnchor),
            centeredView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            centeredView.heightAnchor.constraint(equalToConstant: 40.scale)
        ])
        
        NSLayoutConstraint.activate([
            bottomGradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomGradientView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.24),
            bottomGradientView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PickerView {
    func makeCollectionView() -> PickerCollectionView {
        let layout = PIckerCollectionLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let view = PickerCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeGradiendView() -> GradientView {
        let view = GradientView()
        view.isUserInteractionEnabled = false
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCenteredView() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = Appearance.main400.withAlphaComponent(0.2)
        view.layer.cornerRadius = 8.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
