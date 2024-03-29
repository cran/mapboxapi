% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mts.R
\name{mts_list_tilesets}
\alias{mts_list_tilesets}
\title{List tilesets in a Mapbox account}
\usage{
mts_list_tilesets(
  username,
  type = NULL,
  visibility = NULL,
  sortby = c("created", "modified"),
  limit = 100,
  start = NULL,
  access_token = NULL
)
}
\arguments{
\item{username}{A Mapbox username}

\item{type}{(optional) Return only \code{"vector"} or \code{"raster"} tilesets. If left blank, all tilesets will be returned.}

\item{visibility}{Return only \code{"public"} or \code{"private"} tilesets. Public tilesets can be returned with any public access token; private tilesets require the user's access token with secret scope.}

\item{sortby}{One of \code{"created"} or \code{"modified"}; the returned data frame will be sorted by one of these two options.}

\item{limit}{The number of tilesets to return; defaults to 100.  The maximum number of tilesets returned by this endpoint is 500.}

\item{start}{The tileset ID at which to start the list of sources; defaults to \code{NULL}.}

\item{access_token}{Your Mapbox access token with secret scope.}
}
\value{
A data frame containing information on available tilesets in a given Mapbox account.
}
\description{
List tilesets in a Mapbox account
}
\examples{
\dontrun{
tileset_list <- mts_list_tilesets(username = "your_mapbox_username")
}
}
\seealso{
\url{https://docs.mapbox.com/api/maps/mapbox-tiling-service/#list-tilesets}
}
