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
            # Leer el ancho de la imagen del primer byte
            width = int.from_bytes(f.read(1), "big")
            
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
        print(f"Error convirtiendo la imagen: {e}")


def main():
    # Cargar imagen y convertir a escala de grises
    img = Image.open("input.jpg").convert("L")
    width, height = img.size

    # Asegurar tamaño mínimo de 390x390
    if width < 390 or height < 390:
        img = img.resize((390, 390))
        width, height = 390, 390

    # Dividir en 16 cuadrantes
    q_size = width // 4
    quadrant = int(input("Seleccione cuadrante (1-16): "))
    row = (quadrant - 1) // 4
    col = (quadrant - 1) % 4

    # Extraer cuadrante
    left = col * q_size
    upper = row * q_size
    quadrant_img = img.crop((left, upper, left + q_size, upper + q_size))

    # Guardar cuadrante como .img
    with open("input.img", "w") as f:
        for y in range(q_size):
            f.write(" ".join(str(quadrant_img.getpixel((x, y))) for x in range(q_size)) + "\n")

    # Ejecutar ensamblador
    # subprocess.run(["./interpolador_asm", "input.img", "output.img"])
    # Ejecutar el script de interpolación
    interpolador_main()

    # Leer resultado y guardar como JPEG
    with open("output.img", "r") as f:
        pixels = [[int(v) for v in line.split()] for line in f.readlines()]
    
    output_img = Image.new("L", (len(pixels[0]), len(pixels)))
    for y in range(len(pixels)):
        for x in range(len(pixels[0])):
            output_img.putpixel((x, y), pixels[y][x])
    output_img.save("output.jpg")

    # Mostrar resultados
    draw = ImageDraw.Draw(img)
    draw.rectangle((left, upper, left + q_size, upper + q_size), outline="red")
    img.show()
    output_img.show()

if __name__ == "__main__":
    main()