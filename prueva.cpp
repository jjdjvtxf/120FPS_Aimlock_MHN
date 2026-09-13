#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <memory>

// Estructura para vectores 2D
struct Vector2 {
float x, y;

```
Vector2(float x = 0, float y = 0) : x(x), y(y) {}

float magnitude() const {
    return std::sqrt(x * x + y * y);
}

Vector2 normalized() const {
    float mag = magnitude();
    if (mag > 0) return Vector2(x / mag, y / mag);
    return Vector2(0, 0);
}

Vector2 operator-(const Vector2& other) const {
    return Vector2(x - other.x, y - other.y);
}

Vector2 operator+(const Vector2& other) const {
    return Vector2(x + other.x, y + other.y);
}

Vector2 operator*(float scalar) const {
    return Vector2(x * scalar, y * scalar);
}

float distance(const Vector2& other) const {
    return (*this - other).magnitude();
}
```

};

// Clase Enemigo
class Enemy {
public:
Vector2 position;
float health;
float maxHealth;
float size;
bool isAlive;
bool isTargeted;

```
Enemy(Vector2 pos, float hp = 100.0f, float sz = 25.0f) 
    : position(pos), health(hp), maxHealth(hp), size(sz), 
      isAlive(true), isTargeted(false) {}

void takeDamage(float damage) {
    health -= damage;
    if (health <= 0) {
        health = 0;
        isAlive = false;
    }
}

float getHealthPercent() const {
    return health / maxHealth;
}
```

};

// Sistema de Auto-Apuntado
class AutoAimSystem {
private:
float aimAssistStrength;      // 0.99 = 99% de asistencia
float detectionRange;         // Rango de detección
float smoothSpeed;            // Velocidad de suavizado
bool enabled;

public:
AutoAimSystem(float assist = 0.99f, float range = 400.0f, float smooth = 0.95f)
: aimAssistStrength(assist), detectionRange(range),
smoothSpeed(smooth), enabled(true) {}

```
// Configuración
void setEnabled(bool state) { enabled = state; }
bool isEnabled() const { return enabled; }
void setAimAssist(float value) { aimAssistStrength = std::clamp(value, 0.0f, 1.0f); }
float getAimAssist() const { return aimAssistStrength; }

// Encuentra el mejor objetivo
Enemy* findBestTarget(const Vector2& playerPos, const Vector2& cursorPos, 
                      std::vector<std::unique_ptr<Enemy>>& enemies) {
    if (!enabled || enemies.empty()) return nullptr;
    
    Enemy* bestTarget = nullptr;
    float closestDistance = detectionRange;
    
    // Resetear todos los targets
    for (auto& enemy : enemies) {
        enemy->isTargeted = false;
    }
    
    // Buscar el enemigo más cercano al cursor
    for (auto& enemy : enemies) {
        if (!enemy->isAlive) continue;
        
        float distToCursor = enemy->position.distance(cursorPos);
        float distToPlayer = enemy->position.distance(playerPos);
        
        // Priorizar enemigos cercanos al cursor y dentro del rango
        if (distToCursor < closestDistance && distToPlayer < detectionRange * 1.5f) {
            closestDistance = distToCursor;
            bestTarget = enemy.get();
        }
    }
    
    if (bestTarget) {
        bestTarget->isTargeted = true;
    }
    
    return bestTarget;
}

// Calcula el ángulo con auto-aim aplicado
float calculateAimAngle(const Vector2& playerPos, const Vector2& cursorPos, 
                       Enemy* target, float currentAngle) {
    // Ángulo hacia el cursor
    Vector2 toMouse = cursorPos - playerPos;
    float mouseAngle = std::atan2(toMouse.y, toMouse.x);
    
    // Si hay un objetivo y el auto-aim está activo
    if (target && enabled) {
        Vector2 toTarget = target->position - playerPos;
        float targetAngle = std::atan2(toTarget.y, toTarget.x);
        
        // Interpolar entre cursor (1%) y objetivo (99%)
        float finalAngle = mouseAngle * (1.0f - aimAssistStrength) + 
                          targetAngle * aimAssistStrength;
        
        // Suavizado de rotación
        float angleDiff = finalAngle - currentAngle;
        
        // Normalizar diferencia de ángulo
        while (angleDiff > M_PI) angleDiff -= 2 * M_PI;
        while (angleDiff < -M_PI) angleDiff += 2 * M_PI;
        
        return currentAngle + angleDiff * smoothSpeed;
    }
    
    // Sin auto-aim, seguir el cursor con suavizado
    float angleDiff = mouseAngle - currentAngle;
    while (angleDiff > M_PI) angleDiff -= 2 * M_PI;
    while (angleDiff < -M_PI) angleDiff += 2 * M_PI;
    
    return currentAngle + angleDiff * smoothSpeed;
}

// Predicción de posición del enemigo (opcional, para movimiento)
Vector2 predictTargetPosition(Enemy* target, float bulletSpeed, 
                              const Vector2& playerPos) {
    if (!target) return Vector2(0, 0);
    
    // Aquí puedes añadir predicción de movimiento
    // Por ahora retorna la posición actual
    return target->position;
}
```

};

// Clase Jugador
class Player {
public:
Vector2 position;
float aimAngle;
float size;
int shotsCount;
int hitsCount;

```
Player(Vector2 pos, float sz = 20.0f) 
    : position(pos), aimAngle(0), size(sz), 
      shotsCount(0), hitsCount(0) {}

void shoot() {
    shotsCount++;
}

void registerHit() {
    hitsCount++;
}

float getAccuracy() const {
    if (shotsCount == 0) return 0.0f;
    return (static_cast<float>(hitsCount) / shotsCount) * 100.0f;
}

Vector2 getBarrelEnd() const {
    float barrelLength = 30.0f;
    return Vector2(
        position.x + std::cos(aimAngle) * barrelLength,
        position.y + std::sin(aimAngle) * barrelLength
    );
}
```

};

// Clase Bala
class Bullet {
public:
Vector2 position;
Vector2 velocity;
float damage;
float size;
bool isActive;

```
Bullet(Vector2 pos, float angle, float speed = 10.0f, float dmg = 34.0f) 
    : position(pos), damage(dmg), size(5.0f), isActive(true) {
    velocity = Vector2(std::cos(angle) * speed, std::sin(angle) * speed);
}

void update() {
    position = position + velocity;
}

bool checkCollision(Enemy* enemy) {
    if (!enemy || !enemy->isAlive) return false;
    
    float dist = position.distance(enemy->position);
    return dist < (size + enemy->size);
}
```

};

// Demostración del sistema
int main() {
std::cout << “=== SISTEMA DE AUTO-APUNTADO AL 99% ===” << std::endl;
std::cout << “========================================\n” << std::endl;

```
// Crear jugador en el centro del "mapa"
Player player(Vector2(400, 300));

// Crear sistema de auto-aim con 99% de precisión
AutoAimSystem autoAim(0.99f, 400.0f, 0.95f);

// Crear enemigos de ejemplo
std::vector<std::unique_ptr<Enemy>> enemies;
enemies.push_back(std::make_unique<Enemy>(Vector2(600, 200)));
enemies.push_back(std::make_unique<Enemy>(Vector2(500, 400)));
enemies.push_back(std::make_unique<Enemy>(Vector2(300, 150)));

// Simular cursor del jugador
Vector2 cursorPos(550, 250);

std::cout << "Configuración:" << std::endl;
std::cout << "- Asistencia de apuntado: " << (autoAim.getAimAssist() * 100) << "%" << std::endl;
std::cout << "- Posición jugador: (" << player.position.x << ", " << player.position.y << ")" << std::endl;
std::cout << "- Posición cursor: (" << cursorPos.x << ", " << cursorPos.y << ")" << std::endl;
std::cout << "- Enemigos activos: " << enemies.size() << "\n" << std::endl;

// Simular varios frames del juego
for (int frame = 0; frame < 60; frame++) {
    // Buscar mejor objetivo
    Enemy* target = autoAim.findBestTarget(player.position, cursorPos, enemies);
    
    // Calcular nuevo ángulo de apuntado
    player.aimAngle = autoAim.calculateAimAngle(
        player.position, cursorPos, target, player.aimAngle
    );
    
    // Mostrar información cada 10 frames
    if (frame % 10 == 0) {
        std::cout << "Frame " << frame << ":" << std::endl;
        
        if (target) {
            std::cout << "  ✓ Objetivo detectado en: (" 
                     << target->position.x << ", " << target->position.y << ")" << std::endl;
            std::cout << "  - Salud del objetivo: " 
                     << (target->getHealthPercent() * 100) << "%" << std::endl;
        } else {
            std::cout << "  ✗ Sin objetivo disponible" << std::endl;
        }
        
        std::cout << "  - Ángulo de apuntado: " 
                 << (player.aimAngle * 180.0f / M_PI) << "°" << std::endl;
        std::cout << std::endl;
    }
}

// Simular disparos
std::cout << "\n=== SIMULACIÓN DE DISPAROS ===" << std::endl;

for (int shot = 0; shot < 5; shot++) {
    Enemy* target = autoAim.findBestTarget(player.position, cursorPos, enemies);
    
    if (target) {
        player.shoot();
        
        // Crear bala
        Bullet bullet(player.getBarrelEnd(), player.aimAngle);
        
        // Simular trayectoria
        bool hit = false;
        for (int i = 0; i < 100 && bullet.isActive; i++) {
            bullet.update();
            
            if (bullet.checkCollision(target)) {
                target->takeDamage(bullet.damage);
                player.registerHit();
                hit = true;
                bullet.isActive = false;
                
                std::cout << "Disparo " << (shot + 1) << ": ¡IMPACTO! ";
                std::cout << "Daño: " << bullet.damage << " HP ";
                std::cout << "(Enemigo HP: " << target->health << "/" << target->maxHealth << ")";
                
                if (!target->isAlive) {
                    std::cout << " [ELIMINADO]";
                }
                std::cout << std::endl;
                break;
            }
        }
        
        if (!hit) {
            std::cout << "Disparo " << (shot + 1) << ": Falló" << std::endl;
        }
    }
}

// Estadísticas finales
std::cout << "\n=== ESTADÍSTICAS FINALES ===" << std::endl;
std::cout << "Total de disparos: " << player.shotsCount << std::endl;
std::cout << "Impactos: " << player.hitsCount << std::endl;
std::cout << "Precisión real: " << player.getAccuracy() << "%" << std::endl;
std::cout << "Auto-Aim activo: " << (autoAim.isEnabled() ? "SÍ" : "NO") << std::endl;
std::cout << "Nivel de asistencia: " << (autoAim.getAimAssist() * 100) << "%" << std::endl;

int aliveEnemies = 0;
for (const auto& enemy : enemies) {
    if (enemy->isAlive) aliveEnemies++;
}
std::cout << "Enemigos restantes: " << aliveEnemies << "/" << enemies.size() << std::endl;

return 0;
```

}