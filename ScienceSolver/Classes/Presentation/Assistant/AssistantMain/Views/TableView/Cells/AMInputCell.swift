//
//  AMInputCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AMInputCell: UITableViewCell {
    var didEditing: ((String) -> Void)?
    var didTapSelectAdditionalData: (() -> Void)?
    var didTapCalculator: (() -> Void)?
    var didTapCamera: (() -> Void)?
    var didChangeWritingMode: ((WritingMode) -> Void)?
    
    lazy var container = makeContainer()
    lazy var writingModeView = makeWritingModeView()
    lazy var textView = makeTextView()
    lazy var bottomView = makeBottomView()
    
    private lazy var textViewTopConstraint = NSLayoutConstraint()
    
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
extension AMInputCell {
    func setup(assistant: AssistantsCollectionElement.Assistant) {
        writingModeView.isHidden = assistant != .writing
        bottomView.calculatorButton.isHidden = assistant != .math
        
        textViewTopConstraint.isActive = false
        textViewTopConstraint.constant = assistant == .writing ? 75.scale : 16.scale
        textViewTopConstraint.isActive = true
        
        layoutIfNeeded()
    }
    
    func setup(writingMode: WritingMode) {
        writingModeView.mode = writingMode
    }
    
    func setup(additionalDataEntity: AMSelectEntityButton.Entity?) {
        bottomView.selectEntityButton.entity = additionalDataEntity
    }
    
    func resetInput() {
        textView.textView.text = ""
        didEditing?("")
    }
}

// MARK: Private
private extension AMInputCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
        
        bottomView.selectEntityButton.addTarget(self, action: #selector(selectAdditionalDataTapped), for: .touchUpInside)
        bottomView.calculatorButton.addTarget(self, action: #selector(calculatorTapped), for: .touchUpInside)
        bottomView.cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        
        writingModeView.didChangeMode = { [weak self] mode in
            self?.didChangeWritingMode?(mode)
        }
        
        textView.didEditing = { [weak self] text in
            self?.didEditing?(text)
        }
    }
    
    @objc 
    func selectAdditionalDataTapped() {
        didTapSelectAdditionalData?()
    }
    
    @objc
    func calculatorTapped() {
        didTapCalculator?()
    }
    
    @objc
    func cameraTapped() {
        didTapCamera?()
    }
}

// MARK: Make constraints
private extension AMInputCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 296.scale)
        ])
        
        NSLayoutConstraint.activate([
            writingModeView.widthAnchor.constraint(equalToConstant: 172.scale),
            writingModeView.heightAnchor.constraint(equalToConstant: 43.scale),
            writingModeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            writingModeView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        textViewTopConstraint = textView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -16.scale),
            textViewTopConstraint
        ])
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16.scale),
            bottomView.heightAnchor.constraint(equalToConstant: 31.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AMInputCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 16.scale
        view.layer.borderColor = Appearance.main200.cgColor
        view.layer.borderWidth = 1.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeWritingModeView() -> AssistantCameraWritingModeView {
        let view = AssistantCameraWritingModeView(style: .manual)
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeTextView() -> AMTextView {
        let view = AMTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeBottomView() -> AMInputBottomView {
        let view = AMInputBottomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
}
