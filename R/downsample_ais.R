#' Returns null, just processes data from web
#'
#' @param df The data frame consisting of the combinations of zones, years, months to process
#' @param every_minutes How often algorithm finds the closest points to (e.g. 10 minute, 30 minute, etc)
#' @param status_codes_to_keep Obsolete, not used -- but was used for data 2009-2014. Status codes to retain for downsampling. List here: https://help.marinetraffic.com/hc/en-us/articles/203990998-What-is-the-significance-of-the-AIS-Navigational-Status-Values-
#' @param SOG_threshold threshold to to delete values less than this (corresponding to little or no movement)
#' @param vessel_attr The attributes from the vessel table to join in
#' @param voyage_attr The attributes from the voyage table to join in
#' @param raw If true, no filtering based on time applied. Defaults to FALSE.
#' @param delete_gdb Whether to delete intermediate gdb files that are downloaded. Defaults to TRUE
#'
#' @return NULL
#' @export
#' @importFrom sf st_read
#' @import dplyr
#' @importFrom magrittr %>%
#' @importFrom lubridate as_datetime round_date minute second month day
#' @examples
#' \dontrun{
#' df = data.frame("month"=1:4, "year" = 2009, "zone"=10)
#' downsample_ais(df, raw = TRUE) # gets raw data from marine cadastre
#' }
downsample_ais = function(df, every_minutes = 10,
  status_codes_to_keep = c(0, 7, 8, 9, 10, 11, 12, 13, 14, 15),
  SOG_threshold = 1,
  vessel_attr = c("VesselType","Length"),
  voyage_attr = c("Destination"),
  raw = FALSE,
  delete_gdb = TRUE) {

if(!dir.exists(paste0(getwd(),"/filtered"))) {
  dir.create(paste0(getwd(),"/filtered")) # create output directory if doesn't exist
}
# loop through files to process
for(i in 1:nrow(df)) {
  # if processed file doesn't exist, download
  if(!file.exists(paste0("filtered/",df$zone[i],"_",df$year[i],"_",df$month[i],".csv"))) {

    charMonth = ifelse(df$month[i] < 10, paste0(0, df$month[i]), paste0(df$month[i]))
    month = c("January","February","March","April","May","June","July","August","September","October","November","December")
    # the directory structure changes by year, which is frustrating

    if(df$year[i] == 2009) {
      url = paste0("https://coast.noaa.gov/htdata/CMSP/AISDataHandler/AIS_FGDBs/Zone",df$zone[i],"/Zone",df$zone[i],"_",df$year[i],"_",charMonth,".zip")
      download.file(url, destfile = "temp.zip", quiet=TRUE)
      unzip("temp.zip")
      char_month = ifelse(df$month[i] < 10, paste0("0",df$month[i]), paste0(df$month[i]))
      fname = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,".gdb")
      dat = sf::st_read(dsn = fname, layer = "Broadcast", quiet = TRUE)
      vessel = sf::st_read(dsn = fname, layer = "Vessel", quiet = TRUE)
      voyage = sf::st_read(dsn = fname, layer = "Voyage", quiet = TRUE)
    }
    if(df$year[i] == 2010) {
      char_month = ifelse(df$month[i] < 10, paste0("0",df$month[i]), paste0(df$month[i]))

      url = paste0("https://coast.noaa.gov/htdata/CMSP/AISDataHandler/",df$year[i],"/",char_month,"_",month[df$month[i]],"_",df$year[i],"/Zone",df$zone[i],"_",df$year[i],"_",char_month,".zip")
      download.file(url, destfile = "temp.zip", quiet=TRUE)
      unzip("temp.zip")
      fname = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,".gdb")

      dat = sf::st_read(dsn = fname, layer = "Broadcast", quiet = TRUE)
      vessel = sf::st_read(dsn = fname, layer = "Vessel", quiet = TRUE)
      voyage = sf::st_read(dsn = fname, layer = "Voyage", quiet = TRUE)
    }
    if(df$year[i] %in% c(2011,2012,2013)) {
      char_month = ifelse(df$month[i] < 10, paste0("0",df$month[i]), paste0(df$month[i]))
      url = paste0("https://coast.noaa.gov/htdata/CMSP/AISDataHandler/",df$year[i],"/",char_month,"/Zone",df$zone[i],"_",df$year[i],"_",char_month,".gdb.zip")
      download.file(url, destfile = "temp.zip", quiet=TRUE)
      unzip("temp.zip")
      fname = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,".gdb")
      if(df$year[i] %in% c(2011,2012)) {
      dat = sf::st_read(dsn = fname, layer = "Broadcast", quiet = TRUE)
      vessel = sf::st_read(dsn = fname, layer = "Vessel", quiet = TRUE)
      voyage = sf::st_read(dsn = fname, layer = "Voyage", quiet = TRUE)
      } else {
        dat = sf::st_read(dsn = fname, layer = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,"_Broadcast"), quiet = TRUE)
        vessel = sf::st_read(dsn = fname, layer = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,"_Vessel"), quiet = TRUE)
        voyage = sf::st_read(dsn = fname, layer = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,"_Voyage"), quiet = TRUE)
      }
    }
    if(df$year[i] == 2014) {
      char_month = ifelse(df$month[i] < 10, paste0("0",df$month[i]), paste0(df$month[i]))

      url = paste0("https://coast.noaa.gov/htdata/CMSP/AISDataHandler/",df$year[i],"/",char_month,"/Zone",df$zone[i],"_",df$year[i],"_",char_month,".zip")
      download.file(url, destfile = "temp.zip", quiet=TRUE)
      unzip("temp.zip")
      fname = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,".gdb")

      dat = sf::st_read(dsn = fname, layer = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,"_Broadcast"), quiet = TRUE)
      vessel = sf::st_read(dsn = fname, layer = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,"_Vessel"), quiet = TRUE)
      voyage = sf::st_read(dsn = fname, layer = paste0("Zone",df$zone[i],"_",df$year[i],"_",char_month,"_Voyage"), quiet = TRUE)
    }
    if(df$year[i] %in% c(2015,2016,2017)) {
      char_month = ifelse(df$month[i] < 10, paste0("0",df$month[i]), paste0(df$month[i]))
      char_zone = ifelse(df$zone[i] < 10, paste0("0",df$zone[i]), paste0(df$zone[i]))

      url = paste0("https://coast.noaa.gov/htdata/CMSP/AISDataHandler/",df$year[i],"/AIS_",df$year[i],"_",char_month,"_Zone",char_zone,".zip")
      download.file(url, destfile = "temp.zip", quiet=TRUE)

      unzip("temp.zip")
      #if(df$year!="2017") {
        fname = paste0("AIS_ASCII_by_UTM_Month/",df$year[i],"/AIS_",df$year[i],"_",char_month,"_Zone",char_zone,".csv")
      #}
      dat = read.csv(file = fname,stringsAsFactors = FALSE)
    }

    # remove temporary files
    unlink("temp.zip")

    # remove gdb file according to user input
    if(delete_gdb) unlink(fname)
    # filter out status codes
    #dat = filter(as.data.frame(dat), SOG >= SOG_threshold) %>%
    #  filter(Status %in% status_codes_to_keep) %>%
    #  left_join(vessel[,c("MMSI",vessel_attr)])
    dat = dplyr::filter(as.data.frame(dat), SOG >= SOG_threshold)
    #%>% dplyr::filter(Status %in% status_codes_to_keep)

    if(df$year[i] < 2015) {
    dat[,c(vessel_attr)] = vessel[match(dat$MMSI, vessel$MMSI),c(vessel_attr)]
    unlink("Vessel.csv")

    # join in voyage destination -- this messes up dplyr because voyage data may be incomplete
    dat[,c(voyage_attr)] = voyage[match(dat$MMSI, voyage$MMSI),c(voyage_attr)]
    unlink("Voyage.csv")

    }

    dat$BaseDateTime = lubridate::as_datetime(dat$BaseDateTime)
    dat$keep = 0

    if(raw == FALSE) {
      # round the time to nearest minute
      # dat$BaseDateTime_round = lubridate::round_date(dat$BaseDateTime, "minute")
      #
      # dat$minutes = lubridate::minute(dat$BaseDateTime_round) + lubridate::second(dat$BaseDateTime)/60
      # seq_min = seq(0, 60, by = every_minutes)
      # seq_min[1] = -1 # catch against 00:00:00 throwing error
      # dat$time_chunk = as.numeric(cut(dat$minutes, seq_min))
      # # calculate difference between time stamp and minutes rounded down and minutes rounded up
      # dat$diff_1 = abs(dat$minutes - seq_min[dat$time_chunk])
      # dat$diff_2 = abs(dat$minutes - seq_min[dat$time_chunk+1])
      # # indicator for whether time stamp is closer to lower (diff_1) or upper bound (diff_2)
      # dat$time_1 = ifelse(dat$diff_1 < dat$diff_2, 1, 0)
      # dat$min_timediff = dat$diff_1 * dat$time_1 + (1-dat$time_1)*dat$diff_2  # calculate the smallest of the 2 values
      # # the time_chunk here is really the interval that the timestamp falls into, and the dat$interval is which of the
      # # breaks the time stamp is closest to
      # dat$interval = dat$time_chunk * dat$time_1 + (1-dat$time_1)* (dat$time_chunk+1) # similarly assign the chunk --
      #
      # # also need to catch case where redundant
      # # or which of the breaks this is closest to
      # dat = select(dat, -BaseDateTime_round, -minutes, -time_chunk, -diff_1, -diff_2, -time_1)
      #
      # # create interval: month: day to group_by on -- this is month:day:hour:interval
      # chunk_fac = as.factor(paste0(lubridate::month(dat$BaseDateTime),":",
      #   lubridate::day(dat$BaseDateTime),":",lubridate::hour(dat$BaseDateTime),":",dat$interval))
      # dat$chunk = as.numeric(chunk_fac)
      # dat$BaseDateTime = as.character(dat$BaseDateTime) # needed to keep dplyr from throwing error
      #
      # dat = dplyr::group_by(dat, MMSI, chunk) %>%
      # dplyr::mutate(mintime = ifelse(min_timediff == min(min_timediff), 1, 0)) %>%
      # dplyr::filter(mintime == 1) %>%
      # ungroup %>%
      # dplyr::select(-mintime, -chunk, -keep)

      periodkey <- tibble(start=seq(floor_date(min(dat$BaseDateTime), unit='hours'),
        ceiling_date(max(dat$BaseDateTime), unit='hours'),
        by=paste(every_minutes,"min"))) %>%
        # round down such that the intervals are on the hour (e.g. every 30 minutes even, 00:00, 00:30, 01:00 etc.)
        # then assign an idx (i.e., a chunk number)
        dplyr::mutate(start=floor_date(start,paste(every_minutes,"min")),idx=row_number())

      # round each observation down to nearest "every_minutes", then join the chunk key
      dat <- dat %>% mutate(flr_time=floor_date(BaseDateTime,paste(every_minutes,"min"))) %>%
        dplyr::left_join(periodkey,by=c("flr_time"="start")) %>%
        # group by vessel and time index, and choose the first observation(i.e., the first observation in each "every_minutes" chunk)
        dplyr::group_by(MMSI,idx) %>%
        dplyr::arrange(BaseDateTime) %>%
        dplyr::slice(1) %>%
        dplyr::ungroup() %>%
        dplyr::select(-idx)
    }

    if(nrow(dat) > 0) {
      # write this to csv file
      saveRDS(dat, paste0("filtered/Zone",df$zone[i],"_",df$month[i],"_",df$year[i],".rds"))
    }
    # trash the temp directory that was created
    unlink(paste0("Zone",df$zone[i],"_",df$year[i],"_",df$month[i],".gdb"), recursive=TRUE)
  }

}


}
