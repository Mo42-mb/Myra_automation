# This script is used to transfer liquid between two nodes #

# Define Parameters and Configure Deckware
transferVolume_gene = 1.25
transferVolume_MM = 12.5
transferVolume_treatment 1.25
def generateOperations():
  myra.LoadWasteTub("Myra Standard Waste Tub (Waste Socket)", "Waste")
  myra.LoadPlate("Myra 384 Well Tips", "A")

# Define solutions
mpblock = myra.LoadPlate("Myra Multipurpose Loading Block", "B")
tube_NaCl = mpblock.AllocateLiquidNode("NaCl", "Generic 0.2 mL PCR Tube")
tube_H2O = mpblock.AllocateLiquidNode("H2O", "Generic 0.2 mL PCR Tube")
#Define samples
samplePlate = myra.LoadPlate("Greiner 384", "D")
plateNode_NaCl = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["antibiotic"]) for sample in samples.Valid if sample["antibiotic"] == "NaCl"]
plateNode_H2O = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["antibiotic"]) for sample in samples.Valid if sample["antibiotic"] == "H2O"]
# Operations
myra.TransferLiquid(tube_NaCl, plateNode_NaCl, transferVolume_treatment, maxTipReuseCount = 1)
myra.TransferLiquid(tube_H2O, plateNode_H2O, transferVolume_treatment, maxTipReuseCount = 1)
