#' Install a Mapbox access token in your .Renviron for repeated use
#'
#' @param token The Mapbox access token; can be public (starting with 'pk') or secret (starting with 'sk') scope, which the function will interpret for you
#' @param overwrite Whether or not to overwrite an existing Mapbox access token.  Defaults to FALSE.
#' @param install if TRUE, will install the key in your \code{.Renviron} file for use in future sessions.  Defaults to FALSE.
#'
#' @export
#' @examples \dontrun{
#' my_token <- "..." # The token generated from your Mapbox account
#' mb_access_token(my_token, install = TRUE)
#' Sys.getenv("MAPBOX_PUBLIC_TOKEN")
#' }
mb_access_token <- function(token, overwrite = FALSE, install = FALSE){

  if (grepl("^pk", token)) {
    type <- "MAPBOX_PUBLIC_TOKEN"
  } else if (grepl("^sk", token)) {
    type <- "MAPBOX_SECRET_TOKEN"
  } else {
    stop("Your supplied token appears to be invalid. Check your Mapbox account for details.")
  }

  if (install) {
    home <- Sys.getenv("HOME")
    renv <- file.path(home, ".Renviron")
    if(file.exists(renv)){
      # Backup original .Renviron before doing anything else here.
      file.copy(renv, file.path(home, ".Renviron_backup"))
    }
    if(!file.exists(renv)){
      file.create(renv)
    }
    else{
      if(isTRUE(overwrite)){
        message("Your original .Renviron will be backed up and stored in your R HOME directory if needed.")
        oldenv=read.table(renv, stringsAsFactors = FALSE)
        newenv <- oldenv[-grep(type, oldenv),]
        write.table(newenv, renv, quote = FALSE, sep = "\n",
                    col.names = FALSE, row.names = FALSE)
      }
      else{
        tv <- readLines(renv)
        if(any(grepl(type,tv))){
          stop(sprintf("A %s already exists. You can overwrite it with the argument overwrite=TRUE", type), call.=FALSE)
        }
      }
    }

    tokenconcat <- paste0(sprintf("%s='", type), token, "'")
    # Append access token to .Renviron file
    write(tokenconcat, renv, sep = "\n", append = TRUE)
    message(sprintf('Your access token has been stored in your .Renviron and can be accessed by Sys.getenv("%s"). \nTo use now, restart R or run `readRenviron("~/.Renviron")`', type))
    return(token)
  } else {
    message("To install your access token for use in future sessions, run this function with `install = TRUE`.")
    Sys.setenv(type = token)
  }

}



#' List tokens from a Mapbox account
#'
#' @param username The Mapbox username for which you'd like to list access tokens.
#' @param default If TRUE, will only include the default token for an account. If FALSE, will include all other tokens except for the default.  Defaults to NULL.
#' @param limit The maximum number of tokens to return. Defaults to NULL.
#' @param sortby How to sort the returned tokens; one of \code{"created"} or \code{"modified"}.
#' @param usage If \code{"pk"}, returns only public tokens; if \code{"sk"}, returns only secret tokens.  Defaults to \code{NULL}, which returns all tokens in the scope of the supplied access token.
#' @param access_token Your Mapbox access token.  If left blank, will first check to see if you have a secret token stored in .Renviron, then a public token.
#' @rdname mb_access_token
#'
#' @return A tibble of information about tokens in your Mapbox account.
#'
#' @examples \dontrun{
#'
#' token_list <- list_tokens(
#'   username = "kwalkertcu", # You would use your own username here
#'   limit = 10,
#'   sortby = "modified"#'
#' )
#'
#' }
#'
#' @export
list_tokens <- function(username,
                        default = NULL,
                        limit = NULL,
                        sortby = "created",
                        usage = NULL,
                        access_token = NULL) {

  if (is.null(access_token)) {
    # Use secret token first, then public token
    if (Sys.getenv("MAPBOX_SECRET_TOKEN") != "") {
      access_token <- Sys.getenv("MAPBOX_SECRET_TOKEN")
    } else {
      if (Sys.getenv("MAPBOX_PUBLIC_TOKEN") != "") {
        access_token <- Sys.getenv("MAPBOX_PUBLIC_TOKEN")
      } else {
        stop("A Mapbox access token is required.  Please locate yours from your Mapbox account.", call. = FALSE)
      }

    }
  }

  base <- sprintf("https://api.mapbox.com/tokens/v2/%s", username)


  if (!is.null(default)) {
    if (default) {
      default <- 'true'
    } else {
      default <- 'false'
    }

  }

  request <- httr::GET(base, query = list(access_token = access_token,
                                          default = default,
                                          limit = limit,
                                          sortby = sortby,
                                          usage = usage
                                          ))

  if (request$status_code != 200) {
    pull <- fromJSON(content)
    stop(pull$message, call. = FALSE)
  }

  output <- request %>%
    httr::content(as = "text") %>%
    jsonlite::fromJSON() %>%
    dplyr::as_tibble()

  return(output)

}
