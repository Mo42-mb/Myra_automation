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
CF = mpblock.AllocateLiquidNode("CF", "Generic 2 mL Rounded Base Flip Cap Tube")

samplePlate = myra.LoadPlate("Greiner 384", "D")
plateNode = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["gene"]) for sample in samples.Valid]


# Operations
myra.TransferLiquid(CF, plateNode, transferVolume_CF, maxTipReuseCount = 1)

