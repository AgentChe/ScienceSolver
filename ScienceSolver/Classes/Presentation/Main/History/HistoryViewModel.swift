//
//  HistoryViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import RxSwift
import RxCocoa

final class HistoryViewModel {
    enum Route {
        case back, select(AssistantHistoryItem)
    }
    
    private lazy var firstPageActivity = RxActivityIndicator()
    private lazy var paginationActivity = RxActivityIndicator()
    
    private lazy var assistantManager = AssistantManager()
}

// MARK: Public
extension HistoryViewModel {
    struct Input {
        let didTapBack: Signal<Void>
        let didSelect: Signal<AssistantHistoryItem>
        let didScrollToBottom: Signal<Void>
    }
    
    struct Output {
        let elements: Driver<[HistoryTableElement]>
        let route: Driver<Route>
        let firstPageActivity: Driver<Bool>
        let paginationActivity: Driver<Bool>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(didScrollToBottom: input.didScrollToBottom),
            route: makeRoute(
                didTapBack: input.didTapBack,
                didSelect: input.didSelect
            ),
            firstPageActivity: firstPageActivity.asDriver(),
            paginationActivity: paginationActivity.asDriver()
        )
    }
}

// MARK: Private
private extension HistoryViewModel {
    func makeElements(didScrollToBottom: Signal<Void>) -> Driver<[HistoryTableElement]> {
        var lastPage: AssistantHistoryPage?
        
        func fetch(page: Int) -> Driver<AssistantHistoryPage> {
            assistantManager
                .history(page: page)
                .trackActivity(page == 1 ? firstPageActivity : paginationActivity)
                .compactMap { $0 }
                .asDriver(onErrorDriveWith: .never())
                .do(onNext: { page in
                    lastPage = page
                })
        }
        
        let firstPage = fetch(page: 1)
        let downloadedPage = firstPage
            .flatMapLatest { firstPage -> Driver<AssistantHistoryPage> in
                didScrollToBottom
                    .compactMap { lastPage }
                    .filter { ($0.page.nextPage <= $0.page.total) && ($0.page.current != $0.page.total) }
                    .flatMapFirst { lastPage -> Driver<AssistantHistoryPage> in
                        fetch(page: lastPage.page.nextPage)
                    }
                    .startWith(firstPage)
            }
        
        return downloadedPage
            .map { page -> [HistoryTableElement] in
                page.history.map { item -> HistoryTableElement in
                    HistoryTableElement(item: item)
                }
            }
    }
    
    func makeRoute(
        didTapBack: Signal<Void>, 
        didSelect: Signal<AssistantHistoryItem>
    ) -> Driver<Route> {
        let back = didTapBack
            .map { Route.back }
            .asDriver(onErrorDriveWith: .never())
        
        let select = didSelect
            .map { Route.select($0) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(back, select)
    }
}
