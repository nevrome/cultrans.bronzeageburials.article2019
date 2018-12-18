#### simulation function ####

#' neiman_simulation
#'
#' @param k Integer. Number of ideas at t = 0
#' @param N_g Integer. Population per region
#' @param t_final Integer. Final timestep
#' @param mu Double. Innovation rate
#' @param g Integer. Number of regions
#' @param mi Double. Degree of interregion interaction
#' @param I Doublematrix. Interregion interaction matrix. NA means equal interaction
#' 
neiman_simulation <- function(k, N_g, t_final, mu, g, mi, I) {

  # define variables
  regions <- 1:g
  population <- 1:N_g
  ideas <- 1:k
  timesteps <- 2:t_final
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
        timestep = as.integer(0),
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
  for (p1 in timesteps) {
    
    # new timestep list
    pop_old <- pop_devel[[p1 - 1]]
    pop_new <- pop_old
    
    # adjust time in new timestep list
    pop_new <- lapply(
      pop_new, function(x, p1) {
        x$timestep <- p1 - 1
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

standardize_neiman_output <- function(x) {
  
  x %>%
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
  
}

#### setup settings grid ####

config_matrix <- expand.grid(
  k = 2,
  N_g = c(10, 50, 200),
  t_final = 1400,
  mu = 0,
  g = 8,
  mi = c(0, 0.01, 0.1, 0.5 , 1),
  I = NA
) %>%
  tibble::as.tibble() %>%
  dplyr::mutate(
    model_group = 1:nrow(.)
  ) %>%
  tidyr::uncount(8) %>%
  dplyr::mutate(
    model_id = 1:nrow(.)
  )



#### run simulation ####

models <- pbapply::pblapply(
  1:nrow(config_matrix),
  function(i, config_matrix) {
    neiman_simulation(
      config_matrix$k[i], 
      config_matrix$N_g[i], 
      config_matrix$t_final[i], 
      config_matrix$mu[i],
      config_matrix$g[i], 
      config_matrix$mi[i], 
      config_matrix$I[i]
    ) %>% standardize_neiman_output %>%
      dplyr::mutate(
        model_id = config_matrix$model_id[i], 
        model_group = config_matrix$model_group[i],
        region_population_size = config_matrix$N_g[i],
        degree_interregion_interaction = config_matrix$mi[i]
      )
  },
  config_matrix,
  cl = 2
)

models_groups <- do.call(rbind, models) %>%
  base::split(.$model_group)

