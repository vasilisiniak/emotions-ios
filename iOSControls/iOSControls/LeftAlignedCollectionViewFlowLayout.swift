import UIKit

public class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    // MARK: - UICollectionViewLayout

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var lastY: CGFloat?

        return attributes?.map {
            let attribute = $0.copy() as! UICollectionViewLayoutAttributes

            if attribute.frame.origin.y != lastY {
                lastY = attribute.frame.origin.y
                leftMargin = sectionInset.left
            }

            attribute.frame.origin.x = leftMargin
            leftMargin += attribute.frame.width + minimumInteritemSpacing

            return attribute
        }
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        layoutAttributesForElements(in: UIScreen.main.bounds)?.first { $0.indexPath == indexPath }
    }
}
