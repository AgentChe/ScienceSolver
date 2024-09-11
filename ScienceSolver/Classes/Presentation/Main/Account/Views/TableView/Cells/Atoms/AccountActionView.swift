//
//  AccountActionView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 11.09.2024.
//

import UIKit
import RxSwift

final class AccountActionView: UIView {
    lazy var label = makeLabel()
    lazy var arrowView = makeArrowView()
    lazy var separator = makeSeparator()
    
    private let title: String
    private let separatorHidden: Bool
    private let didTap: () -> Void
    
    private lazy var disposeBag = DisposeBag()
    
    init(title: String, separatorHidden: Bool, didTap: @escaping () -> Void) {
        self.title = title
        self.separatorHidden = separatorHidden
        self.didTap = didTap
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AccountActionView {
    func initialize() {
        backgroundColor = Appearance.mono100
        
        let tapGesture = UITapGestureRecognizer()
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind(to: Binder(self) { base, event in
                base.didTap()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Make constraints
private extension AccountActionView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 18.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18.scale)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 24.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 24.scale),
            arrowView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AccountActionView {
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.medium(size: 16.scale))
            .lineHeight(19.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.attributedText = title.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "Account.ArrowRight")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.isHidden = separatorHidden
        view.backgroundColor = Appearance.main200
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
