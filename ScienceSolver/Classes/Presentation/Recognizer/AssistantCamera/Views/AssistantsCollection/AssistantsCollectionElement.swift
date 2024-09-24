//
//  AssistantsCollectionElement.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

final class AssistantsCollectionElement {
    enum Assistant {
        case math
        case physics
        case biology
        case chemistry
        case writing
        case language
    }
    
    enum Style {
        case onlyWhite
        case whiteBlack
    }
    
    let assistant: Assistant
    let style: Style
    var marked: Bool
    
    init(assistant: Assistant, style: Style, marked: Bool) {
        self.assistant = assistant
        self.style = style
        self.marked = marked
    }
}
