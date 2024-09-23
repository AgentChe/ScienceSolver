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
    }
    
    enum Response {
        case math(MathAssistantResult.Response)
        case physics(PhysicsAssistantResult.Response)
        case biology(BiologyAssistantResult.Response)
        case chemistry(ChemistryAssistantResult.Response)
        case writing(WritingAssistantResult.Response)
        case translate(TranslateResult)
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
        let download = download()
        let refresh = refresh(didTapRefresh: didTapRefresh)
        
        return Driver
            .merge(initial, download, refresh)
    }
    
    func makeInitialElements() -> Driver<[AssistantResultTableElement]> {
        inputData
            .map { inputData -> [AssistantResultTableElement] in
                switch inputData {
                case .recognized(let recognized):
                    switch recognized.recognized.assistant {
                    case .math, .physics, .biology, .chemistry, .writing:
                        return [.questionImage(recognized.recognized.croppedImage), .loading]
                    case .language(let result):
                        return [.questionImage(recognized.recognized.croppedImage), .answer(.language(result))]
                    }
                }
            }
    }
    
    func download() -> Driver<[AssistantResultTableElement]> {
        inputData
            .flatMapLatest { [weak self] inputData -> Driver<[AssistantResultTableElement]> in
                guard let self else { return .never() }
                
                return makeResponseElements(inputData: inputData, refresh: false)
            }
    }
    
    func refresh(didTapRefresh: Signal<Void>) -> Driver<[AssistantResultTableElement]> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .withLatestFrom(inputData)
            .flatMapLatest { [weak self] inputData -> Driver<[AssistantResultTableElement]> in
                guard let self else { return .never() }
                
                return makeResponseElements(inputData: inputData, refresh: true)
            }
    }
    
    func makeResponseElements(inputData: InputData, refresh: Bool) -> Driver<[AssistantResultTableElement]> {
        switch inputData {
        case .recognized(let recognized):
            let croppedImage = recognized.recognized.croppedImage
            
            switch recognized.recognized.assistant {
            case .math(let mathResult):
                return assistantManager
                    .processMath(threadId: mathResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { mathResponse -> [AssistantResultTableElement] in
                        guard let mathResponse else { return [.questionImage(croppedImage)] }
                        
                        return [
                            .questionImage(croppedImage),
                            .answer(.math(mathResponse.response)),
                            (mathResponse.helpful == nil) ? .helpful : nil
                        ].compactMap { $0 }
                    }
                    .startWith([.questionImage(croppedImage), .loading])
            case .physics(let physicsResult):
                return assistantManager
                    .processPhysics(threadId: physicsResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { physicsResponse -> [AssistantResultTableElement] in
                        guard let physicsResponse else { return [.questionImage(croppedImage)] }
                        
                        return [
                            .questionImage(croppedImage),
                            .answer(.physics(physicsResponse.response)),
                            (physicsResponse.helpful == nil) ? .helpful : nil
                        ].compactMap { $0 }
                    }
                    .startWith([.questionImage(croppedImage), .loading])
            case .biology(let biologyResult):
                return assistantManager
                    .processBiology(threadId: biologyResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { biologyResponse -> [AssistantResultTableElement] in
                        guard let biologyResponse else { return [.questionImage(croppedImage)] }
                        
                        return [
                            .questionImage(croppedImage),
                            .answer(.biolody(biologyResponse.response)),
                            (biologyResponse.helpful == nil) ? .helpful : nil
                        ].compactMap { $0 }
                    }
                    .startWith([.questionImage(croppedImage), .loading])
            case .chemistry(let chemistryResult):
                return assistantManager
                    .processChemistry(threadId: chemistryResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { chemistryResponse -> [AssistantResultTableElement] in
                        guard let chemistryResponse else { return [.questionImage(croppedImage)] }
                        
                        return [
                            .questionImage(croppedImage),
                            .answer(.chemistry(chemistryResponse.response)),
                            (chemistryResponse.helpful == nil) ? .helpful : nil
                        ].compactMap { $0 }
                    }
                    .startWith([.questionImage(croppedImage), .loading])
            case .writing(_, let writingResult):
                return assistantManager
                    .processWriting(threadId: writingResult.threadId, isRepeat: refresh)
                    .asDriver(onErrorJustReturn: nil)
                    .map { writingResponse -> [AssistantResultTableElement] in
                        guard let writingResponse else { return [.questionImage(croppedImage)] }
                        
                        return [
                            .questionImage(croppedImage),
                            .answer(.writing(writingResponse.response)),
                            (writingResponse.helpful == nil) ? .helpful : nil
                        ].compactMap { $0 }
                    }
                    .startWith([.questionImage(croppedImage), .loading])
            case .language(let translateResult):
                // В случае с переводом респонс получен сразу на этапе распознавания фото
                guard refresh else { return .never() }
                
                return assistantManager
                    .translate(image: croppedImage, languageCode: translateResult.languageCode)
                    .asDriver(onErrorJustReturn: nil)
                    .map { updateResult -> [AssistantResultTableElement] in
                        let translate = updateResult ?? translateResult
                        
                        return [.questionImage(croppedImage), .answer(.language(translate))]
                    }
                    .startWith([.questionImage(croppedImage), .loading])
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
                case .biolody(let biolodyResponse):
                    return biolodyResponse.body
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
