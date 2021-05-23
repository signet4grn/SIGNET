args <- commandArgs(TRUE)
eval(parse(text=args))
library(data.table)
library(plyr)
gen_list = fread(paste0(Sys.getenv("SIGNET_TMP_ROOT"), "/tmpt/gene_pos"))
colnames(gen_list)[2] = "id"
gen_anot = fread(file)
gpos = join(gen_list, gen_anot, by = "id")

gpos_2 = data.frame(gpos$id, gpos$chrom, gpos$chromStart, gpos$chromEnd)
write.table(
  gpos_2,
  paste0(Sys.getenv("SIGNET_RESULT_ROOT"), "/rest/gene_pos"),
  quote = F,
  row.names = F,
  col.names = F,
  sep = " "
)
