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
    
    private lazy var assistantManager = AssistantManager()
    
    private let inputData: Driver<InputData>
    
    init(recognized: AssistantRecognizerController.Result) {
        inputData = BehaviorRelay(value: InputData.recognized(recognized)).asDriver()
    }
    
    init(historyItem: AssistantHistoryItem) {
        inputData = BehaviorRelay(value: InputData.historyItem(historyItem)).asDriver()
    }
}

// MARK: Public
extension AssistantResultViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapRefresh: Signal<Void>
        let didTapCopy: Signal<AssistantResultTableAnswerElement>
        let didTapLike: Signal<Void>
        let didTapDislike: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let action: Driver<Action>
        let elements: Driver<[AssistantResultTableElement]>
    }
    
    func configure(input: Input) -> Output {
        let assistantResult = makeResult(
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
                assistantResult: assistantResult
            )
        )
    }
}

// MARK: Private
private extension AssistantResultViewModel {
    enum InputData {
        case recognized(AssistantRecognizerController.Result)
        case historyItem(AssistantHistoryItem)
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
    
    func makeRoute(didTapClose: Signal<Void>) -> Driver<Route> {
        let close = didTapClose
            .map { Route.close }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(close)
    }
    
    func makeElements(
        inputData: Driver<InputData>,
        didTapRefresh: Signal<Void>,
        assistantResult: Driver<AssistantResult>
    ) -> Driver<[AssistantResultTableElement]> {
        let initalElements = makeInitialElements(inputData: inputData)
        let resultElements = makeResultElements(assistantResult: assistantResult)
        let resetElements = makeResetElements(didTapRefresh: didTapRefresh, inputData: inputData)
        return Driver.merge(initalElements, resultElements, resetElements)
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
                case .historyItem:
                    return nil
                }
            }
    }
    
    func makeResetElements(didTapRefresh: Signal<Void>, inputData: Driver<InputData>) -> Driver<[AssistantResultTableElement]> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(inputData)
            .map { inputData -> [AssistantResultTableElement] in
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
                case .historyItem(let item):
                    switch item {
                    case .math(let math):
                        return [
                            {
                                if let imageUrl = math.request.imageUrl {
                                    return .questionImageUrl(imageUrl)
                                } else {
                                    return .questionText(math.request.content)
                                }
                            }(),
                            .loading
                        ]
                    case .physics(let physics):
                        return [
                            {
                                if let imageUrl = physics.request.imageUrl {
                                    return .questionImageUrl(imageUrl)
                                } else {
                                    return .questionText(physics.request.content)
                                }
                            }(),
                            .loading
                        ]
                    case .biology(let biology):
                        return [
                            {
                                if let imageUrl = biology.request.imageUrl {
                                    return .questionImageUrl(imageUrl)
                                } else {
                                    return .questionText(biology.request.content)
                                }
                            }(),
                            .loading
                        ]
                    case .chemistry(let chemistry):
                        return [
                            {
                                if let imageUrl = chemistry.request.imageUrl {
                                    return .questionImageUrl(imageUrl)
                                } else {
                                    return .questionText(chemistry.request.content)
                                }
                            }(),
                            .loading
                        ]
                    case .writing(let writing):
                        return [
                            {
                                if let imageUrl = writing.request.imageUrl {
                                    return .questionImageUrl(imageUrl)
                                } else {
                                    return .questionText(writing.request.content)
                                }
                            }(),
                            .loading
                        ]
                    }
                }
            }
    }
    
    func makeResultElements(assistantResult: Driver<AssistantResult>) -> Driver<[AssistantResultTableElement]> {
        assistantResult
            .map { assistantResult -> [AssistantResultTableElement] in
                let inputData = assistantResult.inputData
                
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
                    
                    let inputImage: UIImage? = {
                        switch inputData {
                        case .recognized(let recognized):
                            return recognized.recognized.croppedImage
                        case .historyItem:
                            return nil
                        }
                    }()
                    
                    // TODO
                    let inputText: String? = {
                        nil
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
        didTapRefresh: Signal<Void>,
        didTapLike: Signal<Void>,
        didTapDislike: Signal<Void>
    ) -> Driver<AssistantResult> {
        let initialResult = makeInitialResult(inputData: inputData)
        let refreshResult = makeRefreshResult(inputData: inputData, didTapRefresh: didTapRefresh)
        let helpfulResult = makeHelpfulResult(
            inputData: inputData,
            didTapLike: didTapLike,
            didTapDislike: didTapDislike
        )
        return Driver.merge(initialResult, refreshResult, helpfulResult)
    }
    
    func makeInitialResult(inputData: Driver<InputData>) -> Driver<AssistantResult> {
        inputData
            .flatMapLatest { [weak self] inputData -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                switch inputData {
                case .recognized:
                    return fetchResult(inputData: inputData, refresh: false)
                case .historyItem(let item):
                    switch item {
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
    
    func makeRefreshResult(
        inputData: Driver<InputData>,
        didTapRefresh: Signal<Void>
    ) -> Driver<AssistantResult> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(inputData)
            .flatMapLatest { [weak self] inputData -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                return fetchResult(inputData: inputData, refresh: true)
            }
    }
    
    func makeHelpfulResult(
        inputData: Driver<InputData>,
        didTapLike: Signal<Void>,
        didTapDislike: Signal<Void>
    ) -> Driver<AssistantResult> {
        let helpful = Signal
            .merge(
                didTapLike.map { true },
                didTapDislike.map { false }
            )
            .asDriver(onErrorDriveWith: .never())
        
        return helpful
            .withLatestFrom(inputData) { ($0, $1) }
            .flatMapFirst { [weak self] args -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                let (helpful, inputData) = args
                
                let performHelpful: Single<Void> = { [weak self] in
                    guard let self else { return .never() }
                    
                    switch inputData {
                    case .recognized(let recognized):
                        switch recognized.recognized.assistant {
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
                        case .writing(_, let writing):
                            return assistantManager
                                .helpful(threadId: writing.threadId, assistantType: .writing, helpful: helpful)
                                .catchAndReturn(())
                        case .language:
                            return .never()
                        }
                    case .historyItem(let item):
                        switch item {
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
                        }
                    }
                }()
                
                return performHelpful
                    .asDriver(onErrorDriveWith: .never())
                    .flatMap { [weak self] void -> Driver<AssistantResult> in
                        guard let self else { return .never() }
                        
                        return fetchResult(inputData: inputData, refresh: false)
                    }
            }
    }
    
    func fetchResult(inputData: InputData, refresh: Bool) -> Driver<AssistantResult> {
        switch inputData {
        case .recognized(let recognized):
            switch recognized.recognized.assistant {
            case .math(let mathResult):
                return assistantManager
                    .processMath(threadId: mathResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { mathResponse -> AssistantResult in
                        guard let mathResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.math(mathResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .physics(let physicsResult):
                return assistantManager
                    .processPhysics(threadId: physicsResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { physicsResponse -> AssistantResult in
                        guard let physicsResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.physics(physicsResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .biology(let biologyResult):
                return assistantManager
                    .processBiology(threadId: biologyResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { biologyResponse -> AssistantResult in
                        guard let biologyResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.biology(biologyResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .chemistry(let chemistryResult):
                return assistantManager
                    .processChemistry(threadId: chemistryResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { chemistryResponse -> AssistantResult in
                        guard let chemistryResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.chemistry(chemistryResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .writing(_, let writingResult):
                return assistantManager
                    .processWriting(threadId: writingResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { writingResponse -> AssistantResult in
                        guard let writingResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.writing(writingResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .language(let translateResult):
                guard refresh else {
                    let result = AssistantResult(inputData: inputData, result: .translate(translateResult))
                    return .just(result)
                }
                
                let croppedImage = recognized.recognized.croppedImage
                
                return assistantManager
                    .translate(image: croppedImage, languageCode: translateResult.languageCode)
                    .asDriver(onErrorJustReturn: nil)
                    .map { updateResult -> AssistantResult in
                        let translate = updateResult ?? translateResult
                        
                        let result = AssistantResult.Result.translate(translate)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            }
        case .historyItem(let historyItem):
            switch historyItem {
            case .math(let mathResult):
                return assistantManager
                    .processMath(threadId: mathResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { mathResponse -> AssistantResult in
                        guard let mathResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.math(mathResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .physics(let physicsResult):
                return assistantManager
                    .processPhysics(threadId: physicsResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { physicsResponse -> AssistantResult in
                        guard let physicsResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.physics(physicsResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .biology(let biologyResult):
                return assistantManager
                    .processBiology(threadId: biologyResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { biologyResponse -> AssistantResult in
                        guard let biologyResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.biology(biologyResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .chemistry(let chemistryResult):
                return assistantManager
                    .processChemistry(threadId: chemistryResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { chemistryResponse -> AssistantResult in
                        guard let chemistryResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.chemistry(chemistryResponse)
                        return AssistantResult(inputData: inputData, result: result)
                    }
            case .writing(let writingResult):
                return assistantManager
                    .processWriting(threadId: writingResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { writingResponse -> AssistantResult in
                        guard let writingResponse else { return AssistantResult(inputData: inputData) }
                        
                        let result = AssistantResult.Result.writing(writingResponse)
                        return AssistantResult(inputData: inputData, result: result)
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
                    let solution = mathResponse
                        .solution.map { solution -> String in
                            [solution.math, solution.description].joined(separator: "\n")
                        }
                        .joined(separator: "\n\n")
                    let answer = mathResponse.answer
                    
                    return [solution, answer]
                        .joined(separator: "\n\n")
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
