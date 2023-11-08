# Instala y carga los paquetes necesarios
if (!require("tesseract")) install.packages("tesseract")
if (!require("magick")) install.packages("magick")
library(tesseract)
library(magick)

# Lee la imagen
image <- image_read("/Users/arianmartinez/Library/Mobile Documents")

# Realiza el OCR en la imagen
text <- image %>% 
  image_convert(colorspace = "gray") %>% 
  image_trim() %>% 
  image_ocr()

# Define una función para extraer la fecha
extract_date <- function(text) {
  date_pattern <- "\\b\\d{4}-\\d{2}-\\d{2}\\b"  # Ajusta este patrón si la fecha está en un formato diferente
  date <- regmatches(text, gregexpr(date_pattern, text))[[1]]
  return(date[1])
}

# Define una función para extraer la hora
extract_time <- function(text) {
  time_pattern <- "\\b\\d{2}:\\d{2}:\\d{2}\\b"  # Ajusta este patrón si la hora está en un formato diferente
  time <- regmatches(text, gregexpr(time_pattern, text))[[1]]
  return(time[1])
}

# Extrae la fecha y la hora
date <- extract_date(text)
time <- extract_time(text)

# Imprime la fecha y la hora
print(paste("Date:", date))
print(paste("Time:", time))
