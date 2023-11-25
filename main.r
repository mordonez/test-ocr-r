source("utils.r")

crop_x <- 20 # Reemplaza esto con la coordenada X del punto superior izquierdo del área que quieres recortar
crop_y <- 0 # Reemplaza esto con la coordenada Y del punto superior izquierdo del área que quieres recortar
crop_width <- 150   # Reemplaza esto con el ancho del área que quieres recortar
crop_height <- 90  # Reemplaza esto con el alto del área que quieres recortar

video_path <- "/workspaces/test-r/video.mp4"  # Reemplaza esto con la ruta al video que quieres procesar
csv_path <- "/workspaces/test-r/frames.csv"  # Reemplaza esto con la ruta al archivo CSV donde quieres guardar los datos
image_dir <- "/workspaces/test-r/frames"  # Reemplaza esto con la ruta al directorio donde quieres guardar las imágenes

export_frames(video_path, image_dir)

process_frames(image_dir, csv_path)
