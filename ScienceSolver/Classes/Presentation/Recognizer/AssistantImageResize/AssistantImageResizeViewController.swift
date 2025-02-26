//
//  AssistantImageResizeViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import UIKit
import RxSwift
import RxCocoa
import Mantis

final class AssistantImageResizeViewController: UIViewController {
    struct Result {
        enum Assistant {
            case math(AssistantAnalyzeImageResult)
            case physics(AssistantAnalyzeImageResult)
            case biology(AssistantAnalyzeImageResult)
            case chemistry(AssistantAnalyzeImageResult)
            case writing(WritingStyle, AssistantAnalyzeImageResult)
            case language(TranslateResult)
        }
        
        let croppedImage: UIImage
        let assistant: Assistant
    }
    
    var didResult: ((Result) -> Void)?
    var didCancel: (() -> Void)?
    
    private lazy var mainView = AssistantImageResizeView()
    
    private let viewModel: AssistantImageResizeViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private weak var cropVC: CropViewController?
    
    private lazy var didCroppedImageTrigger = PublishRelay<UIImage>()
    private lazy var didSelectWritingStyleTrigger = PublishRelay<WritingStyle>()
    private lazy var didSelectLanguageTrigger = PublishRelay<Language>()
    
    private init(fromCamera: AssistantCameraViewController.Result) {
        viewModel = AssistantImageResizeViewModel(fromCamera: fromCamera)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: AssistantImageResizeViewModel.Input(
            didTapCancel: mainView.cancelButton.rx.tap.asSignal(),
            didTapDone: mainView.doneButton.rx.tap.asSignal(),
            didCroppedImage: didCroppedImageTrigger.asSignal(),
            didSelectWritingStyle: didSelectWritingStyleTrigger.asSignal(),
            didSelectLanguage: didSelectLanguageTrigger.asSignal(),
            didTapSelectAdditionalData: mainView.selectEntityButton.rx.tap.asSignal()
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        output.selectedAdditionalDataEntity
            .drive(Binder(mainView.selectEntityButton) { base, entity in
                base.entity = entity
            })
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
            .withLatestFrom(output.originalImage)
            .take(1)
            .bind(to: Binder(self) { base, image in
                base.makeCropView(image: image)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: Public
extension AssistantImageResizeViewController {
    static func make(fromCamera: AssistantCameraViewController.Result) -> AssistantImageResizeViewController {
        AssistantImageResizeViewController(fromCamera: fromCamera)
    }
}

// MARK: CropViewControllerDelegate
extension AssistantImageResizeViewController: CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        mainView.update(cropInfo: cropInfo)
        didCroppedImageTrigger.accept(cropped)
    }
    
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
        didCroppedImageTrigger.accept(original)
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {}
}

// MARK: Private
private extension AssistantImageResizeViewController {
    func route(_ route: AssistantImageResizeViewModel.Route) {
        switch route {
        case .cancel:
            didCancel?()
        case .selectWritingStyle(let mode, let style):
            let vc = SWMViewController.make(mode: mode, style: style) { [weak self] result in
                self?.didSelectWritingStyleTrigger.accept(result)
            }
            present(vc, animated: false)
        case .selectLanguage(let language):
            let vc = SLViewController.make(language: language) { [weak self] language in
                self?.didSelectLanguageTrigger.accept(language)
            }
            present(vc, animated: false)
        }
    }
    
    func action(_ action: AssistantImageResizeViewModel.Action) {
        switch action {
        case .crop:
            cropVC?.crop()
            animate(true)
        case .error:
            animate(false)
            
            let vc = ACEViewController.make { [weak self] in
                self?.didCancel?()
            }
            present(vc, animated: false)
        case .result(let result):
            didResult?(result)
            animate(false)
        }
    }
    
    func makeCropView(image: UIImage) {
        var cropViewConfig = CropViewConfig()
        cropViewConfig.showAttachedRotationControlView = false
        
        var config = Config()
        config.showAttachedCropToolbar = false
        config.cropViewConfig = cropViewConfig
        
        let cropVC = Mantis.cropViewController(image: image, config: config)
        cropVC.delegate = self
        
        self.cropVC = cropVC
        
        addChild(cropVC)
        cropVC.view.frame = mainView.imageContainer.bounds
        mainView.imageContainer.addSubview(cropVC.view)
        cropVC.willMove(toParent: self)
    }
    
    func animate(_ animate: Bool) {
        animate ? mainView.animateView.animate() : mainView.animateView.cancel()
        
        mainView.cancelButton.isHidden = animate
        mainView.doneButton.isHidden = animate
    }
}
