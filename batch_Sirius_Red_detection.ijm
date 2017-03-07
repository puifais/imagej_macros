// batch_Sirius_Red_detection
// written by Puifai Santisakultarm on 3/7/2017
// requires Bio-Formats plugin
// utilizes Colour Deconvolution ImageJ built-in function. 
// The sample has Sirius Red staining but the user decides that the vector "Fast Red Fast Blue DAB" color_1 is what he wants

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
		 // open each file with Bio-Formats and convert to RGB
         run("Bio-Formats Importer", "open=[" + path + filelist[i] + "] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");         
         run("RGB Color");

		// split out wanted color
		run("Colour Deconvolution", "vectors=[FastRed FastBlue DAB]");
		selectWindow(filelist[i] + " (RGB)-(Colour_1)");				
		analyzedName = replace(replace(filelist[i],".tiff","_auto-detected.tiff"),".tif","_auto-detected.tif");
		print("Saving:  " + analyzedName);
		save(path + analyzedName); // save for checking the color detection result
		
		// find % of interested color over entire sample
		selectWindow(filelist[i] + " (RGB)-(Colour_1)");
		run("Make Binary");
		run("Measure");
		setResult("Label", i*2, analyzedName);
        selectWindow(filelist[i] + " (RGB)");
        run("Make Binary");
		run("Measure");
		setResult("Label", (i*2)+1, filelist[i]);

		run("Close All");
	}
}

resultName = "results.xls";
print("Saving:  " + resultName);
saveAs("Results", path + resultName);

setBatchMode(false);