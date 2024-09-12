//
//  MathAssistantResult.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 09.09.2024.
//

import Foundation

struct MathAssistantResult {
    struct Request {
        let imageUrl: URL?
        let content: String // latex текст
    }
    
    struct Response {
        struct Solution {
            let step: Int
            let math: String // latex текст
            let description: String // latex текст
        }
        
        let userFormula: String? // latex текст
        let userRawInput: String? // latex текст
        let problem: String // latex текст
        let solution: [Solution]
        let answer: String // latex текст
        let explanation: String? // latex текст
        let recommendation: String? // latex текст
    }
    
    let threadId: String
    let helpful: Bool?
    let request: Request?
    let response: Response
}

// MARK: Public
extension MathAssistantResult {
    init?(body: [String: Any]) {
        guard
            let threadId = body["thread_id"] as? String,
            let content = body["content"] as? [[String: Any]]
        else { return nil }
        
        let request: Request? = {
            for json in content {
                guard
                    let type = json["type"] as? String, type == "request",
                    let content = json["content"] as? String
                else { continue }
                
                let imageUrl: URL? = {
                    guard let path = json["image"] as? String else { return nil }
                    return URL(string: path)
                }()
                
                return Request(imageUrl: imageUrl, content: content)
            }
            
            return nil
        }()
        
        let response: Response? = {
            for json in content {
                guard
                    let type = json["type"] as? String, type == "response",
                    let content = json["content"] as? [String: Any]
                else { continue }
                
                return Response.map(content: content)
            }
            
            return nil
        }()
        guard let response else { return nil }
        
        self = MathAssistantResult(
            threadId: threadId,
            helpful: body["helpful"] as? Bool,
            request: request,
            response: response
        )
    }
    
    static func map(response: Any) -> MathAssistantResult? {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return nil }
        
        return MathAssistantResult(body: body)
    }
}

// MARK: Public
extension MathAssistantResult.Response {
    static func map(content: [String: Any]) -> MathAssistantResult.Response? {
        guard
            let body = content["body"] as? [String: Any],
            let problem = body["problem"] as? String,
            let solutionArray = body["solution"] as? [[String: Any]], !solutionArray.isEmpty,
            let answer = body["answer"] as? String
        else { return nil }
        
        let solution = solutionArray.compactMap { json -> MathAssistantResult.Response.Solution? in
            guard
                let step = json["step"] as? Int,
                let math = json["math"] as? String,
                let description = json["description"] as? String
            else { return nil }
            
            return MathAssistantResult.Response.Solution(
                step: step,
                math: math,
                description: description
            )
        }
        
        guard !solution.isEmpty else { return nil }
        
        return MathAssistantResult.Response(
            userFormula: content["user_formula"] as? String,
            userRawInput: content["user_raw_input"] as? String,
            problem: problem,
            solution: solution,
            answer: answer,
            explanation: body["explanation"] as? String,
            recommendation: body["recommendation"] as? String
        )
    }
}
