from appium import webdriver
from appium.options.ios import AppiumOptions

# 1. Configurar las capacidades del dispositivo y el framework
options = AppiumOptions()
options.platform_name = "iOS"
options.device_name = "iPhone"
options.automation_name = "XCUITest"
# Reemplaza con el UDID (identificador único) de tu iPhone físico conectado por USB
options.set_capability("udid", "TU_UDID_AQUÍ") 

# 2. Conectarse al servidor local de Appium (generalmente en el puerto 4723)
driver = webdriver.Remote("http://127.0.0.1:4723", options=options)

try:
    print("Conexión exitosa con el iPhone. Ejecutando gesto de deslizamiento...")
    
    # 3. Ejecutar un comando nativo de XCUITest para deslizar la pantalla de derecha a izquierda
    driver.execute_script("mobile: swipe", {
        "direction": "left",
        "velocity": 2500
    })
    
    print("Gesto ejecutado correctamente.")

finally:
    # 4. Cerrar la sesión de forma limpia
    driver.quit()