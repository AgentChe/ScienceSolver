//
//  GlobalDefinitions.swift
//  Soccer
//
//  Created by Andrey Chernyshev on 16.01.2021.
//

import Foundation

// TODO
final class GlobalDefinitions {
    static let domain = "https://science.camplain-apps.com"
    static let apiKey = "zMvSnNSvO7NMJbdviV"
    
    static let otterScaleHost = "https://api.korrekted.com"
    static let otterScaleApiKey = "i9upCYSnV2mW4aM3"
    
    static let applicationTag = "WHIP"
    static let amplitudeApiKey = "d4ad5c33d23d7a891e9c68de9471f36b"
    
    static let termsOfServiceUrl = URL(string: "https://sergei-mobile.com/eula.html")!
    static let privacyPolicyUrl = URL(string: "https://sergei-mobile.com/policy.html")!
    static let contactUsUrl = URL(string: "https://sergei-mobile.com/contact.html")!
    
    enum Paygate {
        static let yearly = "train.somatic.endless"
        static let weekly = "train.somatic.monthly"
    }
}
