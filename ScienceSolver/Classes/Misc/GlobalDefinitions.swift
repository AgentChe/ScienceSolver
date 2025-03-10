//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

final class GlobalDefinitions {
    static let domain = "https://science.camplain-apps.com"
    static let apiKey = "zMvSnNSvO7NMJbdviV"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "6ShpjkA5kIKzBA48"
    
    static let applicationTag = "SCIENCE_SOLVER"
    static let amplitudeApiKey = "784ee0e6cb07cb515f3b080b4b415b27"
    
    static let termsOfServiceUrl = URL(string: "https://camplain-apps.com/terms-of-use.html")!
    static let privacyPolicyUrl = URL(string: "https://camplain-apps.com/privacy-policy.html")!
    static let contactUsUrl = URL(string: "https://camplain-apps.com/contacts.html")!
    
    enum Paygate {
        static let yearly = "science.yearly"
        static let weekly = "science.weekly"
    }
}
