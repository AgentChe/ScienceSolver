//
//  AMInputBottomView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AMInputBottomView: UIView {
    lazy var cameraButton = makeCameraButton()
    lazy var calculatorButton = makeCalculatorButton()
    lazy var selectEntityButton = makeSelectEntityButton()
    
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
private extension AMInputBottomView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
}

// MARK: Make constraints
private extension AMInputBottomView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 24.scale),
            cameraButton.heightAnchor.constraint(equalToConstant: 24.scale),
            cameraButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.scale),
            cameraButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            calculatorButton.widthAnchor.constraint(equalToConstant: 24.scale),
            calculatorButton.heightAnchor.constraint(equalToConstant: 24.scale),
            calculatorButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -67.scale),
            calculatorButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            selectEntityButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            selectEntityButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AMInputBottomView {
    func makeCameraButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "AssistantMain.Camera"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCalculatorButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "AssistantMain.Calculator"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSelectEntityButton() -> AMSelectEntityButton {
        let view = AMSelectEntityButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
