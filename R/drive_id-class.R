new_drive_id <- function(x = character()) {
  vec_assert(x, character())
  new_vctr(x, class = "drive_id", inherit_base_type = TRUE)
}

validate_drive_id <- function(x) {
  ok <- is_valid_drive_id(x)
  if (all(ok)) {
    return(x)
  }

  # proceed with plain character vector
  x <- unclass(x)
  # pragmatism re: how to cli-style a path that is the empty string
  # this is related to the use of gargle_map_cli() for vectorized styling
  # if cli gains native vectorization, this may become unnecessary
  x[!nzchar(x)] <- "\"\""

  drive_abort(c(
    "A {.cls drive_id} must match this regular expression: \\
     {.code {drive_id_regex()}}",
    "Invalid input{?s}:{cli::qty(sum(!ok))}",
    bulletize(gargle_map_cli(x[!ok]), bullet = "x")
  ))
}

drive_id_regex <- function() "^[a-zA-Z0-9_-]+$"

is_valid_drive_id <- function(x) {
  # among practitioners, It Is Known that file IDs have >= 25 characters
  # but I'm not convinced the pros outweigh the cons re: checking length
  # for example, in tests, it's nice to not worry about this
  grepl(drive_id_regex(), x) | is.na(x)
}

is_drive_id <- function(x) {
  inherits(x, "drive_id")
}

#' @export
gargle_map_cli.drive_id <- function(x, ...) {
  NextMethod()
}

#' @export
vec_ptype2.drive_id.drive_id <- function(x, y, ...) new_drive_id()
#' @export
vec_ptype2.drive_id.character <- function(x, y, ...) character()
#' @export
vec_ptype2.character.drive_id <- function(x, y, ...) character()

#' @export
vec_cast.drive_id.drive_id <- function(x, to, ...) x
#' @export
vec_cast.drive_id.character <- function(x, to, ...) {
  validate_drive_id(new_drive_id(x))
}
#' @export
vec_cast.character.drive_id <- function(x, to, ...) vec_data(x)

#' @export
vec_ptype_abbr.drive_id <- function(x) "drv_id"

#' @export
pillar_shaft.drive_id <- function(x, ...) {
  # I would like to present drive_id in full, space permitting, or truncate
  # it severely. Anything in between is a waste of horizontal space.
  # But this is not currently possible: https://github.com/r-lib/pillar/issues/331
  # Explored here in https://github.com/tidyverse/googledrive/pull/364
  # Current compromise is to use pillar_shaft.character.
  # Not sure why I can't access via NextMethod().
  pillar::pillar_shaft(unclass(x))
}

#' Extract and/or mark as file id
#'
#' @description Gets file ids from various inputs and marks them as such, to
#'   distinguish them from file names or paths.
#'
#' @description This is a generic function.
#'
#' @param x A character vector of file or shared drive ids or URLs, a
#'   [`dribble`], or a suitable data frame.
#' @param ... Other arguments passed down to methods. (Not used.)
#' @return A character vector bearing the S3 class `drive_id`.
#' @export
#' @examplesIf drive_has_token()
#' as_id("123abc")
#' as_id("https://docs.google.com/spreadsheets/d/qawsedrf16273849/edit#gid=12345")
#'
#' x <- drive_find(n_max = 3)
#' as_id(x)
as_id <- function(x, ...) UseMethod("as_id")

#' @export
as_id.default <- function(x, ...) {
  drive_abort("
    Don't know how to coerce an object of class {.cls {class(x)}} into \\
    a {.cls drive_id}.")
}

#' @export
as_id.NULL <- function(x, ...) NULL

#' @export
as_id.drive_id <- function(x, ...) x

#' @export
as_id.dribble <- function(x, ...) as_id(x$id)

#' @export
as_id.data.frame <- function(x, ...) as_id(validate_dribble(new_dribble(x)))

#' @export
as_id.character <- function(x, ...) {
  if (length(x) == 0L) return(x)
  out <- map_chr(x, get_one_id)
  validate_drive_id(new_drive_id(out))
}

## we anticipate file-id-containing URLs in these forms:
##       /d/FILE_ID   Drive file
## /folders/FILE_ID   Drive folder
##       id=FILE_ID   uploaded blob
id_regexp <- "(/d/|/folders/|id=)[^/]+"

is_drive_url <- function(x) grepl("^http", x) & grepl(id_regexp, x)

get_one_id <- function(x) {
  if (!grepl("^http|/", x)) return(x)

  id_loc <- regexpr(id_regexp, x)
  if (id_loc == -1) {
    NA_character_
  } else {
    gsub("/d/|/folders/|id=", "", regmatches(x, id_loc))
  }
}
