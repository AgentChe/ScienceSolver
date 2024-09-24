//
//  AssistantMainViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantMainViewModel {
    enum Route {
        case history
        case historyItem(AssistantHistoryItem)
        case selectWritingStyle(WritingMode, WritingStyle)
        case selectLanguage(Language)
        case assistantRecognize(AssistantsCollectionElement.Assistant)
        case calculator
        case analyze(AssistantMainViewController.DataForManualAnalyze)
    }
    
    private lazy var assistantManager = AssistantManager()
}

// MARK: Public
extension AssistantMainViewModel {
    struct Input {
        let didSelectAssistant: Signal<AssistantsCollectionElement.Assistant>
        let didTapHistory: Signal<Void>
        let didSelectHistoryItem: Signal<AssistantHistoryItem>
        let didSelectWritingStyle: Signal<WritingStyle>
        let didSelectLanguage: Signal<Language>
        let didTapSelectAdditionalData: Signal<Void>
        let didChangeWritingMode: Signal<WritingMode>
        let didTapCamera: Signal<Void>
        let didTapCalculator: Signal<Void>
        let didTapDone: Signal<String>
    }
    
    struct Output {
        let assistantsElements: Driver<[AssistantsCollectionElement]>
        let elements: Driver<[AssistantMainTableElement]>
        let route: Driver<Route>
        let currentAssistant: Driver<AssistantsCollectionElement.Assistant>
        let writingMode: Driver<WritingMode>
        let additionalDataEntity: Driver<AMSelectEntityButton.Entity?>
    }
    
    func configure(input: Input) -> Output {
        let currentAssistant = makeCurrentAssistant(didSelectAssistant: input.didSelectAssistant)
        let currentWritingMode = makeWritingMode(didChangeWritingMode: input.didChangeWritingMode)
        let additionalDataEntity = makeSelectEntity(
            currentAssistant: currentAssistant,
            didSelectWritingStyle: input.didSelectWritingStyle,
            didSelectLanguage: input.didSelectLanguage,
            languages: makeLanguages()
        )
        
        return Output(
            assistantsElements: makeAssistantsElements(),
            elements: makeElements(history: makeHistoryElements()),
            route: makeRoute(
                didTapHistory: input.didTapHistory,
                didSelectHistoryItem: input.didSelectHistoryItem,
                didTapCamera: input.didTapCamera,
                currentAssistant: currentAssistant,
                didTapCalculator: input.didTapCalculator,
                didTapSelectAdditionalData: input.didTapSelectAdditionalData,
                selectedAdditionalDataEntity: additionalDataEntity,
                currentWritingMode: currentWritingMode,
                didTapDone: input.didTapDone
            ),
            currentAssistant: currentAssistant,
            writingMode: currentWritingMode,
            additionalDataEntity: additionalDataEntity
        )
    }
}

// MARK: Private
private extension AssistantMainViewModel {
    func makeAssistantsElements() -> Driver<[AssistantsCollectionElement]> {
        Single<[AssistantsCollectionElement]>
            .create { single in
                let assistants = [
                    AssistantsCollectionElement(assistant: .math, style: .whiteBlack, marked: true),
                    AssistantsCollectionElement(assistant: .physics, style: .whiteBlack, marked: false),
                    AssistantsCollectionElement(assistant: .biology, style: .whiteBlack, marked: false),
                    AssistantsCollectionElement(assistant: .chemistry, style: .whiteBlack, marked: false),
                    AssistantsCollectionElement(assistant: .writing, style: .whiteBlack, marked: false),
                    AssistantsCollectionElement(assistant: .language, style: .whiteBlack, marked: false)
                ]
                single(.success(assistants))
                
                return Disposables.create()
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func makeElements(history: Driver<[AssistantMainTableElement]>) -> Driver<[AssistantMainTableElement]> {
        history
            .map { history -> [AssistantMainTableElement] in
                var result: [AssistantMainTableElement] = [.input]
                
                if !history.isEmpty {
                    result.append(.historyTitle)
                    result.append(contentsOf: history)
                }
                
                return result
            }
            .startWith([.input])
    }
    
    func makeHistoryElements() -> Driver<[AssistantMainTableElement]> {
        assistantManager
            .history(page: 1)
            .map { $0?.history ?? [] }
            .asDriver(onErrorJustReturn: [])
            .map { $0.map { HistoryTableElement(item: $0) } }
            .map { Array($0.prefix(3)) }
            .map { $0.map { AssistantMainTableElement.historyItem($0) } }
    }
    
    func makeRoute(
        didTapHistory: Signal<Void>, 
        didSelectHistoryItem: Signal<AssistantHistoryItem>,
        didTapCamera: Signal<Void>,
        currentAssistant: Driver<AssistantsCollectionElement.Assistant>,
        didTapCalculator: Signal<Void>,
        didTapSelectAdditionalData: Signal<Void>,
        selectedAdditionalDataEntity: Driver<AMSelectEntityButton.Entity?>,
        currentWritingMode: Driver<WritingMode>,
        didTapDone: Signal<String>
    ) -> Driver<Route> {
        let history = didTapHistory
            .map { Route.history }
            .asDriver(onErrorDriveWith: .never())
        
        let historyItem = didSelectHistoryItem
            .map { Route.historyItem($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let recognize = didTapCamera
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentAssistant)
            .map { Route.assistantRecognize($0) }
        
        let calculator = didTapCalculator
            .asDriver(onErrorDriveWith: .never())
            .map { Route.calculator }
        
        let selectWritingStyle = didTapSelectAdditionalData
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedAdditionalDataEntity)
            .compactMap { $0?.writingStyle }
            .withLatestFrom(currentWritingMode) { ($0, $1) }
            .map { args -> Route in
                let (writingStyle, writingMode) = args
                
                return Route.selectWritingStyle(writingMode, writingStyle)
            }
        
        let selectLanguage = didTapSelectAdditionalData
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(selectedAdditionalDataEntity)
            .compactMap { $0?.language }
            .map { Route.selectLanguage($0) }
        
        let analyzeOnlyText = didTapDone
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentAssistant) { ($0, $1) }
            .compactMap { text, assistant -> AssistantMainViewController.DataForManualAnalyze? in
                switch assistant {
                case .math:
                    return .math(text)
                case .physics:
                    return .physics(text)
                case .biology:
                    return .biology(text)
                case .chemistry:
                    return .chemistry(text)
                case .writing, .language:
                    return nil
                }
            }
            .map { Route.analyze($0) }
        
        let analyzeWritingMode = didTapDone
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentAssistant) { ($0, $1) }
            .filter { $0.1.isWriting }
            .withLatestFrom(selectedAdditionalDataEntity) { ($0.0, $1?.writingStyle) }
            .withLatestFrom(currentWritingMode) { ($0.0, $0.1, $1) }
            .compactMap { text, style, mode -> AssistantMainViewController.DataForManualAnalyze? in
                guard let style else { return nil }
                
                return .writing(text, mode, style)
            }
            .map { Route.analyze($0) }
        
        let translate = didTapDone
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(currentAssistant) { ($0, $1) }
            .filter { $0.1.isLanguage }
            .withLatestFrom(selectedAdditionalDataEntity) { ($0.0, $1?.language) }
            .compactMap { text, language -> AssistantMainViewController.DataForManualAnalyze? in
                guard let language else { return nil }
                
                return .language(text, language)
            }
            .map { Route.analyze($0) }
        
        return Driver
            .merge(history, historyItem, recognize, calculator, selectWritingStyle, selectLanguage, analyzeOnlyText, analyzeWritingMode, translate)
    }
    
    func makeCurrentAssistant(didSelectAssistant: Signal<AssistantsCollectionElement.Assistant>) -> Driver<AssistantsCollectionElement.Assistant> {
        didSelectAssistant
            .startWith(.math)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeWritingMode(didChangeWritingMode: Signal<WritingMode>) -> Driver<WritingMode> {
        didChangeWritingMode
            .startWith(.essay)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeSelectEntity(
        currentAssistant: Driver<AssistantsCollectionElement.Assistant>,
        didSelectWritingStyle: Signal<WritingStyle>,
        didSelectLanguage: Signal<Language>,
        languages: Driver<[Language]>
    ) -> Driver<AMSelectEntityButton.Entity?> {
        let none = currentAssistant
            .filter { $0.notRequiredAdditionalData }
            .map { assistant -> AMSelectEntityButton.Entity? in nil }
        
        let writingStyle: Driver<AMSelectEntityButton.Entity?> = {
            let lastWritingStyle = didSelectWritingStyle
                .asDriver(onErrorDriveWith: .never())
                .startWith(.expository)
            
            let moveToAssistant = currentAssistant
                .filter { $0.isWriting }
                .withLatestFrom(lastWritingStyle)
            
            let changedWritingStyle = lastWritingStyle
                .withLatestFrom(currentAssistant) { ($0, $1) }
                .compactMap { writingStyle, assistant -> WritingStyle? in
                    assistant.isWriting ? writingStyle : nil
                }
            
            return Driver
                .merge(moveToAssistant, changedWritingStyle)
                .map { writingStyle -> AMSelectEntityButton.Entity? in .writingStyle(writingStyle) }
        }()
        
        let language: Driver<AMSelectEntityButton.Entity?> = {
            let initialLanguage = languages
                .compactMap { $0.first }
                .asDriver(onErrorDriveWith: .never())
            let lastLanguage = Driver
                .merge(
                    initialLanguage,
                    didSelectLanguage.asDriver(onErrorDriveWith: .never())
                )
            
            let moveToAssistant = currentAssistant
                .filter { $0.isLanguage }
                .withLatestFrom(lastLanguage)
            
            let changedLanguage = lastLanguage
                .withLatestFrom(currentAssistant) { ($0, $1) }
                .compactMap { language, assistant -> Language? in
                    assistant.isLanguage ? language : nil
                }
            
            return Driver
                .merge(moveToAssistant, changedLanguage)
                .map { language -> AMSelectEntityButton.Entity? in .language(language) }
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
private extension AssistantsCollectionElement.Assistant {
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
private extension AMSelectEntityButton.Entity {
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
