# Script que lee el archivo input.img y realiza una interpolación bilineal
# Deja el resultado en el archivo output.img


# Variables globales
input_file = "input.img"
output_file = "output.img"
input_data = []
output_data = []
width = 0

# Función para leer el archivo de entrada
def read_input_file():
    global input_data, width
    try:
        with open(input_file, "rb") as f:
            # Leer el archivo como un array de bytes
            byte_data = f.read()
            # Obtener el ancho de la imagen
            width = byte_data[0]
            # Convertir los bytes a un array de enteros
            input_data = list(byte_data[1:])
            print(f"Ancho de la imagen: {width}")
            print(f"Datos de entrada: {input_data}")
    except FileNotFoundError:
        print(f"Error: El archivo {input_file} no se encontró.")
        exit(1)
    except Exception as e:
        print(f"Error al leer el archivo {input_file}: {e}")
        exit(1)

# Función para escribir el archivo de salida
def write_output_file():
    global output_data
    try:
        with open(output_file, "wb") as f:
            # Convertir el array de enteros a bytes y escribir en el archivo
            f.write(bytes(output_data))
    except Exception as e:
        print(f"Error al escribir el archivo {output_file}: {e}")
        exit(1)

# Función para realizar la interpolación bilineal
def bilinear_interpolation():
    global input_data, output_data, width
    height = len(input_data) // width
    output_data = [0] * (width * height) * 2

    for y in range(height - 1):
        for x in range(width - 1):
            # Obtener los cuatro píxeles que rodean el píxel a interpolar
            p1 = input_data[y * width + x]
            p2 = input_data[y * width + (x + 1)]
            p3 = input_data[(y + 1) * width + x]
            p4 = input_data[(y + 1) * width + (x + 1)]

            # Realizar la interpolación bilineal
            output_data[y * width + x] = (p1 + p2 + p3 + p4) // 4

    print(f"Datos de salida: {output_data}")

# Función principal
def main():
    read_input_file()
    bilinear_interpolation()
    write_output_file()
    print("Interpolación completada y guardada en output.img.")

if __name__ == "__main__":
    main()