runner <- function(client, gitstring) {
  # download gitrepo to /lambda/app
  x <- sprintf("git clone %s /lambda/app", gitstring)
  system(x)

  # Install required libraries
  source("/lambda/app/Rinstall.R")
  Rinstall() 

  # Execute Data processing
  source("/lambda/app/run_all.R")
  run_all()
  lsresult = system("ls /lambda/app")
  result <- sprintf("result is %s and hopefully %s", a, lsresult)
  return(result) 
}

lambdr::start_lambda()