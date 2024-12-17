//
//  AssistantResultTableElement.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

enum AssistantResultTableElement {
    case questionImageUrl(URL)
    case questionImage(UIImage)
    case questionText(String)
    case loading
    case answer(AssistantResultTableAnswerElement)
    case helpful
}

enum AssistantResultTableAnswerElement {
    case math(MathAssistantResult.Response)
    case physics(PhysicsAssistantResult.Response)
    case biology(BiologyAssistantResult.Response)
    case chemistry(ChemistryAssistantResult.Response)
    case writing(WritingAssistantResult.Response)
    case language(TranslateResult)
    
    var detected: Bool {
        switch self {
        case .math(let response):
            return response.detected
        case .physics(let response):
            return response.detected
        case .biology(let response):
            return response.detected
        case .chemistry(let response):
            return response.detected
        case .writing(let response):
            return response.detected
        case .language(let translateResult):
            return true
        }
    }
}
