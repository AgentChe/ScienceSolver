//
//  ARTLoadingCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit
import Lottie

final class ARTLoadingCell: UITableViewCell {
    lazy var animationView = makeAnimationView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension ARTLoadingCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }
}

// MARK: Make constraints
private extension ARTLoadingCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            animationView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -290.scale),
            animationView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            animationView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension ARTLoadingCell {
    func makeAnimationView() -> LottieAnimationView {
        let animation = LottieAnimation.named("ART.Loader")
        let view = LottieAnimationView(animation: animation)
        view.backgroundColor = UIColor.clear
        view.loopMode = .loop
        view.play()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
}
