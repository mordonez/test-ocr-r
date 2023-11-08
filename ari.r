# Install and load required packages
if (!require("tesseract")) install.packages("tesseract")
if (!require("magick")) install.packages("magick")

library(tesseract)
library(magick)

# Load the image
# Lee la imagen
# URL de la imagen
url <- "https://www.dropbox.com/scl/fi/ytbh22xy456g4zftiimqq/image_000139.tiff?rlkey=ez323gfqxxr114bsc5i32o9ie&raw=1"

# Ruta donde se guardará la imagen
destfile <- "image_000139.tiff"

# Descarga la imagen
#download.file(url, destfile, mode = "wb")

# Lee la imagen
#image <- image_read(destfile)
image <- image_read("image_000139.tiff")

# Preprocess the image (resize, crop, enhance, etc.)
# image <- image_resize(image, width = 800)
# Apply filters or thresholding as needed

# Perform OCR using Tesseract
text <- ocr(image)

# Extracted text
extracted_text <- as.character(text)

# Function to filter and extract time information
extract_time_lines <- function(text) {
  lines <- strsplit(text, "\n")[[1]]
  time_lines <- grep("\\b\\d{1,2}(:\\d{2})?\\s*(AM|PM|am|pm)?\\b", lines, ignore.case = TRUE, value = TRUE)
  return(time_lines)
}

# Extract lines with time information
time_lines <- extract_time_lines(extracted_text)

# Function to extract time from a line using regular expressions
extract_time_from_line <- function(line) {
  time_pattern <- "\\b\\d{1,2}(:\\d{2})?\\s*(AM|PM|am|pm)?\\b"
  times <- regmatches(line, gregexpr(time_pattern, line, ignore.case = TRUE))[[1]]
  times <- unlist(times)
  return(times)
}

if (length(time_lines) >= 2) {
  second_line <- time_lines[2]
  extracted_time <- extract_time_from_line(second_line)
  print(extracted_time)
} else {
  print("No time information found.")
}



# Extract time from each filtered line
extracted_times <- lapply(time_lines, extract_time_from_line)

# Print the extracted time information
print(extracted_times)

df<-as.data.frame(extracted_times)
