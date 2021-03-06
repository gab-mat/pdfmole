
##  ----------------------------------------------------------------------------
#  align_rows
#  ==========
#' @title Align Rows
#' @description Align the rows of an object of class \code{pdf\_df}.
#' @param x an object of class \code{pdf\_df}.
#' @param method a character string giving the name of the method.
#' @param ... additional arguments
#' @details Some details to be written.
#' @return Returns a object of class \code{"pdf\_df"}.
##  ----------------------------------------------------------------------------
align_rows <- function(x, method = c("exact_match", "hclust"), ...) {
    method <- match.arg(method)
    switch(method, 
        exact_match = align_rows_exact_match(x, ...),
        hclust = align_rows_hclust(x, ...))
}

align_rows_exact_match <- function(x, ...) {
    x$row <- match(x$ystart, sort(unique(x$ystart), decreasing = TRUE))
    x
}

align_rows_hclust <- function(x, ...) {
    kwargs <- list(...)
    .align_rows_hclust <- function(x, h) {
        ymean <- x$yend + x$ystart / 2
        distance_matrix <- dist(ymean)
        hierarchical_cluster <- hclust(distance_matrix, method = "single")
        cut_height <- if ( is.null(h) ) min(x$yend - x$ystart) else h
        cutree(hierarchical_cluster, h = cut_height)
    }
    x$row <- NA_integer_
    for ( i in unique(x$page) ) {
        b <- (x$page == i)
        x$row[b] <- .align_rows_hclust(x[b,], h = kwargs$h)
    }

    ## reorder
    x <- x[order(x$ystart, decreasing = TRUE),]
    x$row <- match(x$row, unique(x$row))
    x
}

## class(z) <- union("pdf_data", class(z))
## z
