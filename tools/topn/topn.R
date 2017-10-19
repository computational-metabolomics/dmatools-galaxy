library(XCMSwrapper)
library(optparse)


option_list <- list(
  make_option("--sample_metadata", type="character"),
  make_option("--out_dir", type="character"),
  make_option("--class", type="character"),
  make_option("--file_include", type="character"),
  make_option("--cores", type="character"),
  make_option("--scan_dens", type="numeric"),
  make_option("--n", type="numeric"),
  make_option("--ppm", type="numeric"),
  make_option("--snthr", type="numeric"),
  make_option("--minfrac", type="numeric"),
  make_option("--polarity", type="character"),
  make_option("--time_window_choice", type="character"),
  make_option("--files", type="character"),
  make_option("--galaxy_files", type="character")

)

# store options
opt<- parse_args(OptionParser(option_list=option_list))


time_window_choice<- trimws(strsplit(opt$time_window_choice, ';')[[1]])
time_window_choice <- time_window_choice[time_window_choice != ""]
tdf <- plyr::ldply(time_window_choice, function(x){trimws(strsplit(x, ',')[[1]])})
colnames(tdf) <- c('min', 'max')
tdf$min <- as.numeric(tdf$min)
tdf$max <- as.numeric(tdf$max)

# Nearline processing
params <- list(
  topn.class = opt$class,
  topn.class.files = opt$file_include,
  topn.msPurity = TRUE,
  topn.cores = opt$cores,
  topn.scanDens = opt$scan_dens, # for scan range x to y, take every 'n' scan (i.e. x, x+n, x+2n ... y)
  topn.timeRange = tdf,
  topn.chunks = NULL, #list(c = 3, timeWin = c(0,1800)), # e.g. list(c = 3, timeWin = c(0,1800)) #chunk time range 0-1800 in to 3.
  topn.n = opt$n, # number of peaks to take per window
  topn.ppm = opt$ppm,
  topn.snthr = opt$snthr,
  topn.minfrac= opt$minfrac,
  topn.clustType = 'hc',
  topn.camera_xcms = '',
  faahKO=FALSE
)


#
sample_metadata <- read.table(opt$sample_metadata, sep='\t', stringsAsFactors=FALSE)

filepaths <- trimws(strsplit(opt$files, ',')[[1]])
filepaths <- filepaths[filepaths != ""]
filepaths_wo_suffix <- unlist(lapply(filepaths, function(x){tools::file_path_sans_ext(basename(x))}))

galaxy_files <- trimws(strsplit(opt$galaxy_files, ',')[[1]])
galaxy_files <- galaxy_files[galaxy_files != ""]

if(!is.null(opt$class)){
  # print(sample_metadata[,1])
  file_select <- sample_metadata[,1][sample_metadata[,2]==opt$class]
  chosen_files <- galaxy_files[filepaths_wo_suffix %in% file_select]
}else{
  chosen_files <- galaxy_files
}
print(chosen_files)

if(!is.null(opt$file_include)){
  file_include <- trimws(strsplit(opt$file_include, ',')[[1]])
  file_include <- as.numeric(file_include[file_include != ""])
  print(file_include)
  chosen_files <- chosen_files[file_include]
}
print(chosen_files)
params$topn.filenames = chosen_files

topn = getTopn(obj=NULL, params)
colnames(topn) = c('mzmed', 'rtmin', 'rtmax')
topn = create_incl(grps = topn, incl_in = NULL, write_file = F, posneg = opt$polarity, comments='topn')


print('HEAD ROWS OF TOPN')
print(head(topn))
write.table(topn, file.path(opt$out_dir, 'topn_peaklist.tsv'), row.names=FALSE, sep='\t')