//
//  AssistantCameraActionButton.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 28.02.2025.
//

import UIKit

final class AssistantCameraActionButton: TapAreaButton {
    enum Mode {
        case take
        case other
    }
    
    lazy var blurView = makeBlurView()
    lazy var iconView = makeIconView()
    
    private let iconName: String
    private let mode: Mode
    
    init(iconName: String, mode: Mode) {
        self.iconName = iconName
        self.mode = mode
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AssistantCameraActionButton {
    func initialize() {
        layer.cornerRadius = mode == .take ? 36.scale : 20.scale
        layer.masksToBounds = true
    }
}

// MARK: Make constraints
private extension AssistantCameraActionButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: mode == .take ? 72.scale : 24.scale),
            iconView.heightAnchor.constraint(equalToConstant: mode == .take ? 72.scale : 24.scale),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantCameraActionButton {
    func makeBlurView() -> UIVisualEffectView {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        view.isUserInteractionEnabled = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = mode == .take ? 36.scale : 20.scale
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeIconView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
