// From Yu Shi. Adapted by Puifai Santisakultarm on 2/7/2017
// requires Bio-Formats

// when this is true, the script runs faster but images are hidden
setBatchMode(true);

// load array of all files inside input directory
path = getDirectory("Select folder of input tiff files"); 
filelist = getFileList(path);

//Set what are to be measured
run("Set Measurements...", "area mean min median area_fraction display redirect=None decimal=0");      

for (i=0; i< filelist.length; i++) {

	print("analyzing: "+ filelist[i]);
	// process tiff files only
	if (endsWith(filelist[i], ".tif") || endsWith(filelist[i], ".tiff"))  {
		 // open each file with Bio-Formats
         run("Bio-Formats Importer", "open=[" + path + filelist[i] + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

         // duplicate the 2 files for analysis
         run("Duplicate...", "title=total duplicate");
         analyzedName1 = replace(replace(filelist[i],".tiff","_total.tiff"),".tif","_total.tif");
         run("Duplicate...", "title=Psig duplicate");
         analyzedName2 = replace(replace(filelist[i],".tiff","_Psig.tiff"),".tif","_Psig.tif");

         // detect the total area using low threshold value
         selectWindow("total");
         run("Invert", "slice");
         setAutoThreshold("Default dark");
         setThreshold(8, 255);
         run("Measure");
         setResult("Label", i*2, analyzedName1);

         // detect the wanted area using high threshold value
         selectWindow("Psig");
         run("Invert", "slice");
         setAutoThreshold("Default dark");
         setThreshold(145, 255);         
         run("Measure");
         setResult("Label", i*2, analyzedName2);
         
         run("Close All");
	}
}

resultName = "results.xls";
print("Saving:  " + resultName);
saveAs("Results", path + resultName);

setBatchMode(false);