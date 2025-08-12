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
CDK8 = mpblock.AllocateLiquidNode("tube_CDK8", "Generic 1.5 mL Flip Cap Tube")
H2O = mpblock.AllocateLiquidNode("tube_H2O", "Generic 1.5 mL Flip Cap Tube")
#Define samples
samplePlate = myra.LoadPlate("Greiner 384", "D")
plateNode_CDK8 = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["gene"]) for sample in samples.Valid if sample["gene"] == "CDK8"]
plateNode_H2O = [samplePlate.Well[sample["Well Index"]].AllocateLiquidNode(sample["gene"]) for sample in samples.Valid if sample["gene"] == "H2O"]
# Operations
myra.TransferLiquid(CDK8, plateNode_CDK8, transferVolume_plasmid)
myra.TransferLiquid(H2O, plateNode_H2O, transferVolume_plasmid)
