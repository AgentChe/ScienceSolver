//
//  MainView.swift
//  CVMaker
//
//  Created by Андрей Чернышев on 27.08.2024.
//

import UIKit

final class MainView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension MainView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension MainView {
    func makeConstraints() {
        
    }
}

// MARK: Lazy initialization
private extension MainView {
    
}
