//
//  ARTAnswerCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit
import WebKit

final class ARTAnswerCell: UITableViewCell {
    var didTapRefresh: (() -> Void)?
    var didTapCopy: ((AssistantResultTableAnswerElement) -> Void)?
    
    lazy var container = makeContainer()
    lazy var stackView = makeStackView()
    
    private lazy var titleAttrs = TextAttributes()
        .textColor(Appearance.main400)
        .font(Fonts.Inter.medium(size: 16.scale))
        .lineHeight(19.scale)
        .textAlignment(.left)
    private lazy var normalAttrs = TextAttributes()
        .textColor(Appearance.mono200)
        .font(Fonts.Inter.regular(size: 16.scale))
        .lineHeight(22.scale)
        .textAlignment(.left)
    
    private var answer: AssistantResultTableAnswerElement?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension ARTAnswerCell {
    func setup(answer: AssistantResultTableAnswerElement) {
        self.answer = answer
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let views = makeViews(answer: answer)
        views.forEach { view in
            stackView.addArrangedSubview(view)
        }
        
        layoutIfNeeded()
    }
}

// MARK: Private
private extension ARTAnswerCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
    }
    
    @objc
    func refreshTapped() {
        didTapRefresh?()
    }
    
    @objc
    func copyTapped() {
        guard let answer else { return }
        
        didTapCopy?(answer)
    }
    
    func makeViews(answer: AssistantResultTableAnswerElement) -> [UIView] {
        switch answer {
        case .math(let response):
            return makeMathViews(response: response)
        case .physics(let response):
            return makePhysicsViews(response: response)
        case .biology(let response):
            return makeBiologyViews(response: response)
        case .chemistry(let response):
            return makeChemistryViews(response: response)
        case .writing(let response):
            return makeWritingViews(response: response)
        case .language(let translateResult):
            return makeLanguageViews(response: translateResult)
        }
    }
    
    func makeMathViews(response: MathAssistantResult.Response) -> [UIView] {
        var views =  [UIView]()
        
        guard response.detected, let data = response.data else {
            let errorLabel = makeNormalTextLabel(response.error ?? "")
            views.append(errorLabel)
            
            return views
        }
        
        if let userFormula = data.userFormula {
            let userFormulaViews = [
                makeTitleLabel("AssistantResult.Math.UserFormula".localized),
                makeKatexWebView(userFormula),
                makeSeparator()
            ]
            views.append(contentsOf: userFormulaViews)
        }
        
        let answerViews = [
            makeTitleLabel("AssistantResult.Answer".localized),
            makeKatexWebView(data.body),
            (data.explanation == nil && data.recommendation == nil) ? nil : makeSeparator()
        ].compactMap { $0 }
        views.append(contentsOf: answerViews)
        
        if let explanation = data.explanation {
            let explanationViews = [
                makeTitleLabel("AssistantResult.Explanation".localized),
                makeKatexWebView(explanation),
                (data.recommendation == nil) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: explanationViews)
        }
        
        if let recommendation = data.recommendation {
            let recommendationViews = [
                makeTitleLabel("AssistantResult.Recommendation".localized),
                makeKatexWebView(recommendation)
            ]
            views.append(contentsOf: recommendationViews)
        }
        
        let actionsView = makeActionsView()
        views.append(actionsView)
        
        return views
    }
    
    func makePhysicsViews(response: PhysicsAssistantResult.Response) -> [UIView] {
        var views = [UIView]()
        
        guard response.detected, let data = response.data else {
            let errorLabel = makeNormalTextLabel(response.error ?? "")
            views.append(errorLabel)
            
            return views
        }
        
        if !data.body.isEmpty {
            let bodyViews = [
                makeTitleLabel("AssistantResult.Answer".localized),
                makeHTMLTextLabel(data.body),
                (data.explanation.isEmpty && data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: bodyViews)
        }
        
        if !data.explanation.isEmpty {
            let explanationViews = [
                makeTitleLabel("AssistantResult.Explanation".localized),
                makeHTMLTextLabel(data.explanation),
                (data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: explanationViews)
        }
        
        if !data.recommendation.isEmpty {
            let recommendationViews = [
                makeTitleLabel("AssistantResult.Recommendation".localized),
                makeHTMLTextLabel(data.recommendation)
            ]
            views.append(contentsOf: recommendationViews)
        }
        
        let actionsView = makeActionsView()
        views.append(actionsView)
        
        return views
    }
    
    func makeBiologyViews(response: BiologyAssistantResult.Response) -> [UIView] {
        var views = [UIView]()
        
        guard response.detected, let data = response.data else {
            let errorLabel = makeNormalTextLabel(response.error ?? "")
            views.append(errorLabel)
            
            return views
        }
        
        if !data.body.isEmpty {
            let bodyViews = [
                makeTitleLabel("AssistantResult.Answer".localized),
                makeHTMLTextLabel(data.body),
                (data.explanation.isEmpty && data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: bodyViews)
        }
        
        if !data.explanation.isEmpty {
            let explanationViews = [
                makeTitleLabel("AssistantResult.Explanation".localized),
                makeHTMLTextLabel(data.explanation),
                (data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: explanationViews)
        }
        
        if !data.recommendation.isEmpty {
            let recommendationViews = [
                makeTitleLabel("AssistantResult.Recommendation".localized),
                makeHTMLTextLabel(data.recommendation)
            ]
            views.append(contentsOf: recommendationViews)
        }
        
        let actionsView = makeActionsView()
        views.append(actionsView)
        
        return views
    }
    
    func makeChemistryViews(response: ChemistryAssistantResult.Response) -> [UIView] {
        var views = [UIView]()
        
        guard response.detected, let data = response.data else {
            let errorLabel = makeNormalTextLabel(response.error ?? "")
            views.append(errorLabel)
            
            return views
        }
        
        if !data.body.isEmpty {
            let bodyViews = [
                makeTitleLabel("AssistantResult.Answer".localized),
                makeHTMLTextLabel(data.body),
                (data.explanation.isEmpty && data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: bodyViews)
        }
        
        if !data.explanation.isEmpty {
            let explanationViews = [
                makeTitleLabel("AssistantResult.Explanation".localized),
                makeHTMLTextLabel(data.explanation),
                (data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: explanationViews)
        }
        
        if !data.recommendation.isEmpty {
            let recommendationViews = [
                makeTitleLabel("AssistantResult.Recommendation".localized),
                makeHTMLTextLabel(data.recommendation)
            ]
            views.append(contentsOf: recommendationViews)
        }
        
        let actionsView = makeActionsView()
        views.append(actionsView)
        
        return views
    }
    
    func makeWritingViews(response: WritingAssistantResult.Response) -> [UIView] {
        var views = [UIView]()
        
        guard response.detected, let data = response.data else {
            let errorLabel = makeNormalTextLabel(response.error ?? "")
            views.append(errorLabel)
            
            return views
        }
        
        if !data.body.isEmpty {
            let bodyViews = [
                makeTitleLabel("AssistantResult.Answer".localized),
                makeHTMLTextLabel(data.body),
                (data.explanation.isEmpty && data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: bodyViews)
        }
        
        if !data.explanation.isEmpty {
            let explanationViews = [
                makeTitleLabel("AssistantResult.Explanation".localized),
                makeHTMLTextLabel(data.explanation),
                (data.recommendation.isEmpty) ? nil : makeSeparator()
            ].compactMap { $0 }
            views.append(contentsOf: explanationViews)
        }
        
        if !data.recommendation.isEmpty {
            let recommendationViews = [
                makeTitleLabel("AssistantResult.Recommendation".localized),
                makeHTMLTextLabel(data.recommendation)
            ]
            views.append(contentsOf: recommendationViews)
        }
        
        let actionsView = makeActionsView()
        views.append(actionsView)
        
        return views
    }
    
    func makeLanguageViews(response: TranslateResult) -> [UIView] {
        [
            makeTitleLabel("AssistantResult.Answer".localized),
            makeNormalTextLabel(response.translate),
            makeActionsView()
        ]
    }
    
    func makeTitleLabel(_ text: String) -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = text.attributed(with: titleAttrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func makeKatexWebView(_ katex: String) -> KatexWebView {
        KatexWebView(katex: katex) { [weak self] in
            self?.updateLayout()
        }
    }
    
    func makeNormalTextLabel(_ text: String) -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = text.attributed(with: normalAttrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func makeHTMLTextLabel(_ text: String) -> UILabel {
        let html: NSAttributedString = {
            let font = Fonts.Inter.regular(size: 16.scale)
            let htmlWithStyle = "<span style=\"font-family: \(font.fontName); font-style: regular; font-size: \(font.pointSize); line-height: \(22.scale)px;\">\(text)</span>"
            
            guard let data = htmlWithStyle.data(using: .utf8) else { return text.attributed(with: normalAttrs) }
            
            let attributedString = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            guard let attributedString else { return text.attributed(with: normalAttrs) }
            
            return attributedString
        }()
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = html
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.main200
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.heightAnchor.constraint(equalToConstant: 1.scale).isActive = true
        
        return view
    }
    
    func makeActionsView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        func makeActionButton(iconName: String) -> TapAreaButton {
            let button = TapAreaButton()
            button.setImage(UIImage(named: iconName), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            return button
        }
        
        let refreshButton = makeActionButton(iconName: "AssistantResult.Refresh")
        let copyButton = makeActionButton(iconName: "AssistantResult.Copy")
        
        NSLayoutConstraint.activate([
            refreshButton.widthAnchor.constraint(equalToConstant: 24.scale),
            refreshButton.heightAnchor.constraint(equalToConstant: 24.scale),
            refreshButton.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -16.scale),
            refreshButton.topAnchor.constraint(equalTo: view.topAnchor),
            refreshButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            copyButton.widthAnchor.constraint(equalToConstant: 24.scale),
            copyButton.heightAnchor.constraint(equalToConstant: 24.scale),
            copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            copyButton.topAnchor.constraint(equalTo: view.topAnchor),
            copyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        
        return view
    }
    
    func updateLayout() {
        layoutIfNeeded()
        
        guard let tableView = superview as? UITableView else {
            return
        }
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}

// MARK: Make constraints
private extension ARTAnswerCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16.scale),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16.scale),
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension ARTAnswerCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 16.scale
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.borderColor = Appearance.main200.cgColor
        view.layer.borderWidth = 1.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeStackView() -> UIStackView {
        let view = UIStackView()
        view.backgroundColor = UIColor.clear
        view.axis = .vertical
        view.spacing = 16.scale
        view.distribution = .fill
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
