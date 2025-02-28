//
//  AssistantCameraView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit

final class AssistantCameraView: UIView {
    lazy var closeButton = makeTapAreaButton(imageName: "AssistantCamera.Close", mode: .other)
    lazy var collectionView = makeCollectionView()
    lazy var wallpapersButton = makeTapAreaButton(imageName: "AssistantCamera.Wallpapers", mode: .other)
    lazy var takeButton = makeTapAreaButton(imageName: "AssistantCamera.Take", mode: .take)
    lazy var flashButton = makeTapAreaButton(imageName: "AssistantCamera.Flash", mode: .other)
    lazy var writingModeView = makeWritingModeView()
    lazy var permissionProblemView = makePermissionProblemView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AssistantCameraView {
    func initialize() {
        backgroundColor = Appearance.mono200
    }
}

// MARK: Make constraints
private extension AssistantCameraView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 40.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 40.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5.scale)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12.scale),
            collectionView.heightAnchor.constraint(equalToConstant: 35.scale)
        ])
        
        NSLayoutConstraint.activate([
            wallpapersButton.widthAnchor.constraint(equalToConstant: 40.scale),
            wallpapersButton.heightAnchor.constraint(equalToConstant: 40.scale),
            wallpapersButton.trailingAnchor.constraint(equalTo: takeButton.leadingAnchor, constant: -32.scale),
            wallpapersButton.centerYAnchor.constraint(equalTo: takeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            takeButton.widthAnchor.constraint(equalToConstant: 72.scale),
            takeButton.heightAnchor.constraint(equalToConstant: 72.scale),
            takeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            takeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -26.scale)
        ])
        
        NSLayoutConstraint.activate([
            flashButton.widthAnchor.constraint(equalToConstant: 40.scale),
            flashButton.heightAnchor.constraint(equalToConstant: 40.scale),
            flashButton.leadingAnchor.constraint(equalTo: takeButton.trailingAnchor, constant: 32.scale),
            flashButton.centerYAnchor.constraint(equalTo: takeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            writingModeView.widthAnchor.constraint(equalToConstant: 172.scale),
            writingModeView.heightAnchor.constraint(equalToConstant: 43.scale),
            writingModeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            writingModeView.bottomAnchor.constraint(equalTo: takeButton.topAnchor, constant: -24.scale)
        ])
        
        NSLayoutConstraint.activate([
            permissionProblemView.leadingAnchor.constraint(equalTo: leadingAnchor),
            permissionProblemView.trailingAnchor.constraint(equalTo: trailingAnchor),
            permissionProblemView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantCameraView {
    func makeTapAreaButton(imageName: String, mode: AssistantCameraActionButton.Mode) -> AssistantCameraActionButton {
        let view = AssistantCameraActionButton(iconName: imageName, mode: mode)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeCollectionView() -> AssistantsCollectionView {
        let layout = AssistantsCollectionViewLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12.scale
        layout.minimumInteritemSpacing = 0
        
        let view = AssistantsCollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.decelerationRate = .fast
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeWritingModeView() -> AssistantCameraWritingModeView {
        let view = AssistantCameraWritingModeView(style: .camera)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePermissionProblemView() -> AssistantCameraPermissionProblemView {
        let view = AssistantCameraPermissionProblemView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
