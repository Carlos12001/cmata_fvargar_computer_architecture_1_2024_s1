#include <stdio.h>

int main() {
  // Números a escribir en el archivo.
  unsigned int registers[] = {0xff000, 0x04020};

  // Abrir el archivo en modo de escritura binaria.
  FILE *file =
      fopen("input.bin", "wb");  // Nota el uso de "wb" para escritura binaria
  if (file == NULL) {
    printf("Error al abrir el archivo.\n");
    return 1;
  }

  printf("Size of registers: %lu bits\n", sizeof(registers) * 8);
  printf("Size of unsigned long int: %lu bits\n", sizeof(unsigned int) * 8);

  size_t numElements = sizeof(registers) / sizeof(unsigned int);
  for (size_t i = 0; i < numElements; ++i) {
    fwrite(&registers[i], sizeof(unsigned int), 1, file);
  }

  // Cerrar el archivo.
  fclose(file);

  printf("Archivo 'input.bin' creado exitosamente.\n");

  return 0;
}
