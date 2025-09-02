This package will help you use the coding interface in the BMS Workbench software for the BMS Myra Liquid Handling Robot.

This is a quick and easy way to ensure that you are correctly adding "genes" and "treatments" in an interactive way based on what is specified by your spreadsheet for each well in the plate. 

################################

Steps:
First, open samples_template.xlsx and resave with your experiment name. 
Enter your sample information in the "R" sheet. Ignore technical replicates for this. One sample represents all technical replicates.
Enter your plate set-up in the "map_view" sheet. Include all technical replicates in this map, exaclty how you will place them in your physical plate. 
The locked sheets in this file will ensure your samples are mapped to the correct well of a 384-well Greiner plate.

Next, open "Write_myra_scripts.R"
Enter all required information as directed by "USER INPUT". This includes updating your working directory, file name, sample number, number of technical reps per sample, transfer volumes, and tube sizes. This roughly encompasses lines 11-40. 

Last, run the remaining code in "Write_myra_scripts.R". This will create an "output" sub-directory with a csv file to upload in the BMS Workbench sample tab and python scripts (each for an individual run). After upoading your sample information, copy each generated script into the the scripts tab, saving each as a unique BMS run file.

To troubleshoot, evaluate the samples_template.xlsx and run the "Write_myra_scripts.R" with this sample data.

