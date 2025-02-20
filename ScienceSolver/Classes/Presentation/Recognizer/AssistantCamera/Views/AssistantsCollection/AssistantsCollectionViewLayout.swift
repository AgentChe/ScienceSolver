//
//  AssistantsCollectionViewLayout.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 19.02.2025.
//

import UIKit

final class AssistantsCollectionViewLayout: UICollectionViewFlowLayout {
    private var mostRecentOffset: CGPoint = .zero

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        
        // Получаем границы коллекции
        let collectionViewBounds = collectionView.bounds
        let halfWidth = collectionViewBounds.size.width * 0.5
        
        // Получаем атрибуты видимых элементов
        guard let attributesForVisibleCells = layoutAttributesForElements(in: collectionViewBounds) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        // Определяем ближайший элемент к центру
        var closestAttributes: UICollectionViewLayoutAttributes?
        var minimumDistance: CGFloat = .greatestFiniteMagnitude
        
        for attributes in attributesForVisibleCells {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            // Расстояние от центра коллекции до центра ячейки
            let distance = attributes.center.x - (collectionView.contentOffset.x + halfWidth)
            
            if abs(distance) < minimumDistance {
                minimumDistance = abs(distance)
                closestAttributes = attributes
            }
        }
        
        guard let targetAttributes = closestAttributes else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        // Обновляем смещение для центрирования ячейки
        mostRecentOffset = CGPoint(x: targetAttributes.center.x - halfWidth, y: proposedContentOffset.y)
        
        return mostRecentOffset
    }
}
