# Instala y carga los paquetes necesarios
if (!require("tesseract")) install.packages("tesseract")
if (!require("magick")) install.packages("magick")
if (!require("av")) install.packages("av")
library(tesseract)
library(magick)
library(av)

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
    image_crop(geometry_area(x = crop_x, y = crop_y, width = crop_width, height = crop_height)) %>%
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

  # Crear el directorio 'processed_frames' si no existe
  if (!dir.exists("processed_frames")) {
    dir.create("processed_frames")
  }

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


#' Exporta los fotogramas de un video como imágenes individuales.
#'
#' @param video_path Ruta del video.
#' @param output_directory Directorio de salida donde se guardarán las imágenes.
#'
#' @return NULL
#'
#' @details Esta función crea un directorio de salida si no existe y luego extrae los fotogramas del video
#' a imágenes individuales en formato PNG. La función utiliza la biblioteca 'av' para obtener la duración
#' del video y extraer los fotogramas.
#'
#' @examples
#' export_frames("video.mp4", "output_frames")
#'
#' @export
export_frames <- function(video_path, output_directory) {
  if (!dir.exists(output_directory)) {
    dir.create(output_directory)
  }

  video_info <- av::av_media_info(video_path)
  duration <- video_info$duration
  av::av_video_images(video = video_path, destdir = output_directory, format = "png", fps = 1)
}

#' Process frames and save data to CSV
#'
#' This function processes a set of image frames and saves the extracted data to a CSV file.
#'
#' @param output_directory The directory where the image frames are stored.
#' @param csv_path The path to the CSV file where the data will be saved.
#'
#' @return None
#'
#' @examples
#' process_frames("/path/to/frames", "/path/to/output.csv")
#'
#' @export
process_frames <- function(output_directory, csv_path) {
  # Function code here
}
process_frames <- function(output_directory, csv_path) {
  files <- list.files(output_directory, full.names = TRUE)
  frames_data <- data.frame()
  for (i in 1:length(files)) {
    image_path <- paste0(files[i])

    result <- process_image_and_extract_datetime(image_path)

    date_screen <- ifelse(is.na(result$date), "", result$date)
    time_screen <- ifelse(is.na(result$time), "", result$time)

    time <- as.POSIXct(i, origin = "1970-01-01", tz = "UTC")
    time_formatted <- format(time, "%H:%M:%S")

    # Añadir los resultados al DataFrame
    frames_data <- rbind(frames_data, data.frame(
      frame_ref = i,
      image_path = files[i],
      time = time_formatted,
      lat = "",
      lon = "",
      deph = "",
      hour = "",
      date_screen = date_screen,
      time_screen = time_screen,
      analize = "",
      color = "",
      observations = "",
      stringsAsFactors = FALSE
    ))
    # Guardar la fila actual en el archivo CSV
    if (i == 1) {
      write.table(frames_data[i, ], csv_path, sep = ",", row.names = FALSE, col.names = TRUE, na = "")
    } else {
      write.table(frames_data[i, ], csv_path, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE, na = "")
    }
    # Liberar memoria
    gc()
  }
  write.csv(frames_data, csv_path, row.names = FALSE)
  cat("Frames extraídos y guardados en:", normalizePath(output_directory), "\n")
}

# Función para recopilar imágenes según un archivo CSV y copiarlas a un directorio de salida.
# Parámetros:
# - csv_path: Ruta del archivo CSV que contiene la información de las imágenes.
# - output_directory: Directorio de salida donde se copiarán las imágenes.
# - clear_first: Indica si se deben borrar los archivos existentes en el directorio de salida antes de copiar las imágenes. Por defecto es FALSE.
collect_images <- function(csv_path, output_directory, clear_first = FALSE) {
  # Leer el archivo CSV
  df <- read.csv(csv_path, stringsAsFactors = FALSE)

  # Crear el directorio 'to_analize' si no existe
  if (!dir.exists(output_directory)) {
    dir.create(output_directory)
  }

  # Si clear_first es TRUE, borrar todos los archivos en el directorio de salida
  if (clear_first) {
    file.remove(list.files(path = output_directory, full.names = TRUE))
  }

  # Iterar sobre cada fila del DataFrame
  for (i in 1:nrow(df)) {
    # Si la columna 'analize' es TRUE
    if (!is.na(df$analize[i]) && df$analize[i] == TRUE) {
      # Obtener la ruta de la imagen
      image_path <- df$image_path[i]

      # Copiar la imagen al directorio 'to_analize'
      file.copy(image_path, output_directory)
    }
  }
}
