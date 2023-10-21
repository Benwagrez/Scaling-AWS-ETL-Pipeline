runner <- function(client, gitstring) {
  # download gitrepo to /lambda/app
  x <- sprintf("git clone %s /lambda/app", gitstring)
  system(x)

  # Install required libraries
  source("/lambda/app/install_packages.R")
  Rinstall() 

  # Execute Data processing
  setwd("/lambda/app/")
  source("/lambda/app/run_all.R")
  lsresult = system("ls /lambda/app")
  result <- sprintf("result is %s and hopefully %s", x, lsresult)
  return(result) 
}

lambdr::start_lambda()