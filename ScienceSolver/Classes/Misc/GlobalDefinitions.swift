//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://science.thinkaboutapps.com"
    static let apiKey = "zMvSnNSvO7NMJbdviV"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "6ShpjkA5kIKzBA48"
    
    static let termsOfServiceUrl = URL(string: "https://thinkaboutapps.com/terms")!
    static let privacyPolicyUrl = URL(string: "https://thinkaboutapps.com/policy")!
    static let contactUsUrl = URL(string: "https://thinkaboutapps.com/contact")!
    
    enum Paygate {
        static let yearly = "science.yearly"
        static let weekly = "science.weekly"
    }
}
