##### Convert map to list of samples for Myra with interactive pipetting #####
## FIRST, Complete all lines of code that begin with "USER INPUT"
## NEXT, run remaining code to develop A) a dataframe that can be imported into BMS Workbench
## A) three Python scripts to add in order: 1:Specified gene; 2: Master mix ("MM"); 3:Specified Treatment

##### Load libraries #####
library(readxl)

##### Load data #####
## USER INPUT: personalise working directory and file
setwd("./Myra_automation")
map <- read_excel("example_samples.xlsx", sheet = "map_R", col_names = FALSE)
key <- read_excel("example_samples.xlsx", sheet = "plate_key", col_names = FALSE)
samples <- read_excel("example_samples.xlsx", sheet = "R")

## USER INPUT: write expected total sample number (including all technical reps)
sample_number <- 9
technical_reps_per_sample <- 3

##### Select transfer volumes (in uL) #####
## USER INPUT: DEFINE
transferVolume_gene <- 1.25
transferVolume_MM <- 12.5
transferVolume_treatment <- 1.25

##### Choose tube size and placement for Myra deck layout #####
## Notes on loading blocks
# "Myra Multipurpose Loading Block": Fits 18 1.5 or 2 mL Eppendorfs and 14 0.2 mL PCR tubes
# "Myra 96x 0.2 mL Tube/Plate Loading Block": Fits up to 96 0.2mL tubes
# This code utilises only the Myra Multipurpose Loading Block.

## USER INPUT: DEFINE TUBE AND PLACEMENT FOR GENE (STEP 1): Put # in front of deselected tube type
#tube_genes <- "Generic 0.2 mL PCR Tube"
tube_genes <- "Generic 1.5 mL Flip Cap Tube"

# (code assumes Master Mix will be added from "Generic 2 mL Rounded Base Flip Cap Tube")

## USER INPUT: DEFINE TUBE AND PLACEMENT FOR TREATMENT (STEP 3): Put # in front of deselected tube type
tube_treatments <- "Generic 0.2 mL PCR Tube"
#tube_treatments <- "Generic 1.5 mL Flip Cap Tube"

################################################################################

##### RUN to create sample dataframe for Myra, no user input required #####
##### Make dataframe #####
## Pair plate with plate map ##
map2 <- as.vector(as.matrix((map)))
key2 <- as.vector(as.matrix((key)))
plate_df <- cbind(map2, key2)
colnames(plate_df)[1:2] <- c("sample", "Well Index")

## Pair plate position with sample info ##
df <- merge(plate_df, samples, by = "sample")
df$sample <- as.numeric(df$sample)
df <- df[order(df$sample), ]

##### Checks #####
expected_samples_total <- sample_number*technical_reps_per_sample

#If you filled out your expected sample number above, run code:
if (nrow(df) == expected_samples_total) {
  print(paste("Great! You have", expected_samples_total, "samples total, including any technical reps"))
  print(paste("Number of genes:", length(unique(df$gene))))
  print("Name of genes:")
  print(unique(df$gene))
  print(paste("Number of treatments:", length(unique(df$treatment))))
  print("Name of treatments:")
  print(unique(df$treatment))
} else {
  print("Something is probably wrong. Check your samples to make sure you have the expected number")
}

##### export df as csv for Myra #####
dir.create("output") # create directory with all output files from this script
write.csv(df, file = "output/example_myra.csv")


##### write python scripts for Myra #####
###### Script #1: Add Genes ######
# load strings
string1 <- 
'# This script is used to transfer liquid between two nodes #

# Define Parameters and Configure Deckware' 
volume1 <- paste("transferVolume_gene =", transferVolume_gene)
volume2 <- paste("transferVolume_MM =", transferVolume_MM)
volume3 <- paste("transferVolume_treatment", transferVolume_treatment)
string2 <-
'
def generateOperations():
  myra.LoadWasteTub("Myra Standard Waste Tub (Waste Socket)", "Waste")
  myra.LoadPlate("Myra 384 Well Tips", "A")

# Define solutions
mpblock = myra.LoadPlate("Myra Multipurpose Loading Block", "B")'
string3 <- 
'
#Define samples
samplePlate = myra.LoadPlate("Greiner 384", "D")'
string4 <- 
'
# Operations'

## LOOPS TO DEFINE NODES AND TRANSFER
## 1: SOLUTION
#load empty vector
solution_nodeA <- character()
#loop
for (x in unique(df$gene)) {
  line1 <- paste(x, ' = mpblock.AllocateLiquidNode("tube_', x,  '", "', tube_genes, '")', sep = "") 
  cat(line1, "\n")  # prints nicely for viewer - without quotes and adds newline
  solution_nodeA <- c(solution_nodeA, line1)  # stores vector
}
## 2: PLATE
#load empty vector
plate_nodeA <- character()
#loop
for (x in unique(df$gene)) {
  line2 <- paste('plateNode_', x, ' = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["gene"]) for sample in samples.Valid if sample["gene"] == "', x, '"]', sep = "")
  cat(line2, "\n")  # prints nicely for viewer - without quotes and adds newline
  plate_nodeA <- c(plate_nodeA, line2)  # stores vector
}
## 3: TRANSFER
#load empty vector
transferA <- character()
#loop
for (x in unique(df$gene)) {
  line3 <- paste('myra.TransferLiquid(', x, ', ', 'plateNode_', x, ', transferVolume_plasmid)', sep = "")
  cat(line3, "\n")  # prints nicely for viewer - without quotes and adds newline
  transferA <- c(transferA, line3)  # stores vector
}
## AMEND and save python script ##
writeLines(c(string1, volume1, volume2, volume3, string2, solution_nodeA, string3, plate_nodeA, string4, transferA), "output/1-MyraScript-genes-interactive.py", sep = "\n")

###### Script #2: add cell-free master mix ######
## If same cell-free master mix is added to all at one time point, use template in Myra

# Template code
Myra_template_MM <- 
  'CF = mpblock.AllocateLiquidNode("CF", "Generic 2 mL Rounded Base Flip Cap Tube")

samplePlate = myra.LoadPlate("Greiner 384", "D")
plateNode = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["gene"]) for sample in samples.Valid]


# Operations
myra.TransferLiquid(CF, plateNode, transferVolume_CF, maxTipReuseCount = 1)
'
writeLines(c(string1, volume1, volume2, volume3, string2, Myra_template_MM), "output/2-MyraScript-MM.py", sep = "\n")

###### Script #3: add antibiotics ######
## LOOPS TO DEFINE NODES AND TRANSFER
## SOLUTION
#load empty vector
solution_nodeB <- character()
#loop
for (x in unique(df$treatment)) {
  line4 <- paste('tube_', x, ' = mpblock.AllocateLiquidNode("', x,  '", "', tube_treatments, '")', sep = "")
  cat(line4, "\n")  # prints nicely for viewer - without quotes and adds newline
  solution_nodeB <- c(solution_nodeB, line4)  # stores vector
}
## PLATE
#load empty vector
plate_nodeB <- character()
#loop
for (x in unique(df$treatment)) {
  line5 <- paste('plateNode_', x, ' = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["antibiotic"]) for sample in samples.Valid if sample["antibiotic"] == "', x, '"]', sep = "")
  cat(line5, "\n")  # prints nicely for viewer - without quotes and adds newline
  plate_nodeB <- c(plate_nodeB, line5)  # stores vector
}
## TRANSFER
#load empty vector
transferB <- character()
#loop
for (x in unique(df$treatment)) {
  line6 <- paste('myra.TransferLiquid(tube_', x, ', ', 'plateNode_', x, ', transferVolume_treatment, maxTipReuseCount = 1)', sep = "")
  cat(line6, "\n")  # prints nicely for viewer - without quotes and adds newline
  transferB <- c(transferB, line6)  # stores vector
}

## AMEND and save python script ##
writeLines(c(string1, volume1, volume2, volume3, string2, solution_nodeB, string3, plate_nodeB, string4, transferB), "output/3-MyraScript-treatment-interactive.py", sep = "\n")

### Paste code into BMC workspace, upload samples as CSV, and run!