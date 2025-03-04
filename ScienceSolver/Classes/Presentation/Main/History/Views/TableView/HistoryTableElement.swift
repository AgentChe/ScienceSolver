//
//  HistoryTableElement.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import Foundation

struct HistoryTableElement {
    enum Mode {
        case image(URL)
        case text(String)
    }
    
    let assistantName: String
    let mode: Mode
    let created: String
    let item: AssistantHistoryItem
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    init(item: AssistantHistoryItem) {
        self.assistantName = {
            switch item {
            case .math:
                return "Assistant.Math".localized
            case .physics:
                return "Assistant.Physics".localized
            case .biology:
                return "Assistant.Biology".localized
            case .chemistry:
                return "Assistant.Chemistry".localized
            case .writing:
                return "Assistant.Writing".localized
            }
        }()
        self.mode = {
            if let url = item.imageUrl {
                return .image(url)
            }
            return .text(item.text)
        }()
        self.created = {
            let date = Date(timeIntervalSince1970: item.created)
            return HistoryTableElement.dateFormatter.string(from: date)
        }()
        self.item = item
    }
}

// MARK: Additional
private extension AssistantHistoryItem {
    var imageUrl: URL? {
        switch self {
        case .math(let result):
            return result.request.imageUrl
        case .physics(let result):
            return result.request.imageUrl
        case .biology(let result):
            return result.request.imageUrl
        case .chemistry(let result):
            return result.request.imageUrl
        case .writing(let result):
            return result.request.imageUrl
        }
    }
    
    var text: String {
        switch self {
        case .math(let result):
            return result.title ?? result.request.content
        case .physics(let result):
            return result.title ?? result.request.content
        case .biology(let result):
            return result.title ?? result.request.content
        case .chemistry(let result):
            return result.title ?? result.request.content
        case .writing(let result):
            return result.title ?? result.request.content
        }
    }
    
    var created: TimeInterval {
        switch self {
        case .math(let result):
            return result.created
        case .physics(let result):
            return result.created
        case .biology(let result):
            return result.created
        case .chemistry(let result):
            return result.created
        case .writing(let result):
            return result.created
        }
    }
}
