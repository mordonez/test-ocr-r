# Instala y carga los paquetes necesarios
if (!require("tesseract")) install.packages("tesseract")
if (!require("magick")) install.packages("magick")
library(tesseract)
library(magick)

# Lee la imagen
# URL de la imagen
url <- "https://www.dropbox.com/scl/fi/ytbh22xy456g4zftiimqq/image_000139.tiff?rlkey=ez323gfqxxr114bsc5i32o9ie&raw=1"

# Ruta donde se guardará la imagen
destfile <- "image_000139.tiff"

# Descarga la imagen
download.file(url, destfile, mode = "wb")

# Lee la imagen
image <- image_read(destfile)

# Realiza el OCR en la imagen
text <- image %>% 
  image_convert(colorspace = "gray") %>%
  image_trim() %>% 
  image_ocr()

//print(paste(text))
# Define una función para extraer la fecha
extract_date <- function(text) {
  date_pattern <- "\\b\\d{2}/\\d{2}/\\d{2}\\b"  # Patrón para fechas en el formato DD/MM/YY
  date <- regmatches(text, gregexpr(date_pattern, text))[[1]]
  return(date[1])
}

# Define una función para extraer la hora
extract_time <- function(text) {
  time_pattern <- "\\b\\d{2}:\\d{2}:\\d{2}\\b"  # Patrón para horas en el formato HH:MM:SS
  time <- regmatches(text, gregexpr(time_pattern, text))[[1]]
  return(time[1])
}

# Extrae la fecha y la hora
date <- extract_date(text)
time <- extract_time(text)

# Imprime la fecha y la hora
print(paste("Date:", date))
print(paste("Time:", time))
