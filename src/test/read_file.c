#include <stdio.h>
#include <stdlib.h>

int main() {
  FILE *file = fopen("input.bin", "rb");
  if (file == NULL) {
    printf("Error al abrir el archivo.\n");
    return 1;
  }

  // Determinar el tamaño del archivo
  fseek(file, 0, SEEK_END);     // Mover al final del archivo
  long fileSize = ftell(file);  // Obtener el tamaño del archivo
  rewind(file);                 // Volver al inicio del archivo

  // Calcular el número de elementos y reservar memoria
  size_t numElements = fileSize / sizeof(unsigned int);
  unsigned int *numbers = malloc(numElements * sizeof(unsigned int));
  if (numbers == NULL) {
    printf("Error al reservar memoria.\n");
    fclose(file);
    return 1;
  }

  // Leer los datos del archivo
  unsigned int readCount =
      fread(numbers, sizeof(unsigned int), numElements, file);
  if (readCount < numElements) {
    printf("No se leyeron todos los elementos esperados.\n");
    // Manejar este error como mejor te parezca
  }

  // Operar con los números leídos...
  // Por ejemplo, imprimirlos
  unsigned int sum = 0;
  for (size_t i = 0; i < numElements; ++i) {
    printf("0x%04x\n", *(numbers + i));
    sum += *(numbers + i);
  }
  printf("--FIN DEL ARCHIVO--\n");
  printf("Suma: 0x%04x\n", sum);

  // Limpiar
  free(numbers);
  fclose(file);

  return 0;
}
