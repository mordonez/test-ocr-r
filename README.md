# Proyecto de OCR con R

Este proyecto utiliza OCR (Reconocimiento Óptico de Caracteres) para extraer la fecha y la hora por pantalla de un video y las guarda en un archivo CSV.

## Dependencias

Este proyecto depende de las siguientes bibliotecas de R:

- magick
- tesseract
- av

## Uso

1. Asegúrate de tener instaladas todas las dependencias.
2. Configura las rutas del video, del archivo CSV y del directorio de imágenes en el script `main.r`.
3. Ejecuta el script `main.r` para extraer los frames del video.
4. Ejecuta el script `collect.r` para copiar las imágenes que son analizables a un directorio de destino.

El script `main.r` se encarga de extraer los frames del video, procesar las imágenes, realizar el OCR y guardar los resultados en un archivo CSV.

El script `collect.r` se encarga de analizar el archivo CSV generado por `main.r` y una vez actualizado el CSV con las imagenes analizables, copia estas a un directorio de destino que se desee.

## Datos de salida

El script `main.r` guarda los resultados en un archivo CSV. Cada fila del archivo CSV corresponde a un frame del video y contiene la referencia del frame, la ruta de la imagen, la fecha y la hora extraídas de la imagen, y el tiempo en formato horas:minutos:segundos.
