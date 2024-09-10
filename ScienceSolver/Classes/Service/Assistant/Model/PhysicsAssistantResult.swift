//
//  PhysicsAssistantResult.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 09.09.2024.
//

struct PhysicsAssistantResult {
    struct Request {
        let content: String
    }
    
    struct Response {
        let userRawInput: String?
        let body: String
        let explanation: String
        let recommendation: String
    }
    
    let threadId: String
    let helpful: Bool?
    let request: Request?
    let response: Response
}

// MARK: Public
extension PhysicsAssistantResult {
    static func map(response: Any) -> PhysicsAssistantResult? {
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
        
        return PhysicsAssistantResult(
            threadId: threadId,
            helpful: body["helpful"] as? Bool,
            request: request,
            response: response
        )
    }
}

// MARK: Public
extension PhysicsAssistantResult.Response {
    static func map(content: [String: Any]) -> PhysicsAssistantResult.Response? {
        guard
            let body = content["body"] as? String,
            let explanation = content["explanation"] as? String,
            let recommendation = content["recommendation"] as? String
        else { return nil }
        
        return PhysicsAssistantResult.Response(
            userRawInput: content["user_raw_input"] as? String,
            body: body,
            explanation: explanation,
            recommendation: recommendation
        )
    }
}
