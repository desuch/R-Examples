#' Download and crop the 1 (~30 meter) or 1/3 (~10 meter) arc-second National Elevation Dataset.
#'
#' \code{get_ned} returns a \code{RasterLayer} of elevation data cropped to a given
#' template study area.
#'
#' @param template A Raster* or Spatial* object to serve 
#' as a template for cropping, and perhaps resolution.
#' @param label A character string naming the study area.
#' @param res A character string representing the desired resolution of the NED. "1"
#' indicates the 1 arc-second NED (the default), while "13" indicates the 1/3 arc-second dataset.
#' @param raw.dir A character string indicating where raw downloaded files should be put.
#' The directory will be created if missing. Defaults to "./RAW/NED/".
#' @param extraction.dir A character string indicating where the extracted and cropped DEM should be put.
#' The directory will be created if missing. Defaults to "./EXTRACTIONS/NED/".
#' @param force.redo If an extraction for this template and label already exists, should a new one be created?
#' @return A \code{RasterLayer} DEM cropped to the extent of the template.
#' @export
get_ned <- function(template, label, res="1", raw.dir="./RAW/NED/", extraction.dir="./EXTRACTIONS/NED/", force.redo=F){  
  
  rasters.dir <- paste(extraction.dir,"/",label,"/rasters",sep='')
  
  dir.create(raw.dir, showWarnings = FALSE, recursive = TRUE)
  dir.create(rasters.dir, showWarnings = FALSE, recursive = TRUE)
  
  template <- sp::spTransform(polygon_from_extent(template),sp::CRS("+proj=longlat +ellps=WGS84"))
  extent.latlon <- raster::extent(template)
  
  if(file.exists(paste(rasters.dir,"/NED_",res,".tif", sep='')) & !force.redo){
    extracted.DEM <- raster::raster(paste(rasters.dir,"/NED_",res,".tif", sep=''))
    return(extracted.DEM)
  }
  
  # Open USGS NED download service.
  # NED tiles are labeled by their northwest corner. Thus, coordinate 36.42N, -105.71W is in grid n37w106
  wests <- seq(ceiling(abs(extent.latlon@xmax)),ceiling(abs(extent.latlon@xmin)))
  norths <- seq(ceiling(abs(extent.latlon@ymin)),ceiling(abs(extent.latlon@ymax)))
  
  tilesLocations <- as.matrix(expand.grid(norths,wests,stringsAsFactors = FALSE))
  
  message("Area of interest includes ",nrow(tilesLocations)," NED tiles.")
  
  # Download and crop tiles
  tiles <- apply(tilesLocations,1,function(loc){
    return(get_ned_tile(template=template, res=res, tileNorthing=loc[1], tileWesting=loc[2], raw.dir=raw.dir))
  })
  
  # Mosaic all tiles
  if(length(tiles)>1){
    message('Mosaicking NED tiles.')
    utils::flush.console()
    
    tiles$fun <- mean
    tiles <- do.call(raster::mosaic, tiles)
    
    gc()
  }else{
    tiles <- tiles[[1]]
  }
  
  tiles <- raster::crop(tiles,sp::spTransform(template,sp::CRS(raster::projection(tiles))), snap="out")
  
  raster::writeRaster(tiles, paste(rasters.dir,"/NED_",res,".tif", sep=''), datatype="FLT4S", options=c("COMPRESS=DEFLATE", "ZLEVEL=9", "INTERLEAVE=BAND"), overwrite=T, setStatistics=FALSE)
  
  return(tiles)
}

#' Download a zipped tile from the 1 (~30 meter) or 1/3 (~10 meter) arc-second National Elevation Dataset.
#'
#' Tiles are specified by a resolution, northing, and westing; northing and westing refer to the 
#' northwest corner of each NED tile, in degrees; tiles are 1x1 degree.
#' Tiles are downloaded in zipped ESRI ArcGrid format. \code{downloadNED} returns the path to the downloaded zip file.
#'
#' @param res A character string representing the desired resolution of the NED. "1"
#' indicates the 1 arc-second NED (the default), while "13" indicates the 1/3 arc-second dataset.
#' @param tileNorthing An integer representing the northing (latitude, in degrees north of the equator) of the northwest corner of the tile to 
#' be downloaded.
#' @param tileWesting An integer representing the westing (longitude, in degrees west of the prime meridian) of the northwest corner of the tile to 
#' be downloaded. 
#' @param raw.dir A character string indicating where raw downloaded files should be put.
#' The directory will be created if missing. Defaults to "./RAW/NED/".
#' @return A character string representing the full local path of the downloaded directory.
#' @export
download_ned_tile <- function(res="1", tileNorthing, tileWesting, raw.dir){
  
  destdir <- paste(raw.dir,'/',res, sep='')
  
  dir.create(destdir, showWarnings = FALSE, recursive = TRUE)
  
  tileWesting <- formatC(tileWesting, width = 3, format = "d", flag = "0") 
  tileNorthing <- formatC(tileNorthing, width = 2, format = "d", flag = "0") 
  
  url <- paste('ftp://rockyftp.cr.usgs.gov/vdelivery/Datasets/Staged/NED/',res,'/ArcGrid/n',tileNorthing,'w',tileWesting,'.zip',sep='')
  destdir <- paste(raw.dir,'/',res,'/',sep='')
  download_data(url=url, destdir=destdir)
  
  return(normalizePath(paste(destdir,'n',tileNorthing,'w',tileWesting,'.zip',sep='')))
}

#' Download and crop tile from the 1 (~30 meter) or 1/3 (~10 meter) arc-second National Elevation Dataset.
#'
#' \code{get_ned_tile} returns a \code{RasterLayer} cropped within the specified \code{template}.
#' If template is not provided, returns the entire NED tile.
#' 
#' @param template A Raster* or Spatial* object to serve 
#' as a template for cropping. If missing, entire tile is returned.
#' @param res A character string representing the desired resolution of the NED. "1"
#' indicates the 1 arc-second NED (the default), while "13" indicates the 1/3 arc-second dataset.
#' @param tileNorthing An integer representing the northing (latitude, in degrees north of the equator) of the northwest corner of the tile to 
#' be downloaded.
#' @param tileWesting An integer representing the westing (longitude, in degrees west of the prime meridian) of the northwest corner of the tile to 
#' be downloaded. 
#' @param raw.dir A character string indicating where raw downloaded files should be put.
#' The directory will be created if missing. Defaults to "./RAW/NED/".
#' @return A \code{RasterLayer} cropped within the specified \code{template}.
#' @export
get_ned_tile <- function(template=NULL, res="1", tileNorthing, tileWesting, raw.dir){
  tmpdir <- tempfile()
  if (!dir.create(tmpdir))
    stop("failed to create my temporary directory")
  
  message("(Down)Loading NED tile for ",tileNorthing,"N and ",tileWesting,"W.")
  
  file <- download_ned_tile(res=res, tileNorthing=tileNorthing, tileWesting=tileWesting, raw.dir=raw.dir)
  
  utils::unzip(file,exdir=tmpdir)
  
  dirs <- list.dirs(tmpdir,full.names = TRUE,recursive=F)
  dirs <- dirs[grepl("grdn",dirs)]
  
  tile <- raster::raster(dirs)
  
  if(!is.null(template)){
    tile <- tryCatch(raster::crop(tile,sp::spTransform(template,sp::CRS(raster::projection(tile))), snap="out"), error=function(e){raster::crop(tile,sp::spTransform(template,sp::CRS(raster::projection(tile))))})
  }
  
  tile <- tile*1
  
  unlink(tmpdir, recursive = TRUE)
   
  return(tile)
}