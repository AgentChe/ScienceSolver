//
//  HelpfulReasonsView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 22.02.2025.
//

import UIKit

final class HelpfulReasonsView: UIView {
    enum Relatively {
        case like, dislike
    }
    
    lazy var likeIconView = makeActionIconView()
    lazy var dislikeIconView = makeActionIconView()
    lazy var reason1Button = makeReasonButton(number: 1)
    lazy var reason2Button = makeReasonButton(number: 2)
    lazy var reason3Button = makeReasonButton(number: 3)
    lazy var reason4Button = makeReasonButton(number: 4)
    lazy var textField = makeTextField()
    lazy var submitButton = makeSubmitButton()
    
    private lazy var reasonsButtons = [
        reason1Button,
        reason2Button,
        reason3Button,
        reason4Button
    ]
    
    private let relatively: Relatively
    private let submit: () -> Void
    
    init(relatively: Relatively, submit: @escaping () -> Void) {
        self.relatively = relatively
        self.submit = submit
        
        super.init(frame: .zero)
        
        makeConstraints()
        initialize()
        checkEnableSubmit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITextFieldDelegate
extension HelpfulReasonsView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: Private
private extension HelpfulReasonsView {
    func initialize() {
        backgroundColor = UIColor.clear
        
        likeIconView.image = UIImage(named: relatively == .like ? "AssistantResult.Like.Selected" : "AssistantResult.Like")
        dislikeIconView.image = UIImage(named: relatively == .dislike ? "AssistantResult.Dislike.Selected" : "AssistantResult.Dislike")
    }
    
    @objc
    func reasonTapped(sender: UIButton) {
        guard let reasonButton = sender as? HelpfulReasonButton else { return }
        
        reasonsButtons.forEach { $0.marked = $0 === reasonButton }
        
        checkEnableSubmit()
    }
    
    @objc
    func submitTapped() {
        submit()
    }
    
    @objc
    func textFieldChanged() {
        checkEnableSubmit()
    }
    
    func checkEnableSubmit() {
        let enable: Bool = {
            guard reasonsButtons.contains(where: { $0.marked }) else { return false }
            
            if let otherMared = reasonsButtons.last?.marked, otherMared {
                return !(textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            
            return true
        }()
        
        submitButton.isEnabled = enable
        submitButton.alpha = enable ? 1 : 0.4
    }
}

// MARK: Make constraints
private extension HelpfulReasonsView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            likeIconView.widthAnchor.constraint(equalToConstant: 40.scale),
            likeIconView.heightAnchor.constraint(equalToConstant: 40.scale),
            likeIconView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -4.scale),
            likeIconView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dislikeIconView.widthAnchor.constraint(equalToConstant: 40.scale),
            dislikeIconView.heightAnchor.constraint(equalToConstant: 40.scale),
            dislikeIconView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 4.scale),
            dislikeIconView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            reason1Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            reason1Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            reason1Button.topAnchor.constraint(equalTo: topAnchor, constant: 56.scale)
        ])
        
        NSLayoutConstraint.activate([
            reason2Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            reason2Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            reason2Button.topAnchor.constraint(equalTo: reason1Button.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            reason3Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            reason3Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            reason3Button.topAnchor.constraint(equalTo: reason2Button.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            reason4Button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            reason4Button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            reason4Button.topAnchor.constraint(equalTo: reason3Button.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textField.topAnchor.constraint(equalTo: reason4Button.bottomAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            submitButton.heightAnchor.constraint(equalToConstant: 50.scale),
            submitButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16.scale),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension HelpfulReasonsView {
    func makeActionIconView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeReasonButton(number: Int) -> HelpfulReasonButton {
        let relativelyDomain: String = {
            switch relatively {
            case .like:
                return "Like"
            case .dislike:
                return "Dislike"
            }
        }()
        
        let view = HelpfulReasonButton(text: "AssistantResult.Helpful.Reason.\(relativelyDomain).\(number)".localized)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(reasonTapped(sender:)), for: .touchUpInside)
        addSubview(view)
        return view
    }
    
    func makeTextField() -> PaddingTextField {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.regular(size: 14.scale))
            .lineHeight(17.scale)
            .textAlignment(.left)
        let placeholderAttrs = TextAttributes()
            .textColor(Appearance.mono200.withAlphaComponent(0.4))
            .font(Fonts.Inter.regular(size: 14.scale))
            .lineHeight(17.scale)
            .textAlignment(.left)
        
        let placeholder: String = {
            switch relatively {
            case .like:
                return "AssistantResult.Helpful.Reason.Like.TextPlaceholder"
            case .dislike:
                return "AssistantResult.Helpful.Reason.Dislike.TextPlaceholder"
            }
        }()
        
        let view = PaddingTextField()
        view.delegate = self
        view.textPadding = UIEdgeInsets(value: 16.scale)
        view.backgroundColor = UIColor.clear
        view.defaultTextAttributes = attrs.dictionary
        view.attributedPlaceholder = placeholder.localized.attributed(with: placeholderAttrs)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16.scale
        view.layer.borderWidth = 1.scale
        view.layer.borderColor = Appearance.main200.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        addSubview(view)
        return view
    }
    
    func makeSubmitButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(Appearance.mono100)
            .font(Fonts.Inter.medium(size: 16.scale))
        
        let view = UIButton()
        view.setAttributedTitle("AssistantResult.Helpful.Reason.Submit".localized.attributed(with: attrs), for: .normal)
        view.layer.cornerRadius = 16.scale
        view.backgroundColor = Appearance.main300
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        addSubview(view)
        return view
    }
}
