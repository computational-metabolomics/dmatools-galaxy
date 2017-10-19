library(XCMSwrapper)
library(optparse)

option_list <- list(

  make_option(c("-s", "--sample_peaklist"), type="character"),
  make_option(c("-b", "--blank_peaklist"), type="character"),
  make_option(c("-t", "--topn"), type="character"),
  make_option(c("-o", "--out_dir"), type="character", default=getwd(),
              help="Output folder for resulting files [default = %default]"
  ),
  make_option("--method", type="character"),
  make_option("--maxms2", type="numeric"),
  make_option("--widthFactor", type="numeric"),
  make_option("--minWidth", type="numeric"),
  make_option("--ilimit", type="numeric"),
  make_option("--shift", type="numeric"),
  make_option("--samplelistNm", type="numeric"),
  make_option("--overlappingP", type="numeric"),
  make_option("--fullpw", action="store_true"),
  make_option("--b_widthFactor", type="numeric"),
  make_option("--b_shift", type="numeric"),
  make_option("--b_exclu_limit", type="numeric"),
  make_option("--b_minWidth", type="numeric"),
  make_option("--polarity", type="character"),
  make_option("--fillgaps", type="character"),
  make_option("--dmaNearline", action="store_true"),
  make_option("--blankClass", type="character"),
  make_option("--intensityCN", type="character"),
  make_option("--sortCN", type="character"),
  make_option("--filterS", type="character")
)

# store options
opt<- parse_args(OptionParser(option_list=option_list))

print(sessionInfo())
print(opt)

if(is.null(opt$fullpw)){
  fullpw = FALSE
}else{
  fullpw = TRUE
}

if(is.null(opt$fillgaps)){
  fillgaps = FALSE
}else{
  fillgaps = TRUE
}


# Nearline processing
# nearline parameters (sample and blank)
params <- list(
  nl.method = opt$method,
  nl.maxms2 = opt$maxms2, # only used for simple nearline
  nl.widthFactor = opt$widthFactor,
  nl.minWidth = opt$minWidth, # 5 seconds
  nl.ilimit = opt$ilimit, # only used for simple nearline
  nl.shift = opt$shift,
  nl.samplelist_nm  = opt$samplelistNm,
  nl.overlappingP  = opt$overlappingP,
  nl.fullpw = fullpw,
  nl.fillgaps = fillgaps,  # only used for metshot nearline
  #nearline blank parameters
  nl.b_widthFactor = opt$b_widthFactor, # increase the width
  nl.b_minWidth = opt$b_minWidth,
  nl.b.shift = opt$b_shift,
  nl.exclu_limit = opt$b_exclu_limit,
  temp_dir='.',
  intensityCN=opt$intensityCN,
  sortCN=opt$sortCN # column of the sample peaklist to use for

)



# ##################################
# # Perform Nearline optimisation
# ##################################
s_peaklist <- read.table(opt$sample_peaklist, header = TRUE, sep='\t', stringsAsFactors = FALSE)
b_peaklist <- read.table(opt$blank_peaklist, header = TRUE, sep='\t', stringsAsFactors = FALSE)

if(!is.null(opt$dmaNearline)){
    # have to do some additional filtering if part of the dma nearline workflow
    blank_class_name <- gsub('-', '.', opt$blankClass)
    b_peaklist = b_peaklist[which(b_peaklist[,paste(blank_class_name, '_valid', sep='')]==1),]
    s_peaklist = s_peaklist[s_peaklist[,opt$filterS]==0,]
}



topn <- read.table(opt$topn, header = TRUE, sep='\t', stringsAsFactors = FALSE, check.names=FALSE)
topn[is.na(topn)] <- ""
# colnames(topn) <- c('Mass [m/z]', 'Formula [M]', 'Formula type', 'Species',   'CS [z]',  'Polarity',  'Start [min]',  'End [min]','Comment')
# colnames(topn) <- gsub('\\.', ' ', colnames(topn))
print(head(topn))

# #Generate inclusions lists for DDA-MS/MS and store in list
incl.lists = nearline_main(pm = params, peaklist_xcms=s_peaklist, pol=opt$polarity, merge_peaklists=FALSE, peaklist_post=NA)

# #Generate exclusion lists for each class being analysed
nearline_main_blank(pm = params,
                        plist = b_peaklist,
                        incl_list_pos = incl.lists,
                        pol = opt$polarity,
                        topn = topn)
#
