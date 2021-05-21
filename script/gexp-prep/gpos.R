args <- commandArgs(TRUE)
eval(parse(text=args))
library(data.table)
library(plyr)
gen_list = fread(file)
colnames(gen_list)[2] = "id"
gen_anot = fread("hugo_gencode_good_hg19_V24lift37_probemap")
gpos = join(gen_list, gen_anot, by = "id")

gpos_2 = data.frame(gpos$id, gpos$chrom, gpos$chromStart, gpos$chromEnd)
write.table(
  gpos_2,
  "gene_pos",
  quote = F,
  row.names = F,
  col.names = F,
  sep = " "
)
