# Proyecto1-Arqui

Este proyecto implementa un **interpolador bilineal** para imágenes en escala de grises. El programa toma una imagen de entrada en formato `.img`, realiza una interpolación bilineal para aumentar su resolución, y genera una nueva imagen interpolada en el mismo formato. También incluye herramientas para convertir entre los formatos `.img` y `.jpg`.

## Requisitos

- La imagen de entrada debe ser **cuadrada** (ancho igual a alto) y su tamaño debe ser divisible por 4.
- Se requiere tener instalados los siguientes programas:
  - `nasm` (ensamblador para el código en ASM)
  - `ld` (enlazador para generar el ejecutable)
  - `Python 3`
  - La librería `Pillow` para Python (puedes instalarla con `pip install pillow`).

## Uso

### 1. Construir el ejecutable
Para compilar el código ensamblador, ejecuta el siguiente comando en la terminal:

```bash
make build
```
### 2. Ejecutar el programa principal
Para ejecutar el programa principal, utiliza:

```bash
make python3
```

### 3. Selección de cuadrante
El programa permite seleccionar un cuadrante de la imagen de entrada para realizar la interpolación. Los cuadrantes están numerados del 1 al 16, organizados en una cuadrícula de 4x4.

## Estructura del proyecto
main.py: Script principal que coordina la ejecución del programa.
Interpolador.py: Implementación en Python de la lógica de lectura, escritura y preparación de datos para el interpolador.
Interpolador.asm: Código ensamblador que realiza la interpolación bilineal.
makefile: Archivo para compilar el código ensamblador.
input.img y output.img: Archivos de entrada y salida en formato binario.
LICENSE: Licencia del proyecto.

## Notas importantes
Asegúrate de que la imagen de entrada sea cuadrada y divisible por 4. De lo contrario, el programa no funcionará correctamente.
Si encuentras errores relacionados con los valores de los píxeles (por ejemplo, valores fuera del rango 0-255), el programa se detendrá y mostrará un mensaje de error.

## Licencia
Este proyecto está licenciado bajo la GNU General Public License v3.0. Consulta el archivo LICENSE para más detalles.

