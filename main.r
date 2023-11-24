source("frames.r")  # Asegúrate de que este es el camino correcto al archivo que contiene la función export_frames

video_path <- "video.mp4"  # Reemplaza esto con la ruta al video que quieres procesar
csv_path <- "frames.csv"  # Reemplaza esto con la ruta al archivo CSV donde quieres guardar los datos
image_dir <- "/workspaces/test-r/frames"  # Reemplaza esto con la ruta al directorio donde quieres guardar las imágenes

export_frames(video_path, csv_path, image_dir)