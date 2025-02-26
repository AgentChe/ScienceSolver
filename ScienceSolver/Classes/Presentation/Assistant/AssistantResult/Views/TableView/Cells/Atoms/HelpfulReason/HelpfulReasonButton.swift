//
//  HelpfulReasonButton.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 22.02.2025.
//

import UIKit

final class HelpfulReasonButton: UIButton {
    lazy var marked = false {
        didSet {
            update()
        }
    }
    
    lazy var markedView = makeMarkedView()
    lazy var label = makeLabel()
    
    private let text: String
    
    init(text: String) {
        self.text = text
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension HelpfulReasonButton {
    func initialize() {
        backgroundColor = UIColor.clear
    }
    
    func update() {
        let icon = UIImage(named: marked ? "AssistantResult.Reason.Checked" : "AssistantResult.Reason.Unchecked")
        markedView.image = icon
    }
}

// MARK: Make constraints
private extension HelpfulReasonButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            markedView.widthAnchor.constraint(equalToConstant: 16.scale),
            markedView.heightAnchor.constraint(equalToConstant: 16.scale),
            markedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            markedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HelpfulReasonButton {
    func makeMarkedView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.regular(size: 14.scale))
            .lineHeight(17.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = text.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
