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
  printf("El archivo contiene %u elementos\n", numElements);
  unsigned int *buffer = malloc(numElements * sizeof(unsigned int));

  // Leer los datos del archivo
  unsigned int readCount =
      fread(buffer, sizeof(unsigned int), numElements, file);

  // Operar con los números leídos...
  // Por ejemplo, imprimirlos
  unsigned int sum = 0;
  for (size_t i = 0; i < numElements; ++i) {
    printf("0x%08x\n", *(buffer + i));
    sum += *(buffer + i);
  }
  printf("--FIN DEL ARCHIVO--\n");
  printf("Suma: 0x%08x\n", sum);

  // Limpiar
  free(buffer);
  fclose(file);

  return 0;
}
