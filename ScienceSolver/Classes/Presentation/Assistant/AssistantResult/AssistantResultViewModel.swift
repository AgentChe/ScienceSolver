//
//  AssistantResultViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantResultViewModel {
    enum Route {
        case close
    }
    
    enum Action {
        case copy(String)
    }
    
    enum InputData {
        case recognized(AssistantRecognizerController.Result)
        case historyItem(AssistantHistoryItem)
        case manual(AssistantMainViewController.DataForManualAnalyze)
    }
    
    struct AssistantResult {
        enum Result {
            case math(MathAssistantResult)
            case physics(PhysicsAssistantResult)
            case biology(BiologyAssistantResult)
            case chemistry(ChemistryAssistantResult)
            case writing(WritingAssistantResult)
            case translate(TranslateResult)
        }
        
        let inputData: InputData
        let result: Result?
        
        init(
            inputData: InputData,
            result: Result? = nil
        ) {
            self.inputData = inputData
            self.result = result
        }
    }
    
    private lazy var assistantManager = AssistantManager()
    
    private let inputData: Driver<InputData>
    
    init(recognized: AssistantRecognizerController.Result) {
        inputData = BehaviorRelay(value: InputData.recognized(recognized)).asDriver()
    }
    
    init(historyItem: AssistantHistoryItem) {
        inputData = BehaviorRelay(value: InputData.historyItem(historyItem)).asDriver()
    }
    
    init(manual: AssistantMainViewController.DataForManualAnalyze) {
        inputData = BehaviorRelay(value: InputData.manual(manual)).asDriver()
    }
}

// MARK: Public
extension AssistantResultViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapRefresh: Signal<AssistantResult>
        let didTapCopy: Signal<AssistantResultTableAnswerElement>
        let didTapLike: Signal<AssistantResult>
        let didTapDislike: Signal<AssistantResult>
    }
    
    struct Output {
        let route: Driver<Route>
        let action: Driver<Action>
        let elements: Driver<[AssistantResultTableElement]>
        let currentResult: Driver<AssistantResult>
    }
    
    func configure(input: Input) -> Output {
        let currentResult = makeResult(
            inputData: inputData,
            didTapRefresh: input.didTapRefresh,
            didTapLike: input.didTapLike,
            didTapDislike: input.didTapDislike
        )
        
        return Output(
            route: makeRoute(didTapClose: input.didTapClose),
            action: makeAction(didTapCopy: input.didTapCopy),
            elements: makeElements(
                inputData: inputData,
                didTapRefresh: input.didTapRefresh,
                assistantResult: currentResult
            ),
            currentResult: currentResult
        )
    }
}

// MARK: Private
private extension AssistantResultViewModel {
    func makeRoute(didTapClose: Signal<Void>) -> Driver<Route> {
        let close = didTapClose
            .map { Route.close }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(close)
    }
    
    func makeElements(
        inputData: Driver<InputData>,
        didTapRefresh: Signal<AssistantResult>,
        assistantResult: Driver<AssistantResult>
    ) -> Driver<[AssistantResultTableElement]> {
        let initalElements = makeInitialElements(inputData: inputData)
        let refreshElements = makeRefreshElements(didTapRefresh: didTapRefresh)
        let resultElements = makeResultElements(assistantResult: assistantResult)
        return Driver.merge(initalElements, refreshElements, resultElements)
    }
    
    func makeInitialElements(inputData: Driver<InputData>) -> Driver<[AssistantResultTableElement]> {
        inputData
            .compactMap { inputData -> [AssistantResultTableElement]? in
                switch inputData {
                case .recognized(let recognized):
                    switch recognized.recognized.assistant {
                    case .math(let math):
                        return [.questionImageUrl(math.url), .loading ]
                    case .physics(let physics):
                        return [.questionImageUrl(physics.url), .loading]
                    case .biology(let biology):
                        return [.questionImageUrl(biology.url), .loading]
                    case .chemistry(let chemistry):
                        return [.questionImageUrl(chemistry.url), .loading]
                    case .writing(_, let writing):
                        return [.questionImageUrl(writing.url), .loading]
                    case .language(let translateResult):
                        return [.questionImage(recognized.recognized.croppedImage), .answer(.language(translateResult))]
                    }
                case .manual(let manual):
                    switch manual {
                    case .math(let text), .physics(let text), .biology(let text), .chemistry(let text):
                        return [.questionText(text), .loading]
                    case .writing(let text, _, _):
                        return [.questionText(text), .loading]
                    case .language(let text, _):
                        return [.questionText(text), .loading]
                    }
                case .historyItem:
                    return nil
                }
            }
    }
    
    func makeRefreshElements(didTapRefresh: Signal<AssistantResult>) -> Driver<[AssistantResultTableElement]> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .map { assistantResult -> [AssistantResultTableElement] in
                guard let result = assistantResult.result else { return [] }
                
                switch result {
                case .math(let mathResult):
                    return [
                        {
                            if let imageUrl = mathResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(mathResult.request.content)
                            }
                        }(),
                        .loading
                    ]
                case .physics(let physicsResult):
                    return [
                        {
                            if let imageUrl = physicsResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(physicsResult.request.content)
                            }
                        }(),
                        .loading
                    ]
                case .biology(let biologyResult):
                    return [
                        {
                            if let imageUrl = biologyResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(biologyResult.request.content)
                            }
                        }(),
                        .loading
                    ]
                case .chemistry(let chemistryResult):
                    return [
                        {
                            if let imageUrl = chemistryResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(chemistryResult.request.content)
                            }
                        }(),
                        .loading
                    ]
                case .writing(let writingResult):
                    return [
                        {
                            if let imageUrl = writingResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(writingResult.request.content)
                            }
                        }(),
                        .loading
                    ]
                case .translate:
                    var result = [AssistantResultTableElement]()
                    
                    let inputData = assistantResult.inputData
                    
                    let inputImage: UIImage? = {
                        switch inputData {
                        case .recognized(let recognized):
                            return recognized.recognized.croppedImage
                        case .historyItem:
                            return nil
                        case .manual:
                            return nil
                        }
                    }()
                    
                    let inputText: String? = {
                        switch inputData {
                        case .recognized:
                            return nil
                        case .historyItem:
                            return nil
                        case .manual(let manual):
                            switch manual {
                            case .math(let text), .physics(let text), .biology(let text), .chemistry(let text):
                                return text
                            case .writing(let text, _, _):
                                return text
                            case .language(let text, _):
                                return text
                            }
                        }
                    }()
                    
                    if let inputImage {
                        result.append(.questionImage(inputImage))
                    } else if let inputText {
                        result.append(.questionText(inputText))
                    }
                    
                    result.append(.loading)
                    
                    return result
                }
            }
    }
    
    func makeResultElements(assistantResult: Driver<AssistantResult>) -> Driver<[AssistantResultTableElement]> {
        assistantResult
            .map { assistantResult -> [AssistantResultTableElement] in
                guard let result = assistantResult.result else { return [] }
                
                switch result {
                case .math(let mathResult):
                    return [
                        { 
                            if let imageUrl = mathResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(mathResult.request.content)
                            }
                        }(),
                        .answer(.math(mathResult.response)),
                        (mathResult.helpful == nil) ? .helpful : nil
                    ].compactMap { $0 }
                case .physics(let physicsResult):
                    return [
                        {
                            if let imageUrl = physicsResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(physicsResult.request.content)
                            }
                        }(),
                        .answer(.physics(physicsResult.response)),
                        (physicsResult.helpful == nil) ? .helpful : nil
                    ].compactMap { $0 }
                case .biology(let biologyResult):
                    return [
                        {
                            if let imageUrl = biologyResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(biologyResult.request.content)
                            }
                        }(),
                        .answer(.biology(biologyResult.response)),
                        (biologyResult.helpful == nil) ? .helpful : nil
                    ].compactMap { $0 }
                case .chemistry(let chemistryResult):
                    return [
                        {
                            if let imageUrl = chemistryResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(chemistryResult.request.content)
                            }
                        }(),
                        .answer(.chemistry(chemistryResult.response)),
                        (chemistryResult.helpful == nil) ? .helpful : nil
                    ].compactMap { $0 }
                case .writing(let writingResult):
                    return [
                        {
                            if let imageUrl = writingResult.request.imageUrl {
                                return .questionImageUrl(imageUrl)
                            } else {
                                return .questionText(writingResult.request.content)
                            }
                        }(),
                        .answer(.writing(writingResult.response))
                    ].compactMap { $0 }
                case .translate(let translateResult):
                    var result = [AssistantResultTableElement]()
                    
                    let inputData = assistantResult.inputData
                    
                    let inputImage: UIImage? = {
                        switch inputData {
                        case .recognized(let recognized):
                            return recognized.recognized.croppedImage
                        case .historyItem:
                            return nil
                        case .manual:
                            return nil
                        }
                    }()
                    
                    let inputText: String? = {
                        switch inputData {
                        case .recognized:
                            return nil
                        case .historyItem:
                            return nil
                        case .manual(let manual):
                            switch manual {
                            case .math(let text), .physics(let text), .biology(let text), .chemistry(let text):
                                return text
                            case .writing(let text, _, _):
                                return text
                            case .language(let text, _):
                                return text
                            }
                        }
                    }()
                    
                    if let inputImage {
                        result.append(.questionImage(inputImage))
                    } else if let inputText {
                        result.append(.questionText(inputText))
                    }
                    
                    result.append(.answer(.language(translateResult)))
                    
                    return result
                }
            }
    }
    
    func makeResult(
        inputData: Driver<InputData>,
        didTapRefresh: Signal<AssistantResult>,
        didTapLike: Signal<AssistantResult>,
        didTapDislike: Signal<AssistantResult>
    ) -> Driver<AssistantResult> {
        let initialResult = makeInitialResult(inputData: inputData)
        let refreshResult = makeRefreshResult(didTapRefresh: didTapRefresh)
        let helpfulResult = makeHelpfulResult(
            didTapLike: didTapLike,
            didTapDislike: didTapDislike
        )
        return Driver.merge(initialResult, refreshResult, helpfulResult)
    }
    
    func makeRefreshResult(didTapRefresh: Signal<AssistantResult>) -> Driver<AssistantResult> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .flatMapLatest { [weak self] currentResult -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                return obtainResult(currentResult, refresh: true)
            }
    }
    
    func makeHelpfulResult(
        didTapLike: Signal<AssistantResult>,
        didTapDislike: Signal<AssistantResult>
    ) -> Driver<AssistantResult> {
        let helpful = Signal
            .merge(
                didTapLike.map { (true, $0) },
                didTapDislike.map { (false, $0) }
            )
            .asDriver(onErrorDriveWith: .never())
        
        return helpful
            .flatMapFirst { [weak self] args -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                let (helpful, currentAssistantResult) = args
                
                guard let currentResult = currentAssistantResult.result else {
                    return .just(currentAssistantResult)
                }
                
                let performHelpful: Single<Void> = { [weak self] in
                    guard let self else { return .never() }
                    
                    switch currentResult {
                    case .math(let math):
                        return assistantManager
                            .helpful(threadId: math.threadId, assistantType: .math, helpful: helpful)
                            .catchAndReturn(())
                    case .physics(let physics):
                        return assistantManager
                            .helpful(threadId: physics.threadId, assistantType: .physics, helpful: helpful)
                            .catchAndReturn(())
                    case .biology(let biology):
                        return assistantManager
                            .helpful(threadId: biology.threadId, assistantType: .biology, helpful: helpful)
                            .catchAndReturn(())
                    case .chemistry(let chemistry):
                        return assistantManager
                            .helpful(threadId: chemistry.threadId, assistantType: .chemistry, helpful: helpful)
                            .catchAndReturn(())
                    case .writing(let writing):
                        return assistantManager
                            .helpful(threadId: writing.threadId, assistantType: .writing, helpful: helpful)
                            .catchAndReturn(())
                    case .translate:
                        return .never()
                    }
                }()
                
                return performHelpful
                    .asDriver(onErrorDriveWith: .never())
                    .flatMap { [weak self] void -> Driver<AssistantResult> in
                        guard let self else { return .never() }
                        
                        return obtainResult(currentAssistantResult, refresh: false)
                    }
            }
    }
    
    func obtainResult(_ result: AssistantResult, refresh: Bool) -> Driver<AssistantResult> {
        guard let currentResult = result.result else {
            return .just(result)
        }
        
        switch currentResult {
        case .math(let math):
            return assistantManager
                .processMath(threadId: math.threadId, isRepeat: refresh)
                .asDriver(onErrorJustReturn: nil)
                .map { mathResponse -> AssistantResult in
                    guard let mathResponse else { return result }
                    
                    let mathResult = AssistantResult.Result.math(mathResponse)
                    return AssistantResult(inputData: result.inputData, result: mathResult)
                }
        case .physics(let physics):
            return assistantManager
                .processPhysics(threadId: physics.threadId, isRepeat: refresh)
                .asDriver(onErrorJustReturn: nil)
                .map { physicsResponse -> AssistantResult in
                    guard let physicsResponse else { return result }
                    
                    let physicsResult = AssistantResult.Result.physics(physicsResponse)
                    return AssistantResult(inputData: result.inputData, result: physicsResult)
                }
        case .biology(let biology):
            return assistantManager
                .processBiology(threadId: biology.threadId, isRepeat: refresh)
                .asDriver(onErrorJustReturn: nil)
                .map { biologyResponse -> AssistantResult in
                    guard let biologyResponse else { return result }
                    
                    let biologyResult = AssistantResult.Result.biology(biologyResponse)
                    return AssistantResult(inputData: result.inputData, result: biologyResult)
                }
        case .chemistry(let chemistry):
            return assistantManager
                .processChemistry(threadId: chemistry.threadId, isRepeat: refresh)
                .asDriver(onErrorJustReturn: nil)
                .map { chemistryResponse -> AssistantResult in
                    guard let chemistryResponse else { return result }
                    
                    let chemistryResult = AssistantResult.Result.chemistry(chemistryResponse)
                    return AssistantResult(inputData: result.inputData, result: chemistryResult)
                }
        case .writing(let writing):
            return assistantManager
                .processWriting(threadId: writing.threadId, isRepeat: refresh)
                .asDriver(onErrorJustReturn: nil)
                .map { writingResponse -> AssistantResult in
                    guard let writingResponse else { return result }
                    
                    let writingResult = AssistantResult.Result.writing(writingResponse)
                    return AssistantResult(inputData: result.inputData, result: writingResult)
                }
        case .translate(let translate):
            switch result.inputData {
            case .recognized(let recognized):
                let croppedImage = recognized.recognized.croppedImage
                
                return assistantManager
                    .translate(image: croppedImage, languageCode: translate.languageCode)
                    .asDriver(onErrorJustReturn: nil)
                    .map { translate -> AssistantResult in
                        guard let translate else { return result }
                        
                        return AssistantResult(inputData: result.inputData, result: .translate(translate))
                    }
            case .manual(let manual):
                switch manual {
                case .language(let text, let language):
                    return assistantManager
                        .translate(text: text, languageCode: language.code)
                        .asDriver(onErrorJustReturn: nil)
                        .map { translate -> AssistantResult in
                            guard let translate else { return result }
                            
                            return AssistantResult(inputData: result.inputData, result: .translate(translate))
                        }
                default:
                    return .just(result)
                }
            case .historyItem:
                return .just(result)
            }
        }
    }
    
    func makeInitialResult(inputData: Driver<InputData>) -> Driver<AssistantResult> {
        inputData.flatMapLatest { [weak self] inputData -> Driver<AssistantResult> in
            guard let self else { return .never() }
            
            switch inputData {
            case .recognized(let recognized):
                switch recognized.recognized.assistant {
                case .math(let mathResult):
                    return assistantManager
                        .processMath(threadId: mathResult.threadId, isRepeat: false)
                        .asDriver(onErrorJustReturn: nil)
                        .map { mathResponse -> AssistantResult in
                            guard let mathResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.math(mathResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .physics(let physicsResult):
                    return assistantManager
                        .processPhysics(threadId: physicsResult.threadId, isRepeat: false)
                        .asDriver(onErrorJustReturn: nil)
                        .map { physicsResponse -> AssistantResult in
                            guard let physicsResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.physics(physicsResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .biology(let biologyResult):
                    return assistantManager
                        .processBiology(threadId: biologyResult.threadId, isRepeat: false)
                        .asDriver(onErrorJustReturn: nil)
                        .map { biologyResponse -> AssistantResult in
                            guard let biologyResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.biology(biologyResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .chemistry(let chemistryResult):
                    return assistantManager
                        .processChemistry(threadId: chemistryResult.threadId, isRepeat: false)
                        .asDriver(onErrorJustReturn: nil)
                        .map { chemistryResponse -> AssistantResult in
                            guard let chemistryResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.chemistry(chemistryResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .writing(_, let writingResult):
                    return assistantManager
                        .processWriting(threadId: writingResult.threadId, isRepeat: false)
                        .asDriver(onErrorJustReturn: nil)
                        .map { writingResponse -> AssistantResult in
                            guard let writingResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.writing(writingResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .language(let translateResult):
                    let result = AssistantResult(inputData: inputData, result: .translate(translateResult))
                    return .just(result)
                }
            case .manual(let data):
                switch data {
                case .math(let string):
                    return assistantManager
                        .analyzeManualMath(text: string)
                        .asDriver(onErrorJustReturn: nil)
                        .map { mathResponse -> AssistantResult in
                            guard let mathResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.math(mathResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .physics(let string):
                    return assistantManager
                        .analyzeManualPhysics(text: string)
                        .asDriver(onErrorJustReturn: nil)
                        .map { physicsResponse -> AssistantResult in
                            guard let physicsResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.physics(physicsResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .biology(let string):
                    return assistantManager
                        .analyzeManualBiology(text: string)
                        .asDriver(onErrorJustReturn: nil)
                        .map { biologyResponse -> AssistantResult in
                            guard let biologyResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.biology(biologyResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .chemistry(let string):
                    return assistantManager
                        .analyzeManualChemistry(text: string)
                        .asDriver(onErrorJustReturn: nil)
                        .map { chemistryResponse -> AssistantResult in
                            guard let chemistryResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.chemistry(chemistryResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .writing(let string, let writingMode, let writingStyle):
                    return assistantManager
                        .analyzeManualWriting(text: string, mode: writingMode, style: writingStyle)
                        .asDriver(onErrorJustReturn: nil)
                        .map { writingResponse -> AssistantResult in
                            guard let writingResponse else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.writing(writingResponse)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                case .language(let string, let language):
                    return assistantManager
                        .translate(text: string, languageCode: language.code)
                        .asDriver(onErrorJustReturn: nil)
                        .map { translate -> AssistantResult in
                            guard let translate else { return AssistantResult(inputData: inputData) }
                            
                            let result = AssistantResult.Result.translate(translate)
                            return AssistantResult(inputData: inputData, result: result)
                        }
                }
            case .historyItem(let historyItem):
                switch historyItem {
                case .math(let math):
                    let result = AssistantResult(inputData: inputData, result: .math(math))
                    return .just(result)
                case .physics(let physics):
                    let result = AssistantResult(inputData: inputData, result: .physics(physics))
                    return .just(result)
                case .biology(let biology):
                    let result = AssistantResult(inputData: inputData, result: .biology(biology))
                    return .just(result)
                case .chemistry(let chemistry):
                    let result = AssistantResult(inputData: inputData, result: .chemistry(chemistry))
                    return .just(result)
                case .writing(let writing):
                    let result = AssistantResult(inputData: inputData, result: .writing(writing))
                    return .just(result)
                }
            }
        }
    }
    
    func makeAction(didTapCopy: Signal<AssistantResultTableAnswerElement>) -> Driver<Action> {
        let copy = didTapCopy
            .asDriver(onErrorDriveWith: .never())
            .map { answer -> String in
                switch answer {
                case .math(let mathResponse):
                    return mathResponse.body
                case .physics(let physicsResponse):
                    return physicsResponse.body
                case .biology(let biologyResponse):
                    return biologyResponse.body
                case .chemistry(let chemistryResponse):
                    return chemistryResponse.body
                case .writing(let writingResponse):
                    return writingResponse.body
                case .language(let translateResult):
                    return translateResult.translate
                }
            }
            .map { Action.copy($0) }
        
        return Driver
            .merge(copy)
    }
}
