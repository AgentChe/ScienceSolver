//
//  AssistantMainTableView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class AssistantMainTableView: UITableView {
    private lazy var elements = [AssistantMainTableElement]()
    
    private lazy var inputCell = AMInputCell(style: .default, reuseIdentifier: nil)
    
    private lazy var didTapHistoryTrigger = PublishRelay<Void>()
    private lazy var didSelectHistoryItemTrigger = PublishRelay<AssistantHistoryItem>()
    private lazy var didTapSelectAdditionalDataTrigger = PublishRelay<Void>()
    private lazy var didTapCalculatorTrigger = PublishRelay<Void>()
    private lazy var didTapCameraTrigger = PublishRelay<Void>()
    private lazy var didChangeWritingModeTrigger = PublishRelay<WritingMode>()
    private lazy var didChangeTextTrigger = PublishRelay<String>()
    private lazy var willBeginDraggingTrigger = PublishRelay<Void>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AssistantMainTableView {
    func setup(elements: [AssistantMainTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    func setup(assistant: AssistantsCollectionElement.Assistant) {
        inputCell.setup(assistant: assistant)
    }
    
    func setup(writingMode: WritingMode) {
        inputCell.setup(writingMode: writingMode)
    }
    
    func setup(additionalDataEntity: AMSelectEntityButton.Entity?) {
        inputCell.setup(additionalDataEntity: additionalDataEntity)
    }
    
    func resetInput() {
        inputCell.resetInput()
    }
    
    var didTapHistory: Signal<Void> {
        didTapHistoryTrigger.asSignal()
    }
    
    var didSelectHistoryItem: Signal<AssistantHistoryItem> {
        didSelectHistoryItemTrigger.asSignal()
    }
    
    var didTapSelectAdditionalData: Signal<Void> {
        didTapSelectAdditionalDataTrigger.asSignal()
    }
    
    var didTapCalculator: Signal<Void> {
        didTapCalculatorTrigger.asSignal()
    }
    
    var didTapCamera: Signal<Void> {
        didTapCameraTrigger.asSignal()
    }
    
    var didChangeWritingMode: Signal<WritingMode> {
        didChangeWritingModeTrigger.asSignal()
    }
    
    var didChangeText: Signal<String> {
        didChangeTextTrigger.asSignal()
    }
    
    var willBeginDragging: Signal<Void> {
        willBeginDraggingTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension AssistantMainTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .input:
            return inputCell
        case .historyTitle:
            return dequeueReusableCell(withIdentifier: String(describing: AMHistoryTitleCell.self), for: indexPath)
        case .historyItem(let historyItem):
            switch historyItem.mode {
            case .image(let url):
                let cell = dequeueReusableCell(withIdentifier: String(describing: HistoryImageCell.self), for: indexPath) as! HistoryImageCell
                cell.setup(
                    assistantName: historyItem.assistantName,
                    imageUrl: url,
                    created: historyItem.created
                )
                return cell
            case .text(let content):
                let cell = dequeueReusableCell(withIdentifier: String(describing: HistoryTextCell.self), for: indexPath) as! HistoryTextCell
                cell.setup(
                    assistantName: historyItem.assistantName,
                    content: content,
                    created: historyItem.created
                )
                return cell
            }
        }
    }
}

// MARK: UITableViewDelegate
extension AssistantMainTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .historyTitle:
            didTapHistoryTrigger.accept(Void())
        case .historyItem(let element):
            didSelectHistoryItemTrigger.accept(element.item)
        default:
            return
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        willBeginDraggingTrigger.accept(Void())
    }
}

// MARK: Private
private extension AssistantMainTableView {
    func initialize() {
        register(AMHistoryTitleCell.self, forCellReuseIdentifier: String(describing: AMHistoryTitleCell.self))
        register(HistoryImageCell.self, forCellReuseIdentifier: String(describing: HistoryImageCell.self))
        register(HistoryTextCell.self, forCellReuseIdentifier: String(describing: HistoryTextCell.self))
        
        dataSource = self
        delegate = self
        
        inputCell.didTapSelectAdditionalData = { [weak self] in
            self?.didTapSelectAdditionalDataTrigger.accept(Void())
        }
        
        inputCell.didTapCalculator = { [weak self] in
            self?.didTapCalculatorTrigger.accept(Void())
        }
        
        inputCell.didTapCamera = { [weak self] in
            self?.didTapCameraTrigger.accept(Void())
        }
        
        inputCell.didChangeWritingMode = { [weak self] mode in
            self?.didChangeWritingModeTrigger.accept(mode)
        }
        
        inputCell.didEditing = { [weak self] text in
            self?.didChangeTextTrigger.accept(text)
        }
    }
}
