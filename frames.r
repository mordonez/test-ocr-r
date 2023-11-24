if (!require("av")) install.packages("av")
if (!require("imager")) install.packages("imager")

export_frames <- function(video_path, csv_path) {
  video_info <- av::av_info(video_path)
  duration <- video_info$duration
  
  frames_data <- data.frame()
  
  for (i in 1:duration) {
    frame <- av::av_read_frame(video_path, i)
    time <- as.POSIXct(i, origin="1970-01-01", tz="UTC")
    time_formatted <- format(time, "%H:%M:%S")
    image_path <- paste0("frame_", i, "_", gsub(":", "_", time_formatted), ".png")
    imager::save.image(frame, image_path)
    
    frames_data <- rbind(frames_data, data.frame(
      frame_ref = i,
      image_path = image_path,
      time = time_formatted,
      lat = 0,
      lon = 0,
      deph = 0,
      hour = 0,
      time_video = 0,
      analize = 0,
      color = 0,
      observations = 0
    ))
  }
  
  write.csv(frames_data, csv_path, row.names = FALSE)
}