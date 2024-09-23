//
//  AssistantAssembly.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class AssistantAssembly {
    func recognize(assistant: AssistantsCollectionElement.Assistant? = nil, from: UIViewController) {
        let nc = NavigationController()
        nc.modalPresentationStyle = .fullScreen
        nc.setNavigationBarHidden(true, animated: false)
        
        let recognizerVC = AssistantRecognizerController.make(assistant: assistant, close: { [weak nc] in
            nc?.dismiss(animated: true)
        }, result: { [weak nc] result in
            let resultVC = AssistantResultViewController.make(recognized: result) { [weak nc] in
                nc?.dismiss(animated: true)
            }
            nc?.pushViewController(resultVC, animated: true)
        })
        
        nc.setViewControllers([recognizerVC], animated: false)
        
        from.present(nc, animated: true)
    }
}
