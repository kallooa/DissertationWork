library(gh)
library(aws.s3)
library(jsonlite)

#Sys.setenv(AWS_ACCESS_KEY_ID = "XXXXXXXXXXX", AWS_SECRET_ACCESS_KEY = "XXXXXXXXXXXXXXXXXXX")

libraries_df = data.frame(name="", created="", updated="", language="", stringsAsFactors = FALSE)

date_range = seq(as.Date("2009-01-01"), as.Date("2018-12-05"), by="days")

for (the_date in 1:length(date_range)) {
  the_date = date_range[the_date]
  print(the_date)
  results = gh("/search/repositories", type = "public", q=paste0("framework created:", the_date), page=1, .token=token)
  #search_results = flatten(results)
  names(results) = seq(length(results))
  tmp = toJSON(results)
  #write(tmp, file=paste0("data/githubdata_", the_date, "_0.json"), append=TRUE)
  s3write_using(tmp, FUN=write, bucket="aadi-praxis", object=paste0("github-framework-search/", "githubdata_", the_date, "_0.json"))
  
  if(length(results$`3`)>0) {
    tmp_df = flatten(fromJSON(jsonlite::toJSON(results$`3`)))
    num_records = length(tmp_df[,1])
    
    if (num_records==100) {
      for (page_num in 1:10)
        results = gh("/search/repositories", type = "public", q=paste0("framework created:", the_date), page=page_num, .token="b2c28f97ab02ef2a1fe369d51ec07b4d04c1de6a")
      names(results) = seq(length(results))
      tmp = toJSON(results)
      s3write_using(tmp, FUN=write, bucket="aadi-praxis", object=paste0("github-framework-search/", "githubdata_", the_date, "_", page_num, ".json"))
    }
  }
  Sys.sleep(2)
}
