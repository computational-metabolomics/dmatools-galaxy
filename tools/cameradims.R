library(optparse)
library(cameraDIMS)

option_list <- list(
  make_option(c("-i", "--in_file"), type="character"),
  make_option(c("-o", "--out_dir"), type="character"),
  make_option("--ppm_iso", default=5),
  make_option("--ppm_adduct", default=5),
  make_option("--maxiso", default=4),
  make_option("--mzabs_iso", default=0.015),
  make_option("--mzabs_adduct", default=0.015),
  make_option("--maxcharge", default=3),
  make_option("--maxmol", default=3),
  make_option("--polarity", default='pos'),
  make_option("--rule_path"),
  make_option("--rule_type"),
  make_option("--export_ruleset", action="store_true"),
  make_option("--intensity_filter", default=0)
)


# store options
opt<- parse_args(OptionParser(option_list=option_list))

print(sessionInfo())
print(opt)

df <- read.table(opt$in_file, header = TRUE, sep='\t', stringsAsFactors=FALSE)

print('IN DATA')
print(nrow(df))
print(head(df))

devppm_adduct <- opt$ppm_adduct / 1000000
devppm_iso <- opt$ppm_iso / 1000000

paramiso <- list("ppm"=opt$ppm_iso,
                 "filter"=TRUE,
                 "maxcharge"=opt$maxcharge,
                 "maxiso"=opt$maxiso,
                 "mzabs"=opt$mzabs_iso,
                 "intval"='maxo',
                 "minfrac"=0.5,
                 'IM'=NULL,
                 'devppm'=devppm_iso)

paramadduct <- list("maxCharge"= opt$maxcharge,
                    "maxMol"= opt$maxmol,
                    'devppm'=devppm_adduct,
                    "mzabs"=opt$mzabs_adduct,
                    'IM'=NULL,
                    "filter"=TRUE,
                    'ppm'=opt$ppm_adduct,
                    "quasimolion"= c(1, 6, 8),
                    'polarity'=opt$polarity)




if(is.null(opt$export_ruleset)){
    rule_export <- FALSE
}else{
    rule_export <- TRUE
}

df$mz <- as.numeric(df$mz)

print(head(df$mz))

if ('intensity' %in% colnames(df)){
    colnames(df)[colnames(df)=='intensity'] = 'i'
}

if (!'peakID' %in% colnames(df)){
    df <- cbind('peakID'=1:nrow(df), df)
}

df$i <- as.numeric(df$i)

df <- df[df$i>opt$intensity_filter,]

cameraOut <- cameraDIMS(data=df,
                        params_iso=paramiso,
                        params_adduct=paramadduct,
                        rule_type=opt$rule_type,
                        rule_pth=opt$rule_path,
                        rule_sep='\t',
                        rule_export=rule_export)


print(head(cameraOut[[1]]))
print(head(cameraOut[[2]]))


out_file1 <- file.path(opt$out_dir, 'camera_annotated_peaklist.txt')
out_file2 <- file.path(opt$out_dir, 'camera_annotated_map.txt')
out_file3 <- file.path(opt$out_dir, 'ruleset.txt')

write.table(cameraOut[[1]], out_file1, row.names=FALSE, sep='\t')
write.table(cameraOut[[2]], out_file2, row.names=FALSE, sep='\t')

if (rule_export){
    write.table(cameraOut[[3]], out_file3, row.names=FALSE, sep='\t')
}
