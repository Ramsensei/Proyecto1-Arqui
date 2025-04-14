import subprocess
from Interpolador import main as interpolador_main
from PIL import Image, ImageDraw


INPUT_IMG = "input.img"
OUTPUT_IMG = "output.img"
INPUT_JPG = "input.jpg"
OUTPUT_JPG = "output.jpg"

# El formato .img es un formato donde el primer byte indica el ancho de la imagen
# y el resto son los valores de 0 a 255 de cada pixel en blanco y negro.

def img2jpg(img_file, jpg_file):
    """Convierte un archivo de tipo img a formato JPEG."""
    try:
        with open(img_file, "rb") as f:
            # Leer el ancho de la imagen de los primeros 2 bytes
            width = int.from_bytes(f.read(2), "big")
            
            # Leer los valores de los píxeles
            pixel_data = f.read()
            height = len(pixel_data) // width
            
            # Crear una imagen en escala de grises
            img = Image.new("L", (width, height))
            img.putdata(pixel_data)
            
            # Guardar la imagen en formato JPEG
            img.save(jpg_file, "JPEG")
            print(f"Imagen convertida y guardada como {jpg_file}")
    except Exception as e:
        print(f"Error convirtiendo la imagen (img2jpg): {e}")


def jpg2img(img_file, jpg_file):
    """Convierte un archivo de formato JPG a tipo img."""
    try:
        img = Image.open(jpg_file).convert("L")
        width, height = img.size
        
        # Crear un archivo .img y escribir el ancho (2 bytes) seguido de los píxeles
        with open(img_file, "wb") as f:
            f.write(width.to_bytes(2, "big"))  # Guardar el ancho como 2 bytes
            pixel_data = img.tobytes()
            f.write(pixel_data)
        
        print(f"Imagen convertida y guardada como {img_file}")
    except Exception as e:
        print(f"Error convirtiendo la imagen (jpg2img): {e}")


def main():
    # Cargar imagen y convertir a escala de grises
    img = Image.open(INPUT_JPG).convert("L")
    width, height = img.size

    # Asegurarse de que la imagen es cuadrada y divisible por 4
    if width != height or width % 4 != 0:
        print("La imagen debe ser cuadrada y divisible por 4.")
        return

    # Dividir en 16 cuadrantes
    q_size = width // 4
    quadrant = int(input("Seleccione cuadrante (1-16): "))
    row = (quadrant - 1) // 4
    col = (quadrant - 1) % 4

    # Extraer cuadrante
    left = col * q_size
    upper = row * q_size
    quadrant_img = img.crop((left, upper, left + q_size, upper + q_size))

    # Guardar cuadrante como imagen
    quadrant_img.save("quadrant.jpg")

    # Convertir cuadrante a formato img
    jpg2img(INPUT_IMG, "quadrant.jpg")

    # Ejecutar ensamblador
    subprocess.run(["./interpolador_asm"])
    # Ejecutar el script de interpolación
    # interpolador_main()

    # Convertir el resultado a JPG
    img2jpg(OUTPUT_IMG, OUTPUT_JPG)

if __name__ == "__main__":
    main()
    # # Convertir de JPG a IMG
    # jpg2img(INPUT_IMG, INPUT_JPG)
    # # Ejecutar el ensamblador (o el script de interpolación)
    # interpolador_main()
    # # Convertir de IMG a JPG
    # img2jpg(OUTPUT_IMG, OUTPUT_JPG)