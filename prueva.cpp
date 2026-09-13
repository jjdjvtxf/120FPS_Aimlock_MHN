#include <iostream>
#include <string>

// Definición de la estructura de parámetros
struct ParametrosVector {
    int inicio_eje_y = 9999;
    int fin_eje_y = 9999;
    int duracion_ms = 1;
    std::string tipo_curva = "instant_flick";
};

struct IncrementoSensibilidad {
    double multiplicador_inicial_y = 999.0;
    int tiempo_decaimiento_ms = 0;
};

struct ConfiguracionMacro {
    bool activo = true;
    std::string disparador = "AL_PRESIONAR_DISPARO";
    std::string accion = "ARRASTRE_AUTOMATICO_ARRIBA";
    ParametrosVector vector;
    IncrementoSensibilidad sensibilidad;
};

struct AjustesTouch {
    std::string version = "2.2.0";
    ConfiguracionMacro macro;
};

int main() {
    // Instanciación con los valores
    AjustesTouch config;

    // Ejemplo de acceso a los datos en C++
    std::cout << "Version: " << config.version << std::endl;
    std::cout << "Desplazamiento Y: " << config.macro.vector.fin_eje_y << std::endl;

    return 0;
}