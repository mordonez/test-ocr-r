source("utils.r")

csv_path <- "/workspaces/test-r/frames.csv"  # Reemplaza esto con la ruta al archivo CSV donde quieres guardar los datos
image_dir <- "/workspaces/test-r/frames_analize"  # Reemplaza esto con la ruta al directorio donde quieres guardar las imágenes
clear_first <- TRUE

analyze_images(csv_path, image_dir, clear_first)
