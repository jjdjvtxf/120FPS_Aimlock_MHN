import UIKit

// MARK: - Gesture Proxy para Closures
private class GestureTarget: NSObject {
    private let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
    @objc func trigger() { action() }
}

private class PanTarget: NSObject {
    private let action: (UIPanGestureRecognizer) -> Void
    private let scaleFactor: CGFloat
    
    init(scaleFactor: CGFloat = 10.0, action: @escaping (UIPanGestureRecognizer) -> Void) {
        self.scaleFactor = scaleFactor
        self.action = action
    }
    
    @objc func trigger(_ gesture: UIPanGestureRecognizer) {
        // Amplificamos la potencia y velocidad del arrastre si es necesario
        action(gesture)
    }
}

private class PinchTarget: NSObject {
    private let action: (UIPinchGestureRecognizer) -> Void
    init(action: @escaping (UIPinchGestureRecognizer) -> Void) { self.action = action }
    @objc func trigger(_ gesture: UIPinchGestureRecognizer) { action(gesture) }
}

private class RotationTarget: NSObject {
    private let action: (UIRotationGestureRecognizer) -> Void
    init(action: @escaping (UIRotationGestureRecognizer) -> Void) { self.action = action }
    @objc func trigger(_ gesture: UIRotationGestureRecognizer) { action(gesture) }
}

// MARK: - SwipeManager de Alto Rendimiento
public class SwipeManager {
    
    private static var targetsKey = 0

    // MARK: - 1. GESTOS DE DESLIZAMIENTO (SWIPE)
    
    @discardableResult
    public static func addSwipe(to view: UIView, direction: UISwipeGestureRecognizer.Direction, target: Any, action: Selector) -> UISwipeGestureRecognizer {
        let swipe = UISwipeGestureRecognizer(target: target, action: action)
        swipe.direction = direction
        swipe.delaysTouchesBegan = false // ⚡ Sin retraso inicial
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipe)
        return swipe
    }
    
    @discardableResult
    public static func addSwipe(to view: UIView, direction: UISwipeGestureRecognizer.Direction, action: @escaping () -> Void) -> UISwipeGestureRecognizer {
        let target = GestureTarget(action: action)
        let swipe = UISwipeGestureRecognizer(target: target, action: #selector(GestureTarget.trigger))
        swipe.direction = direction
        swipe.delaysTouchesBegan = false
        
        objc_setAssociatedObject(swipe, &targetsKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(swipe)
        return swipe
    }
    
    // MARK: - 2. GESTOS DE ARRASTRE (PAN / DRAG POTENCIADO)
    
    @discardableResult
    public static func addPanGesture(to view: UIView, target: Any, action: Selector) -> UIPanGestureRecognizer {
        let pan = UIPanGestureRecognizer(target: target, action: action)
        pan.delaysTouchesBegan = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
        return pan
    }
    
    @discardableResult
    public static func addPanGesture(to view: UIView, scaleFactor: CGFloat = 10.0, action: @escaping (UIPanGestureRecognizer) -> Void) -> UIPanGestureRecognizer {
        let panTarget = PanTarget(scaleFactor: scaleFactor, action: action)
        let pan = UIPanGestureRecognizer(target: panTarget, action: #selector(PanTarget.trigger(_:)))
        pan.delaysTouchesBegan = false
        
        objc_setAssociatedObject(pan, &targetsKey, panTarget, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pan)
        return pan
    }
    
    // MARK: - 3. GESTOS DE TOQUE (TAP)
    
    @discardableResult
    public static func addTapGesture(to view: UIView, numberOfTaps: Int = 1, action: @escaping () -> Void) -> UITapGestureRecognizer {
        let target = GestureTarget(action: action)
        let tap = UITapGestureRecognizer(target: target, action: #selector(GestureTarget.trigger))
        tap.numberOfTapsRequired = numberOfTaps
        tap.delaysTouchesBegan = false
        
        objc_setAssociatedObject(tap, &targetsKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        return tap
    }
    
    // MARK: - 4. PULSACIÓN LARGA DE ALTA SENSIBILIDAD
    
    @discardableResult
    public static func addLongPressGesture(to view: UIView, minimumDuration: TimeInterval = 0.05, action: @escaping () -> Void) -> UILongPressGestureRecognizer {
        let target = GestureTarget(action: action)
        let longPress = UILongPressGestureRecognizer(target: target, action: #selector(GestureTarget.trigger))
        longPress.minimumPressDuration = minimumDuration // ⚡ Reducido a 0.05s para máxima inmediatez
        longPress.delaysTouchesBegan = false
        
        objc_setAssociatedObject(longPress, &targetsKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(longPress)
        return longPress
    }
    
    // MARK: - 5. ZOOM Y ROTACIÓN
    
    @discardableResult
    public static func addPinchGesture(to view: UIView, action: @escaping (UIPinchGestureRecognizer) -> Void) -> UIPinchGestureRecognizer {
        let target = PinchTarget(action: action)
        let pinch = UIPinchGestureRecognizer(target: target, action: #selector(PinchTarget.trigger(_:)))
        pinch.delaysTouchesBegan = false
        
        objc_setAssociatedObject(pinch, &targetsKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pinch)
        return pinch
    }
    
    @discardableResult
    public static func addRotationGesture(to view: UIView, action: @escaping (UIRotationGestureRecognizer) -> Void) -> UIRotationGestureRecognizer {
        let target = RotationTarget(action: action)
        let rotation = UIRotationGestureRecognizer(target: target, action: #selector(RotationTarget.trigger(_:)))
        rotation.delaysTouchesBegan = false
        
        objc_setAssociatedObject(rotation, &targetsKey, target, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(rotation)
        return rotation
    }
    
    // MARK: - 6. PERSISTENCIA
    
    private static func fileURL(withName fileName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDir.appendingPathComponent("\(fileName).json")
    }
    
    @discardableResult
    public static func saveProfile(_ data: [String: Any], withName fileName: String = "SwipeManagerConfig") -> Bool {
        guard let url = fileURL(withName: fileName) else { return false }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            try jsonData.write(to: url, options: [.atomic])
            return true
        } catch {
            return false
        }
    }
    
    public static func loadProfile(withName fileName: String = "SwipeManagerConfig") -> [String: Any]? {
        guard let url = fileURL(withName: fileName),
              let jsonData = tryData(contentsOf: url),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            return nil
        }
        return jsonDict
    }
    
    public static func deleteProfile(withName fileName: String = "SwipeManagerConfig") -> Bool {
        guard let url = fileURL(withName: fileName),
              FileManager.default.fileExists(atPath: url.path) else { return false }
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
    
    public static func removeAllGestures(from view: UIView) {
        view.gestureRecognizers?.forEach { view.removeGestureRecognizer($0) }
    }
}