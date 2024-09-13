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
    
    let assistant: Assistant
    var marked: Bool
    
    init(assistant: Assistant, marked: Bool) {
        self.assistant = assistant
        self.marked = marked
    }
}
