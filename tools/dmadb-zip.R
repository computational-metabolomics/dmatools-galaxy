library(XCMSwrapper)
library(optparse)

option_list <- list(
  make_option(c("-o", "--out_dir"), type="character", default=getwd(),
              help="Output folder for resulting files [default = %default]"
  ),
  make_option(c("-x", "--xset"), type="character",
              help="The path to the xcmsSet object"),

  make_option("--grp_peaklist",   type="character",
              help="The path to the grouped peaklist"
  ),

  make_option("--sqlite_db",   type="character",
              help="The path to sqlite database generated for spectral matching annotation"
  )

)

loadRData <- function(rdata_path, name){
#loads an RData file, and returns the named xset object if it is there
    load(rdata_path)
    return(get(ls()[ls() == name]))
}

opt<- parse_args(OptionParser(option_list=option_list))



grp_peaklist <- read.table(opt$grp_peaklist, header = TRUE, sep='\t', stringsAsFactors = FALSE)
xset <- loadRData(opt$xset, 'xset')

zip_for_dma(opt$out_dir,
            grp_peaklist,
            xset,
            sqlite_db,
            'NA')
