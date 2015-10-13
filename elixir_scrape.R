
# Pulling all articles from Data Elixir - One of the best resources for Data Science
setwd('/Users/apoorv.anand/Documents/elixir')
library(rvest)

all_posts_page <- data.frame(cat = '',item = '',desc = '',link =  '',issue = '')
category <- c('news','techniques','resources','viz')
for (i in 1:56){
  issue <- i
  main_url <- paste0('http://dataelixir.com/issues/',i,'#start')
  for (j in 1:4){
    cat = category[j]
    for (k in 1:5){
      # Link in the <a> tag, Heading in the <h3> tag and description in the <p> tag
      item_head_xpath <- paste0('//*[@id="',cat,'"]/div[',k,']/h3')
      item_attr_xpath <- paste0('//*[@id="',cat,'"]/div[',k,']/h3/a')
      item_desc_xpath <- paste0('//*[@id="',cat,'"]/div[',k,']/p/text()[1]')
      item <- main_url %>% html() %>% html_nodes(xpath = item_head_xpath) %>% html_text()
      if(length(item) >0){
        link <- main_url %>% html() %>% html_nodes(xpath = item_attr_xpath) %>% html_attrs()
        link <- unlist(link)
        if(length(link) == 0) {link <- 'No link present'}
        desc <- main_url %>% html() %>% html_nodes(xpath = item_desc_xpath) %>% html_text()
        if(length(desc) == 0) {desc <- 'No description present'}
        post <- cbind(cat,item,desc,link,issue)
        all_posts_page <- rbind(all_posts_page,post)
      } else{ post <- data.frame(cat = '',item = '',desc = '',link =  '',issue = '')
              all_posts_page <- rbind(all_posts_page,post)}
  }
 }
}

# Removing all the blank rows from the data frame
elixir <- all_posts_page[all_posts_page$cat != '',]
# write.csv(elixir,'data_elixir_archive.csv',row.names=F)

#Getting all the python links
elixir$tag[grepl('python',x = elixir$desc,ignore.case = T)] <- 'python'
elixir$tag[grepl(' R ',x = elixir$desc,ignore.case = T)] <- 'R'

# Tagging articles whic are both python and R
python_rows <- (grep('python',x = elixir$desc,ignore.case = T))
r_rows <- (grep(' R ',x = elixir$desc,ignore.case = T))
elixir$tag[r_rows[r_rows %in% python_rows]] <- 'R and Python'

# Tagging all NA articles to Elixir
elixir$tag[is.na(elixir$tag)] <- 'ELixir'
names(elixir)[] <- c('Category','Title','Description','Link','Week','Tag')
write.csv(elixir,'data_elixir_archive.csv',row.names=F)
