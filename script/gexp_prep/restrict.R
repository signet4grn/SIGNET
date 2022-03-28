##Give a chr input, seperate into a vector

# e.g., 
# 1-22; 1,2,3,4; 22

restrict <- function(x){
case_dash <- grep("^[0-9]+[-]+[0-9]", x, value=T)
case_comma <- grep("^[0-9]+[,]+[0-9]", x, value=T)
case_number <- grep('^[0-9]+$', x, value=T)

if(length(case_dash)==1){
x <- as.numeric(unlist(strsplit(x, "-")))
start <- x[1]
end <- x[2]
res <- seq(start, end)
}else if(length(case_comma)==1){
x <- unlist(strsplit(x, ",")) 
res <- x
}else if(length(case_number)==1){
res <- x
}else{
cat("Format not supported. \n")
}

res <- as.numeric(res)

return(res)

}
