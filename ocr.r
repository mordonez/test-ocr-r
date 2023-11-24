# Instala y carga los paquetes necesarios
if (!require("tesseract")) install.packages("tesseract")
if (!require("magick")) install.packages("magick")
library(tesseract)
library(magick)

# Define una función para extraer la fecha
extract_date <- function(text) {
  date_pattern <- "\\b\\d{2}/\\d{2}/\\d{2}\\b" # Patrón para fechas en el formato DD/MM/YY
  date <- regmatches(text, gregexpr(date_pattern, text))[[1]]
  return(date[1])
}

# Define una función para extraer la hora
extract_time <- function(text) {
  time_pattern <- "\\b\\d{2}:\\d{2}:\\d{2}\\b" # Patrón para horas en el formato HH:MM:SS
  time <- regmatches(text, gregexpr(time_pattern, text))[[1]]
  return(time[1])
}

#' Procesa una imagen y extrae la fecha y la hora
#'
#' Esta función toma la ruta de una imagen, la procesa para mejorar su legibilidad,
#' realiza el reconocimiento óptico de caracteres (OCR) para extraer el texto,
#' y luego extrae la fecha y la hora de ese texto.
#'
#' @param image_path La ruta de la imagen a procesar.
#' @return Una lista con la fecha y la hora extraídas.
#' @error Si el archivo de imagen no existe o no se puede leer, la función devuelve NA para la fecha y la hora.
#' @error Si la imagen es nula o no se puede procesar, la función devuelve NA para la fecha y la hora.
#' @error Si el texto extraído no contiene una fecha y una hora válidas, la función devuelve NA para la fecha y la hora.
#'
#' @examples
#' process_image_and_extract_datetime("path/to/image.jpg")
process_image_and_extract_datetime <- function(image_path) {
  # Verificar si el archivo existe
  if (!file.exists(image_path)) {
    print(paste("Not exist:", image_path))
    return(list(date = NA, time = NA))
  }
  # Leer la imagen
  image <- image_read(image_path)

  # Verificar si la imagen es nula
  if (is.null(image)) {
    print(paste("Not reading:", image_path))
    return(list(date = NA, time = NA))
  }

  # width_crop <- floor(image_info(image)$width * 0.2)
  # width_heigh <- floor(image_info(image)$height * 0.2)

  # Procesar la imagen
  processed_image <- image %>%
    # Solo se necesita la parte superior izquierda de la imagen que contiene la fecha y la hora
    image_crop(geometry_area(x = 20, y = 0, width = 150, height = 90)) %>%
    # Se aumenta para mejor legibilidad
    image_resize("200%") %>%
    # Se convierte a escala de grises porque el OCR funciona mejor con imágenes en escala de grises
    image_convert(colorspace = "gray") %>%
    # Se mejora el contraste porque el OCR funciona mejor con imágenes de alto contraste
    image_modulate(brightness = 120, saturation = 0, hue = 100) %>%
    # Se aplica un umbral para eliminar el ruido
    image_threshold("black", "60%") %>%
    # Se aplica un filtro para eliminar el ruido
    image_despeckle()

  # Guardar la imagen procesada
  image_write(processed_image, path = paste0("processed_frames/", basename(image_path)))

  # Realizar el OCR
  text <- image_ocr(processed_image, options = list(tessedit_char_whitelist = "0123456789:/"))

  # Extraer la fecha y la hora
  date <- extract_date(text)
  time <- extract_time(text)

  print(paste("Processing:", image_path, "| Date:", date, "| Time:", time))

  return(list(date = date, time = time))
}

######
# Main
######

# Obtener los nombres de las imágenes en el directorio 'frames'
image_files <- list.files(path = "/workspaces/test-r/frames")

# Crear un DataFrame vacío para almacenar los resultados
df <- data.frame(frame = character(), date = character(), time = character(), stringsAsFactors = FALSE)

# Iterar sobre cada archivo de imagen
for (i in 1:length(image_files)) {

  image_path <- paste0("/workspaces/test-r/frames/", image_files[i])

  result <- process_image_and_extract_datetime(image_path)

  date <- ifelse(is.na(result$date), "", result$date)
  time <- ifelse(is.na(result$time), "", result$time)

  # Añadir los resultados al DataFrame
  df <- rbind(df, data.frame(frame = image_files[i], date = date, time = time, stringsAsFactors = FALSE))

  # Guardar la fila actual en el archivo CSV
  if (i == 1) {
    write.table(df[i, ], "updated_data.csv", sep = ",", row.names = FALSE, col.names = TRUE, na = "")
  } else {
    write.table(df[i, ], "updated_data.csv", sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE, na = "")
  }
  # Liberar memoria
  gc()
}
