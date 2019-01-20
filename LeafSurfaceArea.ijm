dir1 = getDirectory("Directory containing leaf images ");
dir2 = getDirectory("Destination directory for segmented images ");
list = getFileList(dir1);

setBatchMode(true); 

//Create empty file for results
path3=dir2+"Results.txt";

//Open dialog box
Dialog.create("Input images"); 
	Dialog.addNumber("Image Resolution (dpi)", 800);
	Dialog.addNumber("Number of clusters", 2);
	Dialog.addNumber("Low threshold", 1);
	Dialog.addNumber("High threshold", 1);
	Dialog.addNumber("Radius for median filtering (px)", 2);
	Dialog.show;

//Get parameters
resolution = Dialog.getNumber();
clusters = Dialog.getNumber();
LowT = Dialog.getNumber();
HighT = Dialog.getNumber();
radius = Dialog.getNumber();

File.append("File_Name\t"+"Tot_Leaf_Area\t", path3);

for (k=0; k<list.length; k++){
	
	path = dir1+list[k];
	showProgress(k, list.length);
	s=list[k];
	NameLength=lengthOf(s)-4;
	FName=substring(s,0,NameLength);
	extension=substring(s,NameLength+1,lengthOf(s));

	open(path);

	if(extension!="jpg"){
		path4=dir2+FName+".jpg";
		saveAs("Jpeg", path4);
		close();
		open (path4);}

	print("Processing File:"+FName+"...");

	//K-means segmentation
	run("k-means Clustering ...", "number_of_clusters="+clusters+" cluster_center_tolerance=0.00010000 enable_randomization_seed randomization_seed=48");

	//Thresholding
	setAutoThreshold("Default");
	setThreshold(LowT, HighT);
	run("Convert to Mask");

	//Median filtering
	run("Median...", "radius="+radius);
	run("Median...", "radius="+radius);
	run("Median...", "radius="+radius);
	run("Median...", "radius="+radius);
	run("Median...", "radius="+radius);

	run("Set Measurements...", "  area redirect=None decimal=3");

	//Select the leaves
	run("Create Selection");

	//Measure total leaf surface are on the image
	run("Clear Results");
	run("Measure");
	selectWindow("Results");
	TotLeafArea = getResult('Area', 0);
	TotLeafArea = TotLeafArea*(pow((2.54/resolution), 2));
	print("Total leaf surface area (cm2):"+TotLeafArea);	
	run("Clear Results");
	
	//Save data in text file
	File.append(FName+"\t"+TotLeafArea, path3);

	//Save segmented image
	saveAs("Jpeg", dir2+FName+"_SEGM.jpg");

	close();
	close();}