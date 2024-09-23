//
//  AssistantResultTableView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class AssistantResultTableView: UITableView {
    private lazy var elements = [AssistantResultTableElement]()
    
    private lazy var didTapLikeTrigger = PublishRelay<Void>()
    private lazy var didTapDislikeTrigger = PublishRelay<Void>()
    private lazy var didTapRefreshTrigger = PublishRelay<Void>()
    private lazy var didTapCopyTrigger = PublishRelay<AssistantResultTableAnswerElement>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AssistantResultTableView {
    func setup(elements: [AssistantResultTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapLike: Signal<Void> {
        didTapLikeTrigger.asSignal()
    }
    
    var didTapDislike: Signal<Void> {
        didTapDislikeTrigger.asSignal()
    }
    
    var didTapRefresh: Signal<Void> {
        didTapRefreshTrigger.asSignal()
    }
    
    var didTapCopy: Signal<AssistantResultTableAnswerElement> {
        didTapCopyTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension AssistantResultTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .questionImageUrl(let url):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ARTQuestionImageCell.self), for: indexPath) as! ARTQuestionImageCell
            cell.setup(url: url)
            return cell
        case .questionImage(let image):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ARTQuestionImageCell.self), for: indexPath) as! ARTQuestionImageCell
            cell.setup(image: image)
            return cell
        case .questionText(let text):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ARTQuestionTextCell.self), for: indexPath) as! ARTQuestionTextCell
            cell.setup()
            return cell
        case .loading:
            return dequeueReusableCell(withIdentifier: String(describing: ARTLoadingCell.self), for: indexPath)
        case .answer(let answer):
            let cell = dequeueReusableCell(withIdentifier: String(describing: ARTAnswerCell.self), for: indexPath) as! ARTAnswerCell
            cell.setup(answer: answer)
            cell.didTapRefresh = { [weak self] in
                self?.didTapRefreshTrigger.accept(Void())
            }
            cell.didTapCopy = { [weak self] answer in
                self?.didTapCopyTrigger.accept(answer)
            }
            return cell
        case .helpful:
            let cell = dequeueReusableCell(withIdentifier: String(describing: ARTHelpfulCell.self), for: indexPath) as! ARTHelpfulCell
            cell.didTapLike = { [weak self] in
                self?.didTapLikeTrigger.accept(Void())
            }
            cell.didTapDislike = { [weak self] in
                self?.didTapDislikeTrigger.accept(Void())
            }
            return cell
        }
    }
}

// MARK: UITableViewDelegate
extension AssistantResultTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: Private
private extension AssistantResultTableView {
    func initialize() {
        register(ARTQuestionImageCell.self, forCellReuseIdentifier: String(describing: ARTQuestionImageCell.self))
        register(ARTQuestionTextCell.self, forCellReuseIdentifier: String(describing: ARTQuestionTextCell.self))
        register(ARTLoadingCell.self, forCellReuseIdentifier: String(describing: ARTLoadingCell.self))
        register(ARTAnswerCell.self, forCellReuseIdentifier: String(describing: ARTAnswerCell.self))
        register(ARTHelpfulCell.self, forCellReuseIdentifier: String(describing: ARTHelpfulCell.self))
        
        dataSource = self
        delegate = self
    }
}
