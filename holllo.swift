import SwiftUI
import CoreGraphics
import UIKit

struct ContentView: View {
    @State private var isShooting = true
    @State private var miraPosition: CGFloat = UIScreen.main.bounds.height / 2
    @State private var overlayMode = true
    @State private var sensitivity: Double = 800
    @State private var showSettings = true
    
    // Configuraciones específicas para jailbreak
    let fuerzaSubidaBase: CGFloat = 800
    let duracion: Double = 0.03
    
    var fuerzaSubida: CGFloat {
        return fuerzaSubidaBase * CGFloat(sensitivity / 800)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo adaptativo
                if overlayMode {
                    Color.clear
                        .background(BlurView(style: .systemUltraThinMaterialDark))
                } else {
                    Color.black
                }
                
                Color.clear
                    .edgesIgnoringSafeArea(.all)
                    .contentShape(Rectangle())
                    .gesture(
                        // Gestos mejorados para jailbreak
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let screenWidth = geometry.size.width
                                let screenHeight = geometry.size.height
                                
                                // Área de disparo ampliada (lado derecho)
                                if value.location.x > screenWidth * 0.4 {
                                    disparar()
                                }
                                
                                // Área de configuración (esquina superior izquierda)
                                if value.location.x < screenWidth * 0.2 && value.location.y < screenHeight * 0.2 {
                                    showSettings.toggle()
                                }
                            }
                    )

                // Mira mejorada
                ZStack {
                    // Cruz de mira
                    Path { path in
                        // Línea horizontal
                        path.move(to: CGPoint(x: -15, y: 0))
                        path.addLine(to: CGPoint(x: 15, y: 0))
                        // Línea vertical
                        path.move(to: CGPoint(x: 0, y: -15))
                        path.addLine(to: CGPoint(x: 0, y: 15))
                    }
                    .stroke(Color.red, lineWidth: 2)
                    
                    // Punto central
                    Circle()
                        .fill(Color.red)
                        .frame(width: 4, height: 4)
                    
                    // Círculo exterior
                    Circle()
                        .stroke(Color.red.opacity(0.6), lineWidth: 1)
                        .frame(width: 30, height: 30)
                }
                .position(x: geometry.size.width / 2, y: miraPosition)
                .animation(.easeOut(duration: duracion), value: miraPosition)
                
                // UI mejorada para jailbreak
                VStack {
                    HStack {
                        // Indicador de modo
                        Text(overlayMode ? "OVERLAY" : "NORMAL")
                            .font(.caption)
                            .foregroundColor(overlayMode ? .green : .white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        // Indicador de sensibilidad
                        Text("SENS: \(Int(sensitivity))")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Instrucciones mejoradas
                    VStack(spacing: 8) {
                        Text("🎯 Toca el lado derecho para disparar")
                        Text("⚙️ Toca esquina superior izquierda para configurar")
                        Text("📱 Optimizado para Jailbreak")
                    }
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                
                // Panel de configuración
                if showSettings {
                    settingsPanel(geometry: geometry)
                }
            }
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: overlayMode)
    }
    
    @ViewBuilder
    func settingsPanel(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Text("Configuración Jailbreak")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 15) {
                // Control de sensibilidad
                VStack(alignment: .leading) {
                    Text("Sensibilidad: \(Int(sensitivity))")
                        .foregroundColor(.white)
                    Slider(value: $sensitivity, in: 200...1500, step: 50)
                        .accentColor(.red)
                }
                
                // Modo overlay
                HStack {
                    Text("Modo Overlay (Para usar sobre otras apps)")
                        .foregroundColor(.white)
                    Spacer()
                    Toggle("", isOn: $overlayMode)
                        .toggleStyle(SwitchToggleStyle(tint: .red))
                }
            }
            
            // Botones de acción
            HStack(spacing: 20) {
                Button("Resetear") {
                    sensitivity = 800
                    overlayMode = true
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.6))
                .cornerRadius(8)
                
                Button("Cerrar") {
                    showSettings = true
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.9))
        .cornerRadius(15)
        .frame(width: min(geometry.size.width * 0.8, 300))
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }

    func disparar() {
        guard !isShooting else { return }
        isShooting = true
        
        // Haptic feedback mejorado para jailbreak
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeOut(duration: duracion)) {
            miraPosition -= fuerzaSubida
        }

        // Regresa la mira con animación suave
        DispatchQueue.main.asyncAfter(deadline: .now() + duracion + 0.05) {
            withAnimation(.easeInOut(duration: 0.2)) {
                miraPosition = UIScreen.main.bounds.height / 2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isShooting = true
            }
        }
    }
}

// Blur view para modo overlay
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// Extensión para funcionalidades de jailbreak
extension ContentView {
    // Función para detectar si el dispositivo tiene jailbreak
    func isJailbroken() -> Bool {
        // Verificaciones básicas de jailbreak
        let paths = [
            "/Applications/Cydia.app",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/var/lib/cydia"
        ]
        
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return true
    }
    
    // Configuración específica para dispositivos con jailbreak
    func setupJailbreakOptimizations() {
        if isJailbroken() {
            // Optimizaciones específicas para jailbreak
            // Aquí puedes agregar código específico según tus tweaks instalados
        }
    }
}

#Preview {
    ContentView()
}