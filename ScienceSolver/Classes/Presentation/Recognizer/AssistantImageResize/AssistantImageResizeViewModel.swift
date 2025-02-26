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
        case cancel
        case selectWritingStyle(WritingMode, WritingStyle)
        case selectLanguage(Language)
    }
    
    enum Action {
        case crop
        case error
        case result(AssistantImageResizeViewController.Result)
    }
    
    private let fromCamera: Driver<AssistantCameraViewController.Result>
    
    private lazy var assistantManager = AssistantManager()
    
    init(fromCamera: AssistantCameraViewController.Result) {
        self.fromCamera = BehaviorRelay(value: fromCamera).asDriver()
    }
}

// MARK: Public
extension AssistantImageResizeViewModel {
    struct Input {
        let didTapCancel: Signal<Void>
        let didTapDone: Signal<Void>
        let didCroppedImage: Signal<UIImage>
        let didSelectWritingStyle: Signal<WritingStyle>
        let didSelectLanguage: Signal<Language>
        let didTapSelectAdditionalData: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let action: Driver<Action>
        let originalImage: Driver<UIImage>
        let selectedAdditionalDataEntity: Driver<AIRSelectEntityButton.Entity?>
    }
    
    func configure(input: Input) -> Output {
        let languages = makeLanguages()
        let selectedAdditionalDataEntity = makeSelectEntity(
            didSelectWritingStyle: input.didSelectWritingStyle,
            didSelectLanguage: input.didSelectLanguage,
            languages: languages
        )
        
        return Output(
            route: makeRoute(
                didTapCancel: input.didTapCancel,
                didTapSelectAdditionalData: input.didTapSelectAdditionalData,
                selectedAdditionalDataEntity: selectedAdditionalDataEntity
            ),
            action: makeAction(
                didTapDone: input.didTapDone,
                croppedImage: input.didCroppedImage,
                selectedAdditionalDataEntity: selectedAdditionalDataEntity
            ),
            originalImage: makeOriginalImage(),
            selectedAdditionalDataEntity: selectedAdditionalDataEntity
        )
    }
}

// MARK: Private
private extension AssistantImageResizeViewModel {
    func makeRoute(
        didTapCancel: Signal<Void>,
        didTapSelectAdditionalData: Signal<Void>,
        selectedAdditionalDataEntity: Driver<AIRSelectEntityButton.Entity?>
    ) -> Driver<Route> {
        let cancel = didTapCancel
            .map { Route.cancel }
            .asDriver(onErrorDriveWith: .never())
        
        let selectWritingStyle = didTapSelectAdditionalData
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedAdditionalDataEntity)
            .compactMap { $0?.writingStyle }
            .withLatestFrom(fromCamera) { ($0, $1.assistant) }
            .compactMap { args -> Route? in
                let (writingStyle, assistant) = args
                
                let writingMode: WritingMode? = {
                    switch assistant {
                    case .writing(let mode):
                        return mode
                    default:
                        return nil
                    }
                }()
                
                guard let writingMode else { return nil }
                
                return Route.selectWritingStyle(writingMode, writingStyle)
            }
        
        let selectLanguage = didTapSelectAdditionalData
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedAdditionalDataEntity)
            .compactMap { $0?.language }
            .map { language -> Route in
                .selectLanguage(language)
            }
        
        return Driver
            .merge(cancel, selectWritingStyle, selectLanguage)
    }
    
    func makeAction(
        didTapDone: Signal<Void>,
        croppedImage: Signal<UIImage>,
        selectedAdditionalDataEntity: Driver<AIRSelectEntityButton.Entity?>
    ) -> Driver<Action> {
        let crop = didTapDone
            .map { Action.crop }
            .asDriver(onErrorDriveWith: .never())
        
        let errorOrResult = croppedImage
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(fromCamera) { ($1, $0) }
            .withLatestFrom(selectedAdditionalDataEntity) { ($0.0, $0.1, $1) }
            .flatMapLatest { [weak self] args -> Driver<Action> in
                guard let self else { return .never() }
                
                let (input, image, additionalInfo) = args
                
                switch input.assistant {
                case .math:
                    return assistantManager
                        .analyze(image: image, assistantType: .math)
                        .asDriver(onErrorJustReturn: nil)
                        .map { result -> Action in
                            guard let result else { return .error }
                            return .result(.init(croppedImage: image, assistant: .math(result)))
                        }
                case .physics:
                    return assistantManager
                        .analyze(image: image, assistantType: .physics)
                        .asDriver(onErrorJustReturn: nil)
                        .map { result -> Action in
                            guard let result else { return .error }
                            return .result(.init(croppedImage: image, assistant: .physics(result)))
                        }
                case .biology:
                    return assistantManager
                        .analyze(image: image, assistantType: .biology)
                        .asDriver(onErrorJustReturn: nil)
                        .map { result -> Action in
                            guard let result else { return .error }
                            return .result(.init(croppedImage: image, assistant: .biology(result)))
                        }
                case .chemistry:
                    return assistantManager
                        .analyze(image: image, assistantType: .chemistry)
                        .asDriver(onErrorJustReturn: nil)
                        .map { result -> Action in
                            guard let result else { return .error }
                            return .result(.init(croppedImage: image, assistant: .chemistry(result)))
                        }
                case .writing(let mode):
                    guard let writingStyle = additionalInfo?.writingStyle else {
                        return .just(.error)
                    }
                    
                    return assistantManager
                        .analyzeWriting(image: image, mode: mode, style: writingStyle)
                        .asDriver(onErrorJustReturn: nil)
                        .map { result -> Action in
                            guard let result else { return .error }
                            return .result(.init(croppedImage: image, assistant: .writing(writingStyle, result)))
                        }
                case .language:
                    guard let language = additionalInfo?.language else {
                        return .just(.error)
                    }
                    
                    return assistantManager
                        .translate(image: image, languageCode: language.code)
                        .asDriver(onErrorJustReturn: nil)
                        .map { result -> Action in
                            guard let result else { return .error }
                            return .result(.init(croppedImage: image, assistant: .language(result)))
                        }
                }
            }
        
        return Driver
            .merge(crop, errorOrResult)
    }
    
    func makeOriginalImage() -> Driver<UIImage> {
        fromCamera
            .map { $0.image }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeSelectEntity(
        didSelectWritingStyle: Signal<WritingStyle>,
        didSelectLanguage: Signal<Language>,
        languages: Driver<[Language]>
    ) -> Driver<AIRSelectEntityButton.Entity?> {
        let none = fromCamera
            .filter { $0.assistant.notRequiredAdditionalData }
            .map { fromCamera -> AIRSelectEntityButton.Entity? in nil }
        
        let writingStyle: Driver<AIRSelectEntityButton.Entity?> = {
            let initial = fromCamera
                .compactMap { $0.assistant.isWriting ? WritingStyle.expository : nil }
                .asDriver(onErrorDriveWith: .never())
            
            let selected = didSelectWritingStyle
                .asDriver(onErrorDriveWith: .never())
            
            return Driver
                .merge(initial, selected)
                .map { AIRSelectEntityButton.Entity.writingStyle($0) }
        }()
        
        let language: Driver<AIRSelectEntityButton.Entity?> = {
            let initial = fromCamera
                .filter { $0.assistant.isLanguage }
                .flatMapLatest { [weak self] result -> Driver<Language> in
                    guard let self else { return .never() }
                    
                    return assistantManager
                        .obtainLanaguages(forceUpdate: false)
                        .compactMap { $0.first }
                        .asDriver(onErrorDriveWith: .never())
                }
            
            let selected = didSelectLanguage
                .asDriver(onErrorDriveWith: .never())
            
            return Driver
                .merge(initial, selected)
                .map { AIRSelectEntityButton.Entity.language($0) }
        }()
        
        return Driver
            .merge(none, writingStyle, language)
    }
    
    func makeLanguages() -> Driver<[Language]> {
        assistantManager
            .obtainLanaguages(forceUpdate: false)
            .asDriver(onErrorJustReturn: [])
    }
}

// MARK: Additional
private extension AssistantCameraViewController.Result.Assistant {
    var notRequiredAdditionalData: Bool {
        switch self {
        case .writing, .language:
            return false
        default:
            return true
        }
    }
    
    var isWriting: Bool {
        switch self {
        case .writing:
            return true
        default:
            return false
        }
    }
    
    var isLanguage: Bool {
        switch self {
        case .language:
            return true
        default:
            return false
        }
    }
}

// MARK: Additional
private extension AIRSelectEntityButton.Entity {
    var writingStyle: WritingStyle? {
        switch self {
        case .writingStyle(let style):
            return style
        default:
            return nil
        }
    }
    
    var language: Language? {
        switch self {
        case .language(let language):
            return language
        default:
            return nil
        }
    }
}
