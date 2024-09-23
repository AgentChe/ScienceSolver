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
    }
    
    struct Output {
        let route: Driver<Route>
        let action: Driver<Action>
        let elements: Driver<[AssistantResultTableElement]>
    }
    
    func configure(input: Input) -> Output {
        Output(
            route: makeRoute(didTapClose: input.didTapClose),
            action: makeAction(didTapCopy: input.didTapCopy),
            elements: makeElements(didTapRefresh: input.didTapRefresh)
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
    
    func makeElements(didTapRefresh: Signal<Void>) -> Driver<[AssistantResultTableElement]> {
        let initial = makeInitialElements()
        
        let reset = resetElementsToInitial(didTapRefresh: didTapRefresh)
        
        let result = Driver
            .merge(
                makeDownloadResult(),
                makeRefreshResult(didTapRefresh: didTapRefresh)
            )
        let response = makeResponseElements(assistantResult: result, ignoreHelpful: false)
        
        return Driver
            .merge(initial, reset, response)
    }
    
    func makeInitialElements() -> Driver<[AssistantResultTableElement]> {
        inputData
            .map { inputData -> [AssistantResultTableElement] in
                switch inputData {
                case .recognized:
                    return inputData.initialElements(withLoading: true)
                case .historyItem:
                    return inputData.initialElements(withLoading: false)
                }
            }
    }
    
    func resetElementsToInitial(didTapRefresh: Signal<Void>) -> Driver<[AssistantResultTableElement]> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(inputData)
            .map { inputData -> [AssistantResultTableElement] in
                inputData.initialElements(withLoading: true)
            }
    }
    
    func makeResponseElements(assistantResult: Driver<AssistantResult>, ignoreHelpful: Bool) -> Driver<[AssistantResultTableElement]> {
        assistantResult
            .map { assistantResult -> [AssistantResultTableElement] in
                let inputData = assistantResult.inputData
                
                guard let result = assistantResult.result else {
                    return inputData.initialElements(withLoading: false)
                }
                
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
                        ignoreHelpful ? nil : ((mathResult.helpful == nil) ? .helpful : nil)
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
                        ignoreHelpful ? nil : ((physicsResult.helpful == nil) ? .helpful : nil)
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
                        ignoreHelpful ? nil : ((biologyResult.helpful == nil) ? .helpful : nil)
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
                        ignoreHelpful ? nil : ((chemistryResult.helpful == nil) ? .helpful : nil)
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
                        .answer(.writing(writingResult.response)),
                        ignoreHelpful ? nil : ((writingResult.helpful == nil) ? .helpful : nil)
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
    
    func makeDownloadResult() -> Driver<AssistantResult> {
        inputData
            .flatMapLatest { [weak self] inputData -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                return makeResult(inputData: inputData, refresh: false)
            }
    }
    
    func makeRefreshResult(didTapRefresh: Signal<Void>) -> Driver<AssistantResult> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(inputData)
            .flatMapLatest { [weak self] inputData -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                return makeResult(inputData: inputData, refresh: true)
            }
    }
    
    func makeResult(inputData: InputData, refresh: Bool) -> Driver<AssistantResult> {
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
                // В случае с переводом респонс получен сразу на этапе распознавания фото
                guard refresh else { return .never() }
                
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
            // В случае с историей, в initial сразу отобразятся актуальные данные
            guard refresh else { return .never() }
            
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

// MARK: Additional
private extension AssistantResultViewModel.InputData {
    func initialElements(withLoading: Bool) -> [AssistantResultTableElement] {
        switch self {
        case .recognized(let recognized):
            switch recognized.recognized.assistant {
            case .math(let math):
                return [.questionImageUrl(math.url), withLoading ? .loading : nil].compactMap { $0 }
            case .physics(let physics):
                return [.questionImageUrl(physics.url), withLoading ? .loading : nil].compactMap { $0 }
            case .biology(let biology):
                return [.questionImageUrl(biology.url), withLoading ? .loading : nil].compactMap { $0 }
            case .chemistry(let chemistry):
                return [.questionImageUrl(chemistry.url), withLoading ? .loading : nil].compactMap { $0 }
            case .writing(_, let writing):
                return [.questionImageUrl(writing.url), withLoading ? .loading : nil].compactMap { $0 }
            case .language:
                return [.questionImage(recognized.recognized.croppedImage), withLoading ? .loading : nil].compactMap { $0 }
            }
        case .historyItem(let historyItem):
            switch historyItem {
            case .math(let math):
                return [
                    {
                        if let imageUrl = math.request.imageUrl {
                            return .questionImageUrl(imageUrl)
                        } else {
                            return .questionText(math.request.content)
                        }
                    }(),
                    withLoading ? .loading : nil,
                    withLoading ? nil : .answer(.math(math.response)),
                    withLoading ? nil : ((math.helpful == nil) ? .helpful : nil)
                ].compactMap { $0 }
            case .physics(let physics):
                return [
                    {
                        if let imageUrl = physics.request.imageUrl {
                            return .questionImageUrl(imageUrl)
                        } else {
                            return .questionText(physics.request.content)
                        }
                    }(),
                    withLoading ? .loading : nil,
                    withLoading ? nil : .answer(.physics(physics.response)),
                    withLoading ? nil : ((physics.helpful == nil) ? .helpful : nil)
                ].compactMap { $0 }
            case .biology(let biology):
                return [
                    {
                        if let imageUrl = biology.request.imageUrl {
                            return .questionImageUrl(imageUrl)
                        } else {
                            return .questionText(biology.request.content)
                        }
                    }(),
                    withLoading ? .loading : nil,
                    withLoading ? nil : .answer(.biology(biology.response)),
                    withLoading ? nil : ((biology.helpful == nil) ? .helpful : nil)
                ].compactMap { $0 }
            case .chemistry(let chemistry):
                return [
                    {
                        if let imageUrl = chemistry.request.imageUrl {
                            return .questionImageUrl(imageUrl)
                        } else {
                            return .questionText(chemistry.request.content)
                        }
                    }(),
                    withLoading ? .loading : nil,
                    withLoading ? nil : .answer(.chemistry(chemistry.response)),
                    withLoading ? nil : ((chemistry.helpful == nil) ? .helpful : nil)
                ].compactMap { $0 }
            case .writing(let writing):
                return [
                    {
                        if let imageUrl = writing.request.imageUrl {
                            return .questionImageUrl(imageUrl)
                        } else {
                            return .questionText(writing.request.content)
                        }
                    }(),
                    withLoading ? .loading : nil,
                    withLoading ? nil : .answer(.writing(writing.response)),
                    withLoading ? nil : ((writing.helpful == nil) ? .helpful : nil)
                ].compactMap { $0 }
            }
        }
    }
}
