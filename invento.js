// ===================================================
//  MHN ECLIPSE - CONFIGURACIÓN DE PANTALLA TÁCTIL v2.2.0
// ===================================================

const configuracionEclipse = {
  version: "2.2.0",
  configuracion_pantalla_tactil: {
    flick_multidireccional: {
      estado: true,
      sensibilidad_maxima: 150000,
      ejes: ["arriba", "abajo", "izquierda", "derecha"],
      fuerza_respuesta: 150000
    },
    gestos_movimiento: {
      modo: "pantalla_tactil",
      sensibilidad_gesto: 150000,
      patrones: [
        {
          nombre: "eje_vertical",
          direccion: ["arriba", "abajo"],
          velocidad: 150000
        },
        {
          nombre: "eje_horizontal",
          direccion: ["izquierda", "derecha"],
          velocidad: 150000
        }
      ]
    },
    multiplicador_de_desplazamiento: {
      estado: true,
      escalado_entrada_salida: {
        distancia_fisica_mm: 1,
        distancia_virtual_pixel: 100000,
        factor_multiplicador: 100
      },
      sensibilidad_eje_x: 150000,
      sensibilidad_eje_y: 150000
    },
    ajuste_precision: {
      estado: true,
      suavizado_curva: 0.95,
      radio_zona_muerta: 0.05
    },
    macro_tactil: {
      estado: true,
      modo_ejecucion: "toque_continuo",
      frecuencia_hz: 120,
      puntos_de_contacto: [
        {
          accion: "toque_primario",
          coordenada_x: 500,
          coordenada_y: 1200,
          presion: 150000
        },
        {
          accion: "toque_secundario",
          coordenada_x: 800,
          coordenada_y: 1200,
          presion: 150000
        }
      ]
    }
  }
};

// Exportar configuración para Node.js o entornos de servidor
if (typeof module !== "undefined" && module.exports) {
  module.exports = configuracionEclipse;
}