# Proyecto de OCR con R

Este proyecto utiliza OCR (Reconocimiento Óptico de Caracteres) para extraer la fecha y la hora de las imágenes y las guarda en un archivo CSV.

## Dependencias

Este proyecto depende de las siguientes bibliotecas de R:

- magrittr
- magick
- tesseract

## Uso

1. Asegúrate de tener instaladas todas las dependencias.
2. Ejecuta el script `ocr.r` para procesar las imágenes y extraer la fecha y la hora.

## Funciones principales

- `process_image_and_extract_datetime(image_path)`: Esta función toma la ruta a una imagen, procesa la imagen, realiza el OCR y extrae la fecha y la hora.

## Datos de salida

El script principal guarda los resultados en un archivo CSV llamado "updated_data.csv". Cada fila del archivo CSV corresponde a una imagen y contiene la fecha y la hora extraídas de la imagen.
