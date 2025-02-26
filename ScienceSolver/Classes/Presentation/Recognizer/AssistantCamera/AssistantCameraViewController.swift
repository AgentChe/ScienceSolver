//
//  AssistantCameraViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI
import AVFoundation

final class AssistantCameraViewController: UIViewController {
    struct Result {
        enum Assistant {
            case math
            case physics
            case biology
            case chemistry
            case writing(WritingMode)
            case language
        }
        
        let image: UIImage
        let assistant: Assistant
    }
    
    var didClose: (() -> Void)?
    var didResult: ((Result) -> Void)?
    
    private lazy var mainView = AssistantCameraView()
    
    private let viewModel: AssistantCameraViewModel
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var cameraService: CameraService = {
        let cameraService = CameraService()
        cameraService.delegate = self
        return cameraService
    }()
    
    private lazy var videoPermissionChangedAccessTrigger = PublishRelay<Void>()
    
    private init(assistant: AssistantsCollectionElement.Assistant?) {
        viewModel = AssistantCameraViewModel(assistant: assistant)
        
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
        
        let output = viewModel.configure(input: AssistantCameraViewModel.Input(
            didTapDismiss: mainView.closeButton.rx.tap.asSignal(),
            didTapSelectImageFromLibrary: mainView.wallpapersButton.rx.tap.asSignal(),
            didSelect: mainView.collectionView.didSelect,
            didTapTakePhoto: mainView.takeButton.rx.tap.asSignal(),
            didTapAllowAccess: mainView.permissionProblemView.allowAccessButton.rx.tap.asSignal(),
            videoPermissionChangedAccess: videoPermissionChangedAccessTrigger.asSignal()
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
        
        output.elements
            .drive(Binder(mainView.collectionView) { base, elements in
                base.setup(elements: elements)
            })
            .disposed(by: disposeBag)
        
        output.writingModeHidden
            .drive(Binder(mainView.writingModeView) { base, hidden in
                base.isHidden = hidden
            })
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
            .take(1)
            .bind(to: Binder(self) { base, _ in
                base.setupCameraLayer()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: AssistantCameraViewController
extension AssistantCameraViewController {
    static func make(assistant: AssistantsCollectionElement.Assistant? = nil) -> AssistantCameraViewController {
        let vc = AssistantCameraViewController(assistant: assistant)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: PHPickerViewControllerDelegate
extension AssistantCameraViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results
            .map (\.itemProvider)
            .filter { $0.canLoadObject(ofClass: UIImage.self) }
            .first
        guard let itemProvider else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    self?.complete(image: image)
                }
            }
        }
    }
}

// MARK: CameraServiceDelegate
extension AssistantCameraViewController: CameraServiceDelegate {
    func setPhoto(image: UIImage) {
        complete(image: image)
    }
}

// MARK: Private
private extension AssistantCameraViewController {
    func route(_ route: AssistantCameraViewModel.Route) {
        switch route {
        case .dismiss:
            didClose?()
        case .selectImageFromLibrary:
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            configuration.preferredAssetRepresentationMode = .automatic
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            present(picker, animated: true)
        case .requestPermissionInSettings:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func action(_ action: AssistantCameraViewModel.Action) {
        switch action {
        case .takePhoto:
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .off
            cameraService.photoOutput.capturePhoto(with: photoSettings, delegate: cameraService)
        }
    }
    
    func complete(image: UIImage?) {
        guard let image, let element = mainView.collectionView.elements.first(where: { $0.marked })?.assistant else { return }
        
        let assistant: Result.Assistant = {
            switch element {
            case .math:
                return .math
            case .physics:
                return .physics
            case .biology:
                return .biology
            case .chemistry:
                return .chemistry
            case .writing:
                return .writing(mainView.writingModeView.mode)
            case .language:
                return .language
            }
        }()
        
        let result = Result(image: image, assistant: assistant)
        
        didResult?(result)
    }
    
    func setupCameraLayer() {
        func ui(authorized: Bool) {
            mainView.permissionProblemView.isHidden = authorized
            mainView.takeButton.isHidden = !authorized
            mainView.wallpapersButton.isHidden = !authorized
            mainView.flashButton.isHidden = !authorized
            
            if authorized {
                let previewLayer = AVCaptureVideoPreviewLayer(session: cameraService.captureSession) as AVCaptureVideoPreviewLayer
                previewLayer.frame = mainView.bounds
                previewLayer.videoGravity = .resizeAspectFill
                mainView.layer.insertSublayer(previewLayer, at: 0)
            }
        }
        
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthStatus {
        case .authorized:
            ui(authorized: true)
        case .notDetermined:
            ui(authorized: false)
            
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authorized in
                ui(authorized: authorized)
                self?.videoPermissionChangedAccessTrigger.accept(Void())
            }
        default:
            ui(authorized: false)
        }
    }
}
