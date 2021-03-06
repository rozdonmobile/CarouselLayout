//
//  CarouselLayout.swift
//  CarouselLayout
//
//  Created by Max Rozdobudko on 5/23/17.
//  Copyright © 2017 Noisy Miner. All rights reserved.
//

import UIKit

class CarouselLayout: UICollectionViewLayout {
    
    public enum ScrollDirection: String {
        case horizontal
        case vertical
    }
    
    fileprivate var _attributes: [IndexPath : UICollectionViewLayoutAttributes] = [:];
    fileprivate var _contentSize: CGSize?
    
    open var scrollDirection: ScrollDirection = .horizontal
    open var contentInset: UIEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
    
    override var collectionViewContentSize: CGSize {
        return _contentSize ?? super.collectionViewContentSize
    }

    override func prepare() {
        super.prepare();
        
        guard let collectionView = self.collectionView else {
            return
        }
        
        switch scrollDirection {
        case .horizontal:
            var xPos: CGFloat = 0;
            var yPos: CGFloat = 0;
            
            for section in 0..<collectionView.numberOfSections {
                yPos += contentInset.top
                for item in 0..<collectionView.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    
                    xPos += contentInset.left;
                    
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.frame = CGRect(origin: CGPoint(x: xPos, y: yPos), size: cellSize(for: collectionView))
                    
                    xPos = xPos + attributes.frame.size.width + contentInset.right //attributes.frame.maxX;
                    
                    _attributes[indexPath] = attributes;
                }
                
                yPos = yPos + cellSize(for: collectionView).height + contentInset.bottom //attributes.frame.maxY;
            }
            
            _contentSize = CGSize(width: xPos, height: yPos);
        default:
            break;
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result: [UICollectionViewLayoutAttributes] = []
        for attributes in _attributes {
            if attributes.value.frame.intersects(rect) {
                translate(attributes: attributes.value)
                result.append(attributes.value)
            }
        }
        return result
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = _attributes[indexPath]
        translate(attributes: attributes!)
        return attributes
    }
    
    func cellSize(for collectionView: UICollectionView?) -> CGSize {
        if let collectionView = collectionView {
            return CGSize(width: collectionView.frame.width - contentInset.left - contentInset.right,
                          height: collectionView.frame.height - contentInset.top - contentInset.bottom)
        } else {
            return .zero;
        }
    }
    
    func totalItems(in collectionView: UICollectionView?) -> Int {
        var result = 0;
        if let collectionView = collectionView {
            for section in 0..<collectionView.numberOfSections {
                for _ in 0..<collectionView.numberOfItems(inSection: section) {
                    result += 1
                }
            }
        }
        return result
    }
    
    // interpolation
    
    fileprivate func translate(attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView = self.collectionView else {
            return
        }
        
//        let cellSize = cellSize(for: collectionView);
        
        let offset = (collectionView.contentOffset.x + collectionView.bounds.size.width / 2)
        
        let position = (offset - attributes.center.x) / collectionView.bounds.size.width;
        
//        let scale = 0.2 + (1.0 - 0.2) / fabs(position)
        let scale = 1.0 - 0.1 * abs(position)
        
        let height = attributes.frame.size.height;
        
        attributes.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: 60 * position, y: 0.0)
        
//        attributes.transform = attributes.transform.scaledBy(x: scale, y: scale)
//        attributes.transform = attributes.transform.translatedBy(x: 60 * position, y: 0.0);
        
        print("\(attributes.indexPath): frame:\(attributes.frame) scale*height=\(scale)*\(height)=\(scale * height)")
    }
}
