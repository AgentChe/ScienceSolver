//
//  MathAssistantResult.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 09.09.2024.
//

import Foundation

struct MathAssistantResult {
    struct Request {
        let content: String
    }
    
    struct Response {
        struct Solution {
            let step: Int
            let math: String
            let description: String
        }
        
        let userFormula: String?
        let userRawInput: String?
        let problem: String
        let solution: [Solution]
        let answer: String
        let explanation: String?
        let recommendation: String?
    }
    
    let threadId: String
    let helpful: Bool?
    let request: Request?
    let response: Response
}

// MARK: Public
extension MathAssistantResult {
    static func map(response: Any) -> MathAssistantResult? {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any],
            let threadId = body["thread_id"] as? String,
            let content = body["content"] as? [[String: Any]]
        else { return nil }
        
        let request: Request? = {
            for json in content {
                guard 
                    let type = json["type"] as? String, type == "request",
                    let content = json["content"] as? String
                else { continue }
                
                return Request(content: content)
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
        
        return MathAssistantResult(
            threadId: threadId,
            helpful: body["helpful"] as? Bool,
            request: request,
            response: response
        )
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
