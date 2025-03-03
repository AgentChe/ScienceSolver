//
//  AMSelectEntityButton.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AMSelectEntityButton: UIButton {
    enum Entity {
        case writingStyle(WritingStyle)
        case language(Language)
    }
    
    var entity: Entity? {
        didSet {
            update()
        }
    }
    
    lazy var label = makeLabel()
    lazy var arrowView = makeArrowView()
    
    private lazy var attrs = TextAttributes()
        .textColor(Appearance.main400)
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(22.scale)
        .textAlignment(.left)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AMSelectEntityButton {
    func initialize() {
        backgroundColor = Appearance.main400.withAlphaComponent(0.2)
        layer.cornerRadius = 15.scale
    }
    
    func update() {
        isHidden = entity == nil
        label.attributedText = entity?.title.attributed(with: attrs)
    }
}

// MARK: Make constraints
private extension AMSelectEntityButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.scale),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4.scale),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.scale),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.scale)
        ])
        
        NSLayoutConstraint.activate([
            arrowView.widthAnchor.constraint(equalToConstant: 16.scale),
            arrowView.heightAnchor.constraint(equalToConstant: 16.scale),
            arrowView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AMSelectEntityButton {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeArrowView() -> UIImageView {
        let view = UIImageView()
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "AssistantMain.SelectEntity.Arrow")
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

// MARK: Additional
private extension AMSelectEntityButton.Entity {
    var title: String {
        switch self {
        case .writingStyle(let writingStyle):
            switch writingStyle {
            case .expository:
                return "WritingStyle.Expository".localized
            case .narrative:
                return "WritingStyle.Narrative".localized
            case .argumentative:
                return "WritingStyle.Argumentative".localized
            case .analytical:
                return "WritingStyle.Analytical".localized
            case .research:
                return "WritingStyle.Research".localized
            case .descriptive:
                return "WritingStyle.Descriptive".localized
            case .omparative:
                return "WritingStyle.Comparative".localized
            case .other:
                return "WritingStyle.Other".localized
            }
        case .language(let language):
            return String(format: "AssistantMain.Translate".localized, language.name)
        }
    }
}
