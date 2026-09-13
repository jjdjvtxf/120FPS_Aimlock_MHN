#include <iostream>
#include <string>

// Estructura para los parámetros del vector
struct VectorParameters {
    int start_axis_y = 0;
    int end_axis_y = -150;
    int duration_ms = 15;
    std::string curve = "instant_flick";
};

// Estructura para el incremento de sensibilidad
struct SensitivityBoost {
    double initial_y_multiplier = 3.0;
    int decay_time_ms = 50;
};

// Estructura para el bloque principal de la macro
struct TouchMacro {
    bool enabled = true;
    std::string trigger = "ON_FIRE_BUTTON_DOWN";
    std::string action = "AUTO_DRAG_UP";
    VectorParameters vector_parameters;
    SensitivityBoost sensitivity_boost;
};

// Estructura principal de la configuración
struct TouchConfig {
    std::string version = "2.2.0";
    TouchMacro touch_macro;
};

int main() {
    TouchConfig config;

    // Lectura de los datos cargados en la estructura C++
    std::cout << "Version: " << config.version << std::endl;
    std::cout << "Trigger: " << config.touch_macro.trigger << std::endl;
    std::cout << "End Axis Y: " << config.touch_macro.vector_parameters.end_axis_y << std::endl;
    std::cout << "Initial Y Multiplier: " << config.touch_macro.sensitivity_boost.initial_y_multiplier << std::endl;

    return 0;
}