import UIKit

public class SwipeManager {
    
    /// Configura un gesto de deslizamiento en cualquier vista de forma nativa
    public static func addSwipe(to view: UIView, direction: UISwipeGestureRecognizer.Direction, target: Any, action: Selector) -> UISwipeGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer(target: target, action: action)
        swipeGesture.direction = direction
        view.addGestureRecognizer(swipeGesture)
        return swipeGesture
    }
    
    /// Configura un gesto de arrastre continuo (Pan) para coordenadas libres
    public static func addPanGesture(to view: UIView, target: Any, action: Selector) -> UIPanGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(panGesture)
        return panGesture
    }
}