import UIKit

// MARK: - Gesture Proxy para Closures (Evita memory leaks y simplifica el código)
private class GestureTarget: NSObject {
    private let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    @objc func trigger() {
        action()
    }
}

private class PanTarget: NSObject {
    private let action: (UIPanGestureRecognizer) -> Void
    
    init(action: @escaping (UIPanGestureRecognizer) -> Void) {
        self.action = action
    }
    
    @objc func trigger(_ gesture: UIPanGestureRecognizer) {
        action(gesture)
    }
}

private class PinchTarget: NSObject {
    private let action: (UIPinchGestureRecognizer) -> Void
    
    init(action: @escaping (UIPinchGestureRecognizer) -> Void) {
        self.action = action
    }
    
    @objc func trigger(_ gesture: UIPinchGestureRecognizer) {
        action(gesture)
    }
}

private class RotationTarget: NSObject {
    private let action: (UIRotationGestureRecognizer) -> Void
    
    init(action: @escaping (UIRotationGestureRecognizer) -> Void) {
        self.action = action
    }
    
    @objc func trigger(_ gesture: UIRotationGestureRecognizer) {
        action(gesture)
    }
}

// MARK: - SwipeManager Expandido
public class SwipeManager {
    
    // Almacenamiento privado para retener los targets de los gestos basados en closures
    private static var targetsKey = 0
    private static var targetsStorage: [String: Any] = [:]

    // MARK: - 1. GESTOS DE DESLIZAMIENTO (SWIPE)
    
    /// Configura un gesto de deslizamiento tradicional (Target-Action)
    @discardableResult
    public static func addSwipe(to view: UIView, direction: UISwipeGestureRecognizer.Direction, target: Any, action: Selector) -> UISwipeGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer(target: target, action: action)
        swipeGesture.direction = direction
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipeGesture)
        return swipeGesture
    }
    
    /// Configura un deslizamiento utilizando closures (Sin necesidad de @objc)
    @discardableResult
    public static func addSwipe(to view: UIView, direction: UISwipeGestureRecognizer.Direction, action: @escaping () -> Void) -> UISwipeGestureRecognizer {
        let gestureTarget = GestureTarget(action: action)
        let swipeGesture = UISwipeGestureRecognizer(target: gestureTarget, action: #selector(GestureTarget.trigger))
        swipeGesture.direction = direction
        
        // Asociar el target para evitar que se libere de memoria
        objc_setAssociatedObject(swipeGesture, &targetsKey, gestureTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipeGesture)
        return swipeGesture
    }
    
    // MARK: - 2. GESTOS DE ARRASTRE (PAN / DRAG)
    
    /// Configura un gesto de arrastre continuo (Target-Action)
    @discardableResult
    public static func addPanGesture(to view: UIView, target: Any, action: Selector) -> UIPanGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: target, action: action)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
        return panGesture
    }
    
    /// Configura un gesto de arrastre con closure y retorno de velocidad/traslación
    @discardableResult
    public static func addPanGesture(to view: UIView, action: @escaping (UIPanGestureRecognizer) -> Void) -> UIPanGestureRecognizer {
        let panTarget = PanTarget(action: action)
        let panGesture = UIPanGestureRecognizer(target: panTarget, action: #selector(PanTarget.trigger(_:)))
        
        objc_setAssociatedObject(panGesture, &targetsKey, panTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
        return panGesture
    }
    
    // MARK: - 3. GESTOS DE TOQUE (TAP)
    
    /// Agrega un gesto de toque simple o múltiple con closure
    @discardableResult
    public static func addTapGesture(to view: UIView, numberOfTaps: Int = 1, action: @escaping () -> Void) -> UITapGestureRecognizer {
        let gestureTarget = GestureTarget(action: action)
        let tapGesture = UITapGestureRecognizer(target: gestureTarget, action: #selector(GestureTarget.trigger))
        tapGesture.numberOfTapsRequired = numberOfTaps
        
        objc_setAssociatedObject(tapGesture, &targetsKey, gestureTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
        return tapGesture
    }
    
    // MARK: - 4. GESTOS DE PULSACIÓN LARGA (LONG PRESS)
    
    /// Agrega un gesto de mantener presionado
    @discardableResult
    public static func addLongPressGesture(to view: UIView, minimumDuration: TimeInterval = 0.5, action: @escaping () -> Void) -> UILongPressGestureRecognizer {
        let gestureTarget = GestureTarget(action: action)
        let longPress = UILongPressGestureRecognizer(target: gestureTarget, action: #selector(GestureTarget.trigger))
        longPress.minimumPressDuration = minimumDuration
        
        objc_setAssociatedObject(longPress, &targetsKey, gestureTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(longPress)
        return longPress
    }
    
    // MARK: - 5. GESTOS DE ZOOM Y ROTACIÓN (PINCH & ROTATE)
    
    /// Agrega un gesto de pellizcar (Pinch / Zoom)
    @discardableResult
    public static func addPinchGesture(to view: UIView, action: @escaping (UIPinchGestureRecognizer) -> Void) -> UIPinchGestureRecognizer {
        let pinchTarget = PinchTarget(action: action)
        let pinchGesture = UIPinchGestureRecognizer(target: pinchTarget, action: #selector(PinchTarget.trigger(_:)))
        
        objc_setAssociatedObject(pinchGesture, &targetsKey, pinchTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pinchGesture)
        return pinchGesture
    }
    
    /// Agrega un gesto de rotación con dos dedos
    @discardableResult
    public static func addRotationGesture(to view: UIView, action: @escaping (UIRotationGestureRecognizer) -> Void) -> UIRotationGestureRecognizer {
        let rotationTarget = RotationTarget(action: action)
        let rotationGesture = UIRotationGestureRecognizer(target: rotationTarget, action: #selector(RotationTarget.trigger(_:)))
        
        objc_setAssociatedObject(rotationGesture, &targetsKey, rotationTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(rotationGesture)
        return rotationGesture
    }
    
    // MARK: - UTILIDADES GENERALES
    
    /// Remueve todos los gestos asociados a una vista
    public static func removeAllGestures(from view: UIView) {
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }
    }
}