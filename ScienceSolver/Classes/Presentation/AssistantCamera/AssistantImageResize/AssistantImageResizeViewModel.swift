//
//  AssistantImageResizeViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantImageResizeViewModel {
    enum Route {
        case cancel, done
    }
    
    private let fromCamera: Driver<AssistantCameraViewController.Result>
    
    init(fromCamera: AssistantCameraViewController.Result) {
        self.fromCamera = BehaviorRelay(value: fromCamera).asDriver()
    }
}

// MARK: Public
extension AssistantImageResizeViewModel {
    struct Input {
        let didTapCancel: Signal<Void>
        let didTapDone: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let originalImage: Driver<UIImage>
    }
    
    func configure(input: Input) -> Output {
        Output(
            route: makeRoute(
                didTapCancel: input.didTapCancel,
                didTapDone: input.didTapDone
            ),
            originalImage: makeOriginalImage()
        )
    }
}

// MARK: Private
private extension AssistantImageResizeViewModel {
    func makeRoute(
        didTapCancel: Signal<Void>,
        didTapDone: Signal<Void>
    ) -> Driver<Route> {
        let cancel = didTapCancel
            .map { Route.cancel }
            .asDriver(onErrorDriveWith: .never())
        
        let done = didTapDone
            .map { Route.done }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(cancel, done)
    }
    
    func makeOriginalImage() -> Driver<UIImage> {
        fromCamera
            .map { $0.image }
            .asDriver(onErrorDriveWith: .never())
    }
}
