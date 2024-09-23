//
//  AssistantCameraViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantCameraViewModel {
    enum Route {
        case dismiss, selectImageFromLibrary, requestPermissionInSettings
    }
    
    enum Action {
        case takePhoto
    }
    
    private let initialAssistant: Driver<AssistantsCollectionElement.Assistant?>
    
    init(assistant: AssistantsCollectionElement.Assistant?) {
        initialAssistant = BehaviorRelay(value: assistant).asDriver()
    }
}

// MARK: Public
extension AssistantCameraViewModel {
    struct Input {
        let didTapDismiss: Signal<Void>
        let didTapSelectImageFromLibrary: Signal<Void>
        let didSelect: Signal<AssistantsCollectionElement.Assistant>
        let didTapTakePhoto: Signal<Void>
        let didTapAllowAccess: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let elements: Driver<[AssistantsCollectionElement]>
        let writingModeHidden: Driver<Bool>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        let startAssistant = initialAssistant.map { $0 ?? .math }
        let currentAssistant = Driver.merge(startAssistant, input.didSelect.asDriver(onErrorDriveWith: .never()))
        
        return Output(
            route: makeRoute(
                didTapDismiss: input.didTapDismiss,
                didTapSelectImageFromLibrary: input.didTapSelectImageFromLibrary,
                didTapAllowAccess: input.didTapAllowAccess
            ),
            elements: makeElements(startAssistant: startAssistant),
            writingModeHidden: currentAssistant.map { $0 != .writing },
            action: makeAction(didTapTakePhoto: input.didTapTakePhoto)
        )
    }
}

// MARK: Private
private extension AssistantCameraViewModel {
    func makeRoute(
        didTapDismiss: Signal<Void>,
        didTapSelectImageFromLibrary: Signal<Void>,
        didTapAllowAccess: Signal<Void>
    ) -> Driver<Route> {
        let dismiss = didTapDismiss
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let selectImageFromLibrary = didTapSelectImageFromLibrary
            .map { Route.selectImageFromLibrary }
            .asDriver(onErrorDriveWith: .never())
        
        let requestPermissionInSettings = didTapAllowAccess
            .map { Route.requestPermissionInSettings }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(dismiss, selectImageFromLibrary, requestPermissionInSettings)
    }
    
    func makeElements(startAssistant: Driver<AssistantsCollectionElement.Assistant>) -> Driver<[AssistantsCollectionElement]> {
        startAssistant
            .map { startAssistant -> [AssistantsCollectionElement] in
                [
                    .init(assistant: .math, marked: startAssistant == .math),
                    .init(assistant: .physics, marked: startAssistant == .physics),
                    .init(assistant: .biology, marked: startAssistant == .biology),
                    .init(assistant: .chemistry, marked: startAssistant == .chemistry),
                    .init(assistant: .writing, marked: startAssistant == .writing),
                    .init(assistant: .language, marked: startAssistant == .language)
                ]
            }
    }
    
    func makeAction(didTapTakePhoto: Signal<Void>) -> Driver<Action> {
        let takePhoto = didTapTakePhoto
            .map { Action.takePhoto }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(takePhoto)
    }
}
