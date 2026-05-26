# 🚀 CETI Business SuperApp — Manual de Despliegue Transversal

**Autor del Handover:** Antigravity AI  
**Desarrollador Responsable / Administrador de Nube:** Erick Alexander Turcios Melendez  
**Fase de Software:** Producción Comercial (Code Freeze Certificado)  
**Entorno Principal:** Flutter Nativo (Android / iOS Híbrido) + Cloud Firestore + Firebase Crashlytics

---

## 1. Topología de Datos Dinámicos (Cloud Configuration)
El ecosistema CRM y POS de CETI ha sido diseñado con una arquitectura Reactiva *Schema-less* en Cloud Firestore. Esto te permite inyectar nuevas funcionalidades sin requerir una re-compilación del ejecutable binario.

### Estructura Dinámica de `customers`
La estructura base del documento en Firestore es:
```json
{
  "firstName": "String",
  "lastName": "String",
  "email": "String",
  "phone": "String",
  "birthDate": "Timestamp",
  "points": "Number",
  "tier": "String (Bronce | Plata | Oro)",
  "nfcTagId": "String (Opcional - Hex UID Físico)",
  "walletPassId": "String",
  "customFields": "Map<String, Dynamic>"
}
```
**Inyección de `customFields` en caliente:**  
A través de la consola de Firebase, puedes agregar un objeto JSON en `customFields` para un cliente. La UI de `loyalty_screen.dart` está mapeada dinámicamente:
```json
"customFields": {
  "Alergias": "Lactosa, Maní",
  "Sucursal Preferida": "CETI Central Plaza",
  "Canal Adquisición": "Instagram"
}
```
La aplicación interceptará estas llaves y las renderizará al vuelo al escanear la tarjeta física NFC o el Apple Wallet Pass del cliente.

---

## 2. Flujo de Sincronización Multi-Máquina

Para compilar e inyectar el sistema en cualquier máquina de escritorio o laptop Windows/macOS, debes seguir estrictamente este flujo *Poka-Yoke*:

### A. Clonación y Sincronización del Worktree
```bash
# Navega al directorio de desarrollo
cd /tu/directorio/de/proyectos

# Clona el Worktree seguro desde el repositorio maestro
git clone https://github.com/tu-repositorio/ceti_app.git

# Ingresa al nodo
cd ceti_app
```

### B. Reconstrucción de Enlaces C++ (Symlinks)
CETI utiliza Firebase, Crashlytics y NFC nativo. Si estás en **Windows**, debes garantizar que el **Developer Mode** esté activo (`ms-settings:developers`) antes de instalar dependencias, de lo contrario la reconstrucción de *symlinks* de C++ colapsará.
```bash
# Limpia caché corrupta
flutter clean

# Reconstruye conectores nativos y descarga SDKs
flutter pub get
```

---

## 3. Despliegue Binario y Obfuscación (Producción)

El código de CETI es propiedad intelectual avanzada. Jamás despliegues el modo `debug` para hardware comercial. Debes generar un APK *Hardened* con alineación a R8 Shrinker (ProGuard) y variables encriptadas (Obfuscation).

### Comando de Ensamblaje Release
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

**¿Qué hace este comando?**
1. **MinifyEnabled & ShrinkResources**: Activa las reglas implementadas en `android/app/build.gradle.kts`. Desecha todo código no utilizado y reduce drásticamente los MB de la aplicación.
2. **ProGuard Rules**: Lee el archivo `proguard-rules.pro` asegurándose de que `nfc_manager` y `com.google.firebase` sobrevivan a la poda de código nativo.
3. **--obfuscate**: Encripta las clases lógicas nativas escritas en Dart (`DashboardProvider`, `InventoryProvider`, lógicas CRM). Nadie que extraiga el APK podrá realizar ingeniería inversa sobre los métodos transaccionales.
4. **--split-debug-info**: Mueve los mapas de trazabilidad a una carpeta aislada, para que si ocurre un *crash*, Firebase Crashlytics pueda de-ofuscar los registros enviando el mapa desde el *backend*.

**Ruta de Extracción del Binario Final:**
El instalador puro estará listo y empaquetado en:
`build/app/outputs/flutter-apk/app-release.apk`

---
*CETI SuperApp — Framework Consolidado. Sistemas Cerrados.*
