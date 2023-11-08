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
    image_crop(geometry_area(x = 0, y = 0, width = 220, height = 90)) %>%
    image_resize("200%") %>%
    image_convert(colorspace = "gray") %>%
    image_modulate(brightness = 120, saturation = 0, hue = 100) %>%
    image_threshold("black", "60%") %>%
    image_despeckle()

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
image_files <- list.files(path = "frames")

# Crear un DataFrame vacío para almacenar los resultados
df <- data.frame(frame = character(), date = character(), time = character(), stringsAsFactors = FALSE)

# Iterar sobre cada archivo de imagen
for (i in 1:length(image_files)) {
  # Ajustar la ruta al archivo
  image_path <- paste0("frames/", image_files[i])

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
