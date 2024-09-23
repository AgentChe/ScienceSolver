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
}
