#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define KMAXIMO 22050  // Circular buffer
#define BUFFER_SIZE \
  1024  // Tamaño del buffer de salida, ajusta según tus necesidades.

int main() {
  FILE *inputFile, *outputFile;
  int32_t x, y;
  int32_t y_anteriores[KMAXIMO] = {0};
  int32_t buffer[BUFFER_SIZE];  // Buffer para almacenar valores de `y` antes de
                                // escribir.
  int k = 2;                    // Ajusta según sea necesario.
  int index = 0, bufferIndex = 0;

  inputFile = fopen("input.bin", "rb");
  outputFile = fopen("output.bin", "wb");
  if (inputFile == NULL || outputFile == NULL) {
    fprintf(stderr, "Error al abrir archivos.\n");
    return 1;
  }
  int n_k = 0;  // esto va ser el index-k
  // index y n_k siempre seran MENORES a KMAXIMO
  // Recuerda que en assembly KMAXIMO es igual a KMAXIMO*4

  while (fread(&x, sizeof(int32_t), 1, inputFile) ==
         1) {  // preguntar si existe una forma de saber esto
    int y_anterior = (index - k >= 0) ? y_anteriores[(index - k) % KMAXIMO] : 0;
    y = x + 1 + y_anterior;
    y_anteriores[index % KMAXIMO] = y;

    buffer[bufferIndex++] = y;

    // Cuando el buffer está lleno, escribe todo el buffer al archivo de salida.
    if (bufferIndex >= BUFFER_SIZE) {
      fwrite(buffer, sizeof(int32_t), BUFFER_SIZE, outputFile);
      bufferIndex = 0;  // Reinicia el índice del buffer para la próxima carga.
    }

    index++;  //
  }

  // Escribe cualquier valor restante en el buffer que no haya llenado el buffer
  // completo.
  if (bufferIndex > 0) {
    fwrite(buffer, sizeof(int32_t), bufferIndex, outputFile);
  }

  fclose(inputFile);
  fclose(outputFile);

  return 0;
}
