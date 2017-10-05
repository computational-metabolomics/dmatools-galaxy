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
  make_option("--polarity", type="character")

)



# store options
opt<- parse_args(OptionParser(option_list=option_list))


# Nearline processing
# nearline parameters (sample and blank)
params <- list(
  nl.method = opt$interval,
  nl.maxms2 = opt$maxms2, # only used for simple nearline
  nl.widthFactor = opt$widthFactor,
  nl.minWidth = opt$minWidth, # 5 seconds
  nl.ilimit = opt$ilimit, # only used for simple nearline
  nl.shift = opt$shift,
  nl.samplelist_nm  = opt$samplelistNm,
  nl.overlappingP  = opt$overlappingP,
  nl.fullpw = TRUE,
  #nearline blank parameters
  nl.b_widthFactor = opt$b_widthFactor, # increase the width
  nl.b_minWidth = opt$b_minWidth,
  nl.b.shift = opt$b_shift,
  nl.exclu_limit = opt$exclu_limit
)


# ##################################
# # Perform Nearline optimisation
# ##################################
s_peaklist <- read.table(opt$sample_peaklist, header = TRUE, sep='\t', stringsAsFactors = FALSE)
b_peaklist <- read.table(opt$blank_peaklist, header = TRUE, sep='\t', stringsAsFactors = FALSE)
topn <- read.table(opt$topn, header = TRUE, sep='\t', stringsAsFactors = FALSE)

# #Generate inclusions lists for DDA-MS/MS and store in list
incl.lists = nearline_main(pm = params, peaklist_xcms=s_peaklist, pol=opt$polarity, cls='_', merge_peaklists=TRUE)


#Generate exclusion lists for each class being analysed
nearline_main_blank(pm = params,
                        plist = b_peaklist,
                        incl_list_pos = incl.lists,
                        pol = opt$s_peaklist,
                        cls = '_',
                        topn = topn)

