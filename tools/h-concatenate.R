library(optparse)

option_list <- list(
  make_option(c("-f", "--files"), type="character"),
  make_option(c("-c", "--columns"), type="character"),
  make_option(c("-o", "--out_dir"), type="character"),
  make_option(c("-u", "--uc"), type="character")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list),  args = commandArgs(trailingOnly = TRUE))

print(sessionInfo())
print(opt)

file_paths <- trimws(strsplit(opt$files, ';')[[1]])
file_paths <- file_paths[file_paths != ""]

columns <- trimws(strsplit(opt$columns, ';')[[1]])
columns <- columns[columns != ""]

columns <- lapply(columns, function(x){trimws(strsplit(x, ',')[[1]])})


readIn <- function(f, c){
  print('#### reading in file with columns ####')
  print(f)
  print(c)
  df <- read.table(f, header = TRUE, sep='\t', stringsAsFactors=FALSE)
  if (sum(colnames(df) %in% c)==0){
    print('PLEASE CHECK: Selected columns not in file!!')
    print(colnames(df))
    print(c)
    q()
  }

  df <- df[ , (colnames(df) %in% c)]
  if (length(c)==1){
    df <- data.frame(df)
    colnames(df) <- c
  }

  return(df)
}

m <- mapply(readIn, file_paths, columns, SIMPLIFY = FALSE)

m <- unname(m)
merged <- do.call(cbind, m)

if(!is.null(opt$uc)){
  uc <- trimws(strsplit(opt$uc, ',')[[1]])
  uc <- uc[uc != ""]
  print(colnames(merged))
  print(uc)
  merged <- merged[uc]
}

print(head(merged))

write.table(merged, file.path(opt$out_dir, 'combined_table.tsv'), row.names=FALSE, sep='\t')


