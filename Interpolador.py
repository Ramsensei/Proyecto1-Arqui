# Script que lee el archivo input.img y realiza una interpolación bilineal
# Deja el resultado en el archivo output.img


# Variables globales
input_file = "input.img"
output_file = "output.img"
input_data = []
output_data = []
width = 0
new_width = 0

# Función para leer el archivo de entrada
def read_input_file():
    global input_data, width
    try:
        with open(input_file, "rb") as f:
            # Leer el archivo como un array de bytes
            # Obtener el ancho de la imagen
            width = int.from_bytes(f.read(2), "big")
            byte_data = f.read()
            # Convertir los bytes a un array de enteros
            input_data = list(byte_data)
            print(f"Ancho de la imagen: {width}")
            # print(f"Datos de entrada: {input_data}")
    except FileNotFoundError:
        print(f"Error: El archivo {input_file} no se encontró.")
        exit(1)
    except Exception as e:
        print(f"Error al leer el archivo {input_file}: {e}")
        exit(1)

# Función para escribir el archivo de salida
def write_output_file():
    global output_data, new_width
    try:
        with open(output_file, "wb") as f:
            # Escribir el ancho de la nueva imagen
            f.write(new_width.to_bytes(2, "big"))  # Guardar el ancho como 2 bytes
            # Convertir el array de enteros a bytes y escribir en el archivo
            f.write(bytes(output_data))
    except Exception as e:
        print(f"Error al escribir el archivo {output_file}: {e}")
        exit(1)

# Función para realizar la interpolación bilineal
def bilinear_interpolation():
    global input_data, output_data, width, new_width
    new_width = width * 3 - 2
    print(f"Nuevo ancho de la imagen: {new_width}")
    output_data = [0] * (new_width ** 2)

    # Copiar los valores de la imagen original a la nueva imagen en las posiciones correctas
    for y in range(width):
        for x in range(width):
            try:
                output_data[y * new_width * 3 + x * 3] = input_data[y * width + x]
            except:
                print(f"Error al copiar los datos de entrada a la salida: y={y}, x={x}")
                exit(1)

    # Interpolar los valores de las columnas multiplos de 3
    for y in range(new_width):
        for x in range(width):
            if(output_data[y * new_width + x * 3] == 0):
                # Interpolar el valor de la columna
                output_data[y * new_width + x * 3] = round(((3 - y%3) * output_data[(y - y%3) * new_width + x * 3] + (y%3) * output_data[(y + 3 - y%3) * new_width + x * 3]) / 3)

    # Interpolar los valores de las filas
    for y in range(new_width):
        for x in range(new_width):
            if(output_data[y * new_width + x] == 0):
                # Interpolar el valor de la fila
                output_data[y * new_width + x] = round(((3 - x%3) * output_data[y * new_width + (x - x%3)] + (x%3) * output_data[y * new_width + (x + 3 - x%3)]) / 3)
            


    # print(f"Datos de salida: {output_data}")

# Función principal
def main():
    read_input_file()
    bilinear_interpolation()
    # Revisar que no haya bytes mayores a 255
    for i in input_data:
        if(i > 255 or i < 0):
            print(f"Error: El valor {i} es mayor a 255.")
            exit(1)
    for i in output_data:
        if(i > 255 or i < 0):
            print(f"Error: El valor {i} es mayor a 255.")
            exit(1)
    write_output_file()
    print("Interpolación completada y guardada en output.img.")

if __name__ == "__main__":
    main()