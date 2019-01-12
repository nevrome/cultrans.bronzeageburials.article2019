#### simulation function ####

#' neiman_simulation
#'
#' @param k Integer. Number of ideas at t = 0
#' @param N_g Integer. Population per region
#' @param t_start Integer. Starting time
#' @param t_end Integer. Final timestep
#' @param mu Double. Innovation rate
#' @param g Integer. Number of regions
#' @param mi Double. Degree of interregion interaction
#' @param I Doublematrix. Interregion interaction matrix. NA means equal interaction
#'
neiman_simulation <- function(k, N_g, t_start, t_end, mu, g, mi, I) {

  # define variables
  regions <- 1:g
  population <- 1:N_g
  ideas <- 1:k
  timesteps <- (t_start + 1):t_end
  if (is.na(I)) {
    I <- matrix(
      rep(1, g*g), g, g
    )
    diag(I) <- 0
  }

  # create starting populations
  pop0 <- lapply(
    regions, function(region, N, k) {
      tibble::tibble(
        timestep = as.integer(t_start),
        individual = population,
        idea = rep_len(ideas, max(population)),
        region = region
      )
    },
    k, population
  )

  # create development list
  pop_devel <- list()
  pop_devel[[1]] <- pop0

  # determine number of ideas
  last_idea <- max(do.call(rbind, pop_devel[[1]])$idea)

  # simulation loop
  for (p1 in 2:length(timesteps)) {

    # new timestep list
    pop_old <- pop_devel[[p1 - 1]]
    pop_new <- pop_old

    # adjust time in new timestep list
    pop_new <- lapply(
      pop_new, function(x, p1) {
        x$timestep <- timesteps[p1] - 1
        return(x)
      },
      p1
    )

    # intraregion learning
    pop_new <- lapply(
      pop_new, function(x) {
        x$idea <- sample(x$idea, length(x$idea), replace = T)
        return(x)
      }
    )

    # interregion learning
    pop_new <- lapply(
      regions, function(i, pop_new, pop_old, mi, I, regions) {
        exchange_where <- which(sample(c(TRUE, FALSE), nrow(pop_new[[i]]), prob = c(mi, 1 - mi), replace = T))
        exchange_with <- sample(regions, length(exchange_where), prob = I[,i], replace = T)
        pop_new[[i]]$idea[exchange_where] <- unlist(sapply(
          seq_along(exchange_where),
          function(j, pop_old, exchange_with, exchange_where) {
            v <- pop_old[[exchange_with[j]]]$idea
            return(v[exchange_where[j]])
          },
          pop_old, exchange_with, exchange_where
        ))
        return(pop_new[[i]])
      },
      pop_new, pop_old, mi, I, regions
    )

    # innovation
    if(mu != 0) {
      for (i in seq_along(regions)) {
        innovate_where <- which(sample(c(TRUE, FALSE), nrow(pop_new[[i]]), prob = c(mu, 1 - mu), replace = T))
        new_ideas <- seq(last_idea + 1, last_idea + length(innovate_where))
        last_idea <- last_idea + length(innovate_where)
        pop_new[[i]]$idea[innovate_where] <- new_ideas
      }
    }

    pop_devel[[p1]] <- pop_new
  }

  # transform to data.frame
  pop_devel_time_dfs <- lapply(
    pop_devel, function(x) {
      do.call(rbind, x)
    }
  )
  pop_devel_df <- do.call(rbind, pop_devel_time_dfs)

  return(pop_devel_df)
}



#### output preparation ####

standardize_neiman_output <- function(x, region_names) {

  x <- x %>%
    dplyr::group_by(
      timestep, idea, region
    ) %>%
    dplyr::summarise(
      number = n()
    ) %>%
    dplyr::ungroup() %>%
    # calculate proportion
    dplyr::group_by(
      timestep, region
    ) %>%
    dplyr::mutate(
      proportion = number/sum(number)
    ) %>%
    dplyr::ungroup() %>%
    # that's just to fill gaps in the area plot
    tidyr::complete(
      timestep,
      idea,
      region,
      fill = list(number = as.integer(0), proportion = as.double(0))
    ) %>%
    dplyr::select(
      region, timestep, idea, proportion
    )

  x$idea <- paste0("idea_", x$idea)
  x$region <- as.factor(x$region)
  levels(x$region) <- region_names

  return(x)

}
