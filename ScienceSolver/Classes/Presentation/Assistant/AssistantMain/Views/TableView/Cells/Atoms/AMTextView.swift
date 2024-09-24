//
//  AMTextView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AMTextView: UIView {
    var didTapDone: ((String) -> Void)?
    
    lazy var textView = makeTextView()
    lazy var placeholderLabel = makePlaceholderLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
        addToolBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITextViewDelegate
extension AMTextView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
}

// MARK: Private
private extension AMTextView {
    func initialize() {
        backgroundColor = UIColor.clear
    }
    
    func addToolBar() {
        let doneButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel".localized, style: .done, target: self, action: #selector(cancelTapped))
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = Appearance.main200
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.inputAccessoryView = toolBar
    }
    
    @objc
    func doneTapped() {
        textView.resignFirstResponder()
        
        didTapDone?(textView.text)
    }
    
    @objc
    func cancelTapped() {
        textView.resignFirstResponder()
    }
}

// MARK: Make constraints
private extension AMTextView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8.scale),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AMTextView {
    func makeTextView() -> UITextView {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.regular(size: 16.scale))
        
        let view = UITextView()
        view.backgroundColor = UIColor.clear
        view.showsHorizontalScrollIndicator = false
        view.textContainerInset = UIEdgeInsets(vertical: 8.scale, horizontal: 16.scale)
        view.delegate = self
        view.typingAttributes = attrs.dictionary
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePlaceholderLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200.withAlphaComponent(0.4))
            .font(Fonts.Inter.regular(size: 16.scale))
            .lineHeight(22.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "AssistantMain.Input.Placeholder".localized.attributed(with: attrs)
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
