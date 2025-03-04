//
//  HistoryTableView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class HistoryTableView: UITableView {
    lazy var elements = [HistoryTableElement]()
    
    private lazy var didScrollToBottomTrigger = PublishRelay<Void>()
    private lazy var didSelectTrigger = PublishRelay<AssistantHistoryItem>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension HistoryTableView {
    func setup(elements: [HistoryTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    func reset() {
        elements = []
        
        reloadData()
    }
    
    func add(elements: [HistoryTableElement]) {
        self.elements.append(contentsOf: elements)
        
        reloadData()
    }
    
    var didScrollToBottom: Signal<Void> {
        didScrollToBottomTrigger.asSignal()
    }
    
    var didSelect: Signal<AssistantHistoryItem> {
        didSelectTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension HistoryTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        switch element.mode {
        case .image(let url):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HistoryImageCell.self), for: indexPath) as! HistoryImageCell
            cell.setup(
                assistantName: element.assistantName,
                imageUrl: url,
                created: element.created
            )
            return cell
        case .text(let content):
            let cell = dequeueReusableCell(withIdentifier: String(describing: HistoryTextCell.self), for: indexPath) as! HistoryTextCell
            cell.setup(
                assistantName: element.assistantName,
                content: content,
                created: element.created
            )
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension HistoryTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard (elements.count - 1) == indexPath.row else { return }
        didScrollToBottomTrigger.accept(Void())
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectTrigger.accept(elements[indexPath.row].item)
    }
}

// MARK: Private
private extension HistoryTableView {
    func initialize() {
        register(HistoryImageCell.self, forCellReuseIdentifier: String(describing: HistoryImageCell.self))
        register(HistoryTextCell.self, forCellReuseIdentifier: String(describing: HistoryTextCell.self))
        
        dataSource = self
        delegate = self
    }
}
