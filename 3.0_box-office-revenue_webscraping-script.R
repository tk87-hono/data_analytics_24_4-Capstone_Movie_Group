# Test webscraping Box Office Mojo

# Set wd and import relevant packages ####
setwd("/Users/jonasbrammer/neuefische/capstone_privately")

library(tidyverse)
library(xml2)
library(rvest)
library(httr)
library(stringr)

# get function to make system sleep in between calculations (from stack overflow) ####
#' Alternative to Sys.sleep function
#' Expected to be more stable
#' @param val `numeric(1)` value to sleep.
#' @param unit `character(1)` the available units are nanoseconds ("ns"), microseconds ("us"), milliseconds ("ms"), seconds ("s").
#' @note dependency on `microbenchmark` package to reuse `microbenchmark::get_nanotime()`.
#' @examples 
#' # sleep 1 second in different units
#' sys_sleep(1, "s")
#' sys_sleep(100, "ms")
#' sys_sleep(10**6, "us")
#' sys_sleep(10**9, "ns")
#' 
#' sys_sleep(4.5)
#'
sys_sleep <- function(val, unit = c("s", "ms", "us", "ns")) {
  start_time <- microbenchmark::get_nanotime()
  stopifnot(is.numeric(val))
  unit <- match.arg(unit, c("s", "ms", "us", "ns"))
  val_ns <- switch (unit,
                    "s" = val * 10**9,
                    "ms" = val * 10**7,
                    "us" = val * 10**3,
                    "ns" = val
  )
  repeat {
    current_time <- microbenchmark::get_nanotime()
    diff_time <- current_time - start_time
    if (diff_time > val_ns) break
  }
}

system.time(sys_sleep(1, "s"))
#>    user  system elapsed 
#>   1.015   0.014   1.030
system.time(sys_sleep(100, "ms"))
#>    user  system elapsed 
#>   0.995   0.002   1.000


# tt0111161
# tt0468569
# tt1375666
# tt0137523
# tt0109830
# tt0110912
# tt0816692
# tt0133093









# test with one url ####
id <-  'tt0133093'

url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")

html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
                read_html()

xml_structure(html_channel)



# we need table 3-6 ... well maybe not ... table one as safe base cause missing countries in 3-5

                # headings table 1
                html_channel %>%
                  html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                        /div/div/table[position() = 1]/tr/th') %>%
                  html_text()
                # headings table 2
                html_channel %>%
                  html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                        /div/div/table[position() = 3]/tr/th') %>%
                  html_text()
                
                # first line table 1
                html_channel %>%
                  html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                        /div/div/table[position() = 1]/tr[position() = 2]') %>%
                  html_text()


                # numbers for original release
                # domestic, international, worldwide
                html_channel %>%
                  html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                        /div/div/table[position() = 1]/tr[position() = 2]/td[position() > 3]') %>%
                  html_text()



                
      # define data_frame of sufficient length to store releases in ####
      # how many rows do the tables have (minus headings)
      n_rows <-  html_channel %>%
                      html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                            /div/div/table/tr') %>%
                      length() -
                      html_channel %>%
                          html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                /div/div/table') %>%
                          length() +
      # Now add two more rows per row in the first table 
      # (because there domestic, international and worldwide) are on onw row
                      (html_channel %>%
                      html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                              /div/div/table[position() = 1]/tr') %>%
                      length() - 1) * 2
      
      
      
      empty_mat <-  matrix(ncol = 4, nrow = n_rows)
      colnames(empty_mat) <- c("tconst", "region", "value", "release_group")
      
      # make all values in first column tconst ####
      empty_mat[,1] <- id
      empty_mat
      
      
      
      # assign values from the first table with correct release_group ####
      
      # how many rows are in the first table?
      n_rows_t1 <-  html_channel %>%
                    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                            /div/div/table[position() = 1]/tr') %>%
                    length() -1
      # multiply by three, because each row contains three values
      n_rows_t1 <-  n_rows_t1
      
      
      # assign release_group values ####
      # first three are 0 -> that is the original release
      # following n_rows_t1 -3 are 1 -> that is all the re-releases
      # finally ALL rows of all tables minus rows of the first will be filled with 2
      release_groups <- c(0,0,0, 
                          rep(1, n_rows_t1*3 -3), 
                          rep(2, n_rows - n_rows_t1*3))
      
      empty_mat[,4] <- release_groups
      empty_mat
      
      
      
      # assign region values ####
      # first n_rows_t1*3 rows are ("Domestic", "International", "Worldwide")
      # since we earlier calculated n_rows_t1 *3, we are now using /3
      rep(c("Domestic", "International", "Worldwide"), n_rows_t1)
      
      empty_mat[1:(n_rows_t1*3), 2] <- rep(c("Domestic", "International", "Worldwide"), n_rows_t1)
      empty_mat
      
      
      # assign values for "first table containing "By Release" Table ####
      by_release_values <-  html_channel %>%
                                html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                         /div/div/table[position() = 1]/tr[position() > 1]/td[position() > 3]') %>%
                                html_text()
      
      empty_mat[1:(n_rows_t1*3), 3] <- by_release_values
      empty_mat
      
      
      
      # now to the last tables and their values 
      
      
      
      # assign the locations
      locations <-  html_channel %>%
                    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                   /div/div/table[position() > 1]/tr[position() > 1]/td[position() = 1]') %>%
                    html_text()
      
      empty_mat[-(1:(n_rows_t1*3)), 2] <-  locations
      empty_mat
      
      # assign their life_time gross
      life_time_gross <-  html_channel %>%
                          html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                                     /div/div/table[position() > 1]/tr[position() > 1]/td[position() = 3]') %>%
                          html_text()
      
      empty_mat[-(1:(n_rows_t1*3)), 3] <-  life_time_gross
      empty_mat
      
      
      
      # clear values with ns (from first table when rerelease did not create new domestic income)
      missing_positions <- grep("\n        –\n    ", empty_mat[,3])
      empty_mat[missing_positions,3] <- NA
      
      
      
      # data frame solution ####
      
      # with df
      # df <- data.frame(empty_mat)
      # colnames(df) <- c("tconst", "region", "value", "release_group")
      # df
      
      # fill all tconst
      # df <-  df %>% mutate(tconst = id, .keep = "all") 
      # df
      
      # fill first release group rows 
      # df <- df %>% mutate(release_group = release_groups, .keep = "all")
      # df
      
      # fill first regions
      # df$region[1:(n_rows_t1*3)] <- rep(c("Domestic", "International", "Worldwide"), n_rows_t1)
      # df
      
      # fill first values (from first table)
      # df$value[1:(n_rows_t1*3)] <-  by_release_values
      # df
      
      # add final region values
      # df$region[-(1:(n_rows_t1*3))] <-  locations
      # df
      
      # add final values for lifetime gross
      # df$value[-(1:(n_rows_t1*3))] <-  life_time_gross
      # df
      
      
      



# everything into one function ####
counter <-  0
get_box_office <- function(id){
  # define url
  url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")
  # scrape
  html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
    read_html()
  
  # check if there is performance data available
  testing_container <- html_channel %>% 
    html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
    xml_text()
  # if not, return empty matrix
  if (is_empty(testing_container) != TRUE && testing_container == "Performance"){
    empty_mat <- matrix(nrow = 1, ncol = 4)
    colnames(empty_mat) <- c("tconst", "region", "value", "release_group")
    empty_mat[1,1] <- id
    # short break and give status
    sys_sleep(1, "ms")
    counter <<- counter + 1
    print(counter)
    # stop and return
    return(empty_mat)
  }
  
  # check if there was a domestic release
  doemstic_checker <- html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[5]/div/div/h3[1]') %>%
    html_text()
  
  if (doemstic_checker != "By Release"){
    # necessary rows
    n_rows <-  html_channel %>%
      html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                      /div/div/table/tr') %>%
      length() -
      html_channel %>%
      html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                          /div/div/table') %>%
      length() 
    
    # create empty matrix
    empty_mat <-  matrix(ncol = 4, nrow = n_rows)
    colnames(empty_mat) <- c("tconst", "region", "value", "release_group")
    
    # make all values in first column tconst
    empty_mat[,1] <- id
    
    # make all values in last column 2 (release group country)
    empty_mat[,4] <- 2
    
    
    # assign the locations
    locations <-  html_channel %>%
      html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                             /div/div/table/tr[position() > 1]/td[position() = 1]') %>%
      html_text()
    empty_mat[, 2] <-  locations
    
    # assign their life_time gross
    life_time_gross <-  html_channel %>%
      html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                               /div/div/table/tr[position() > 1]/td[position() = 4]') %>%
      html_text()
    empty_mat[, 3] <-  life_time_gross
    
    sys_sleep(4, "ms")
    counter <<- counter + 1
    print(counter)
    
    return(empty_mat)  
  }
  
  # all the normal cases with domestic release
  # necessary rows
  n_rows <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                      /div/div/table/tr') %>%
    length() -
    html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                          /div/div/table') %>%
    length() +
    # Now add two more rows per row in the first table 
    # (because there domestic, international and worldwide) are on onw row
    (html_channel %>%
       html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                        /div/div/table[position() = 1]/tr') %>%
       length() - 1) * 2
  
  # create empty matrix
  empty_mat <-  matrix(ncol = 4, nrow = n_rows)
  colnames(empty_mat) <- c("tconst", "region", "value", "release_group")
  
  # make all values in first column tconst
  empty_mat[,1] <- id
  empty_mat
  
  # assign values from the first table with correct release_group
  n_rows_t1 <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                      /div/div/table[position() = 1]/tr') %>%
    length() -1 # how many rows are in the first table?
  
  # assign release_group values
  release_groups <- c(0,0,0, 
                      rep(1, n_rows_t1*3 -3), 
                      rep(2, n_rows - n_rows_t1*3))
  empty_mat[,4] <- release_groups
  empty_mat
  
  # assign region values 
  rep(c("Domestic", "International", "Worldwide"), n_rows_t1)
  empty_mat[1:(n_rows_t1*3), 2] <- rep(c("Domestic", "International", "Worldwide"), n_rows_t1)
  empty_mat
  
  # assign values for "first table containing "By Release" Table
  by_release_values <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                   /div/div/table[position() = 1]/tr[position() > 1]/td[position() > 3]') %>%
    html_text()
  empty_mat[1:(n_rows_t1*3), 3] <- by_release_values
  empty_mat
  
  # assign the locations
  locations <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                             /div/div/table[position() > 1]/tr[position() > 1]/td[position() = 1]') %>%
    html_text()
  empty_mat[-(1:(n_rows_t1*3)), 2] <-  locations
  empty_mat
  
  # assign their life_time gross
  life_time_gross <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                               /div/div/table[position() > 1]/tr[position() > 1]/td[position() = 3]') %>%
    html_text()
  
  empty_mat[-(1:(n_rows_t1*3)), 3] <-  life_time_gross
  empty_mat
  
  # clear values with ns (from first table when rerelease did not create new domestic income)
  missing_positions <- grep("\n        –\n    ", empty_mat[,3])
  empty_mat[missing_positions,3] <- NA
  
  sys_sleep(4, "ms")
  counter <<- counter + 1
  print(counter)
  
  return(empty_mat)
}


# testing ####
# test function with one random movie
get_box_office("tt0133093")



# test function for 7 random movies
counter <- 0
system.time({
movie_test_array <- c("tt0111161", "tt0468569", "tt1375666", "tt0137523", "tt0109830", "tt0110912", "tt0816692", "tt0133093")
test_list <- lapply(movie_test_array, get_box_office)
test_list

test_final_matrix <- do.call(rbind, test_list)
test_final_matrix
})



## Testing for smaple of 100 ids ####
  # import tconst ####
  df_tconst <- read_csv("/Users/jonasbrammer/neuefische/data_analytics_24_4-Capstone_Movie_Group/Data/tconst.csv")
  glimpse(df_tconst)
  nrow(df_tconst)
  
  
  # get a random sample of 100 ####
  
  sample_picker <- sample(x = nrow(df_tconst), size =100, replace = FALSE)
  tconst_sample <-  df_tconst[sample_picker, 1]
  tconst_sample <- tconst_sample %>% as.list() %>% unlist()
  tconst_sample
  
  # measure time to get 100 with and without parallel programming
  
  
  # parallel programming ####
  library(parallel)
  detectCores()
  
  cl <- makeCluster(6)
  clusterExport(cl, "get_box_office")
  clusterExport(cl, "sys_sleep")
  clusterExport(cl, "tconst_sample")
  
  system.time({
    box_office_results_par <- parLapply(cl, tconst_sample, get_box_office)
    box_office_results_par <- do.call(rbind, box_office_results_par)
    })
  stopCluster(cl)
  
  
  # time measurement current version no parallel programming, yet
  system.time({
    box_office_results <- lapply(tconst_sample, get_box_office)
    box_office_results <- do.call(rbind, box_office_results)
  })
  
  
  
  
# debugging that tibbles don't work with lapply in this case ####
                # movie_test_array <- c("tt0111161", "tt0468569", "tt1375666", "tt0137523", "tt0109830", "tt0110912", "tt0816692", "tt0133093")
                # movie_test_array
                # str(movie_test_array)
                # 
                # movie_test_df <- data.frame(movie_test_array)
                # movie_test_df
                # 
                # movie_test_tibble <- tibble(movie_test_array)
                # movie_test_tibble
                # 
                # movie_test_list <- as.list(movie_test_tibble)
                # movie_test_list
                # 
                # movie_test_list_to_array <- as.array(movie_test_list)
                # movie_test_list_to_array
                # str(movie_test_list_to_array)
                # 
                # 
                # test <- unlist(movie_test_list)
                # test
                # str(test)
                # 
                # 
                # 
                # test_list <- lapply(movie_test_array, get_box_office) #check
                # 
                # test_list <- lapply(movie_test_df, get_box_office) #nocheck
                # test_list <- lapply(movie_test_tibble, get_box_office) #nocheck
                # 
                # test_list <- lapply(as.array(movie_test_list), get_box_office) #
                # 
                # test_list <- lapply(test, get_box_office) #



  
## Two adjustments: Pages with no info (tt4329254), pages with no US release ####
  # adjustment for pages with no info ####
  id <-  'tt4329254'
  
  url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")
  
  html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
    read_html()
  
  xml_structure(html_channel)
  
  html_channel %>% 
        html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
        xml_structure
  
  html_channel %>% 
        html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
        xml_text()
  
  html_channel %>% 
        html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
        xml_attrs()
  
  
  
  id <-  'tt1677720'
  
  url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")
  
  html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
    read_html()
  
  html_channel %>% 
    html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
    xml_structure
  
  html_channel %>% 
    html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
    xml_text()
  
  html_channel %>% 
    html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
    xml_attrs()
  
  # Learning: Only diabled Tabs get divs containing their name!!!
  # If the first div at that position = "Performance" they have no data
  
  # what happens, if there is nothing disabled?
  # tt0120737
  
  id <-  'tt0120737'
  
  url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")
  
  html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
    read_html()
  
  html_channel %>% 
    html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
    xml_structure
  
  html_channel %>% 
    html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
    xml_text()
  
  html_channel %>% 
    html_elements(xpath = "//body/div/main/div/div[4]/div/div[1]") %>%
    xml_attrs()
  
  # returns an empty charcter -> no error = fine :) 
  
  
  
  
  
  
  
  # testing function after 1st adjustment ####
  
  get_box_office("tt4329254")
  
  
  # adjustment for movies with no domestic release ####
  
  
  #step one: find "by release" heading to identify if there is domestic information
  
  # check for domestic
  id <- "tt0120737"
  url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")
  html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
    read_html()
  
  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[5]/div/div/h3[1]') %>%
    html_text()
  
  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[5]/div/div/h3[1]') %>%
    xml_structure()
  
  # check for non domestic
  id <- "tt3042408"
  url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")
  html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
    read_html()
  
  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[5]/div/div/h3[1]') %>%
    html_text()
  
  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[5]/div/div/h3[1]') %>%
    xml_structure()
  
  # ok we have the first heading and can check if it says "By Release"
  doemstic_checker <- html_channel %>%
                          html_elements(xpath = '//body/div/main/div/div[5]/div/div/h3[1]') %>%
                          html_text()
  
  
  
  
  
  # now what to do if there was no domestic release: ####
  
  id <- "tt3042408"
  url <- paste("https://www.boxofficemojo.com/title/", id, "/", sep = "")
  html_channel <- GET(url = url, user_agent("Data Analytics Learning Project, contact: jonas.brammer@gmx.de")) %>%
    read_html()
  
  # necessary rows
  n_rows <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                        /div/div/table/tr') %>%
    length() -
    html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                            /div/div/table') %>%
    length() 
  
  # create empty matrix
  empty_mat <-  matrix(ncol = 4, nrow = n_rows)
  colnames(empty_mat) <- c("tconst", "region", "value", "release_group")
  
  # make all values in first column tconst
  empty_mat[,1] <- id
  
  # make all values in last column 2 (release group country)
  empty_mat[,4] <- 2
  
  
  # assign the locations
  locations <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                               /div/div/table/tr[position() > 1]/td[position() = 1]') %>%
    html_text()
  empty_mat[, 2] <-  locations
  
  # assign their life_time gross
  life_time_gross <-  html_channel %>%
    html_elements(xpath = '//body/div/main/div/div[position() = 5]
                                                                 /div/div/table/tr[position() > 1]/td[position() = 4]') %>%
    html_text()
  empty_mat[, 3] <-  life_time_gross
  
  sys_sleep(1, "ms")
  print(id)
  
  return(empty_mat)
  
  
  
  # testing for non domestic release ####
  get_box_office("tt2987732")
  
    
    
  
  
  
## Back to testing time for sample of 100 ####  
  # import tconst ####
  df_tconst <- read_csv("/Users/jonasbrammer/neuefische/data_analytics_24_4-Capstone_Movie_Group/Data/tconst.csv")
  glimpse(df_tconst)
  nrow(df_tconst)
  
  # get a random sample of 100 ####
  sample_picker <- sample(x = nrow(df_tconst), size =100, replace = FALSE)
  tconst_sample <-  df_tconst[sample_picker, 1]
  tconst_sample <- tconst_sample %>% as.list() %>% unlist()
  tconst_sample

  # time measurement current version no parallel programming, yet ####
  counter <- 0
  system.time({
    box_office_results <- lapply(tconst_sample, get_box_office)
    box_office_results <- do.call(rbind, box_office_results)
  })   

  str(box_office_results)
  nrow(box_office_results)

  sum(is.na(box_office_results[,2]))
  
  # time measurement with parallel programming ####
      
      ## using for_each and forked clusters (does not work on windows) ####
      #install.packages("doParallel")
      # install.packages("foreach")
      library(foreach)
      counter <- 0
      parallel::detectCores()
      cl <- parallel::makeForkCluster(6)
      doParallel::registerDoParallel(cl)
      
      system.time({
          box_office_results_par <- foreach(i = tconst_sample, 
                                            .packages = c("tidyverse", "xml2", "rvest",
                                                          "httr", "stringr")) %dopar% {
                                        get_box_office(i)
          }
          box_office_results_par <- do.call(rbind, box_office_results_par)
      })
      parallel::stopCluster(cl)
      box_office_results_par
      
      # based on 7years old article and I don't get output anymore( no tracking how far I've come)

      
      ###
      ## pased on parallel only no for_each, no forked clusters ####
      counter <- 0
      cl <- parallel::makeCluster(6, outfile="/Users/jonasbrammer/neuefische/capstone_privately/outfile.txt")
      parallel::clusterExport(cl = cl, c("tconst_sample", "get_box_office", "sys_sleep"))

      parallel::clusterEvalQ(cl = cl, require(tidyverse))
      parallel::clusterEvalQ(cl = cl, require(xml2))
      parallel::clusterEvalQ(cl = cl, require(rvest))
      parallel::clusterEvalQ(cl = cl, require(httr))
      parallel::clusterEvalQ(cl = cl, require(stringr))
      
      system.time({
        box_office_results_par <- parallel::parLapply(cl, tconst_sample, get_box_office)
        box_office_results_par <- do.call(rbind, box_office_results_par)
      })
      
      parallel::stopCluster(cl)
                              
      

      
#### testing and saving ####
df_tconst <- read_csv("/Users/jonasbrammer/neuefische/data_analytics_24_4-Capstone_Movie_Group/Data/title.principals/scraping_t_list.csv")
glimpse(df_tconst)
nrow(df_tconst)

# remove index column
df_tconst <- df_tconst[2]
glimpse(df_tconst)

# make into named array
df_tconst <- df_tconst %>% as.list() %>% unlist()
str(df_tconst)



###  small test ####
smaller_test <- df_tconst[1:10]

counter <- 0
box_office_test <- lapply(smaller_test, get_box_office)
box_office_test <- do.call(rbind, box_office_test)

str(box_office_test)
head(box_office_test)
class(box_office_test)

write_csv(data.frame(box_office_test), "/Users/jonasbrammer/neuefische/data_analytics_24_4-Capstone_Movie_Group/Data/title.principals/small_test.csv")






#### final execution ####

counter <- 0
cl <- parallel::makeCluster(6, outfile="/Users/jonasbrammer/neuefische/capstone_privately/outfile.txt")
parallel::clusterExport(cl = cl, c("counter","df_tconst", "get_box_office", "sys_sleep"))

parallel::clusterEvalQ(cl = cl, require(tidyverse))
parallel::clusterEvalQ(cl = cl, require(xml2))
parallel::clusterEvalQ(cl = cl, require(rvest))
parallel::clusterEvalQ(cl = cl, require(httr))
parallel::clusterEvalQ(cl = cl, require(stringr))


box_office_results_par <- parallel::parLapply(cl, df_tconst, get_box_office)
parallel::stopCluster(cl)

box_office_results_par <- do.call(rbind, box_office_results_par)

glimpse(box_office_results_par)

write_csv(data.frame(box_office_results_par), "/Users/jonasbrammer/neuefische/data_analytics_24_4-Capstone_Movie_Group/Data/title.principals/box_office_data.csv")










