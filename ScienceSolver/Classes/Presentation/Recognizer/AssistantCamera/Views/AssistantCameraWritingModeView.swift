//
//  AssistantCameraWritingModeView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class AssistantCameraWritingModeView: UIView {
    var didChangeMode: ((WritingMode) -> Void)?
    
    enum Style {
        case camera
        case manual
    }
    
    lazy var mode: WritingMode = .essay {
        didSet {
            update(animate: true)
            didChangeMode?(mode)
        }
    }
    
    lazy var selector = makeSelector()
    lazy var essayButton = makeButton()
    lazy var outlineButton = makeButton()
    
    private lazy var selectedAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.medium(size: 16.scale))
    private lazy var deselectedCameraAttrs = TextAttributes()
        .textColor(Appearance.mono100)
        .font(Fonts.Inter.medium(size: 16.scale))
    private lazy var deselectedManualAttrs = TextAttributes()
        .textColor(Appearance.mono200.withAlphaComponent(0.4))
        .font(Fonts.Inter.medium(size: 16.scale))
    
    private lazy var selectorLeadingConstraint = NSLayoutConstraint()
    private lazy var selectorTrailingConstraint = NSLayoutConstraint()
    
    private lazy var disposeBag = DisposeBag()
    
    private let style: Style
    
    init(style: Style) {
        self.style = style
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        update(animate: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AssistantCameraWritingModeView {
    func initialize() {
        backgroundColor = {
            switch style {
            case .camera:
                return Appearance.main100.withAlphaComponent(0.2)
            case .manual:
                return  Appearance.main100
            }
        }()
        layer.cornerRadius = 21.5.scale
        layer.masksToBounds = true
        
        Observable
            .merge(
                essayButton.rx.tap.map { WritingMode.essay },
                outlineButton.rx.tap.map { WritingMode.outline }
            )
            .bind(to: Binder(self) { base, mode in
                base.mode = mode
            })
            .disposed(by: disposeBag)
    }
    
    func update(animate: Bool) {
        NSLayoutConstraint.deactivate([
            selectorLeadingConstraint,
            selectorTrailingConstraint
        ])
        
        let essayAttrs = {
            switch style {
            case .camera:
                return mode == .essay ? selectedAttrs : deselectedCameraAttrs
            case .manual:
                return mode == .essay ? selectedAttrs : deselectedManualAttrs
            }
        }()
        essayButton.setAttributedTitle("AssistantCamera.Essay".localized.attributed(with: essayAttrs), for: .normal)
        
        let outlineAttrs = {
            switch style {
            case .camera:
                return mode == .outline ? selectedAttrs : deselectedCameraAttrs
            case .manual:
                return mode == .outline ? selectedAttrs : deselectedManualAttrs
            }
        }()
        outlineButton.setAttributedTitle("AssistantCamera.Outline".localized.attributed(with: outlineAttrs), for: .normal)
        
        switch mode {
        case .essay:
            selectorLeadingConstraint = selector.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4.scale)
            selectorTrailingConstraint = selector.trailingAnchor.constraint(equalTo: centerXAnchor)
        case .outline:
            selectorLeadingConstraint = selector.leadingAnchor.constraint(equalTo: centerXAnchor)
            selectorTrailingConstraint = selector.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4.scale)
        }
        
        NSLayoutConstraint.activate([
            selectorLeadingConstraint,
            selectorTrailingConstraint
        ])
        
        if animate {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.layoutIfNeeded()
            })
        } else {
            layoutIfNeeded()
        }
    }
}

// MARK: Make constraints
private extension AssistantCameraWritingModeView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            selector.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            selector.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale)
        ])
        
        NSLayoutConstraint.activate([
            essayButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            essayButton.trailingAnchor.constraint(equalTo: centerXAnchor),
            essayButton.topAnchor.constraint(equalTo: topAnchor),
            essayButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            outlineButton.leadingAnchor.constraint(equalTo: centerXAnchor),
            outlineButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            outlineButton.topAnchor.constraint(equalTo: topAnchor),
            outlineButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantCameraWritingModeView {
    func makeSelector() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = 17.5.scale
        view.backgroundColor = Appearance.mono100
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeButton() -> UIButton {
        let view = UIButton()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
