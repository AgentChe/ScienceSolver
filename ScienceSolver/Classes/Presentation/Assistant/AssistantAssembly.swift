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
            let resultVC = AssistantResultViewController.make(recognized: result, generateEssay: { [weak nc] text, style in
                let data = AssistantMainViewController.DataForManualAnalyze.writing(text, .essay, style)
                let essayVC = AssistantResultViewController.make(manual: data)
                nc?.pushViewController(essayVC, animated: true)
            })
            resultVC.addCloseButtonInNavigationBar { [weak nc] in
                nc?.dismiss(animated: true)
            }
            
            nc?.setNavigationBarHidden(false, animated: false)
            nc?.setViewControllers([resultVC], animated: true)
        })
        
        nc.setViewControllers([recognizerVC], animated: false)
        
        from.present(nc, animated: true)
    }
    
    func manualAnalyze(data: AssistantMainViewController.DataForManualAnalyze, from: UINavigationController) {
        let resultVC = AssistantResultViewController.make(manual: data, generateEssay: { [weak from] text, style in
            let data = AssistantMainViewController.DataForManualAnalyze.writing(text, .essay, style)
            let essayVC = AssistantResultViewController.make(manual: data)
            from?.pushViewController(essayVC, animated: true)
        })
        from.pushViewController(resultVC, animated: true)
    }
    
    func history(item: AssistantHistoryItem, from: UINavigationController) {
        let resultVC = AssistantResultViewController.make(historyItem: item, generateEssay: { [weak from] text, style in
            let data = AssistantMainViewController.DataForManualAnalyze.writing(text, .essay, style)
            let essayVC = AssistantResultViewController.make(manual: data)
            from?.pushViewController(essayVC, animated: true)
        })
        from.pushViewController(resultVC, animated: true)
    }
}
