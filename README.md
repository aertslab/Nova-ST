# Nova-ST Analysis

## HDMI Processing

The `demultiplex_per_tile.sh` script should be used first to demultiplex the NovaSeq6000 run into individual tiles. Next the `add_umi_to_r1_32bp.sh` script should be used to append the UMIs from Read 2 to the end of Read 1. All fastq files from the HDMIs are now ready for processing.

The notebook `1.1.HDMI_Processing.ipynb` should be used next. This notebook will first be used to check the sequence of the HDMIs, this should match the pattern shown. Next, each of the barcodes and coordinates will be extracted for each HDMI in each tile, checked against the expected sequence and a small subset of barcodes will be stored seperately. All of this information is saved to `.pickle` files for downstream use.

Next, the `1.2.HDMI_HOUGH_Detection.ipynb` notebook will be used to process the HDMI data into images, from which the fiducual markers present on the flowcell will be detected. The centroids for the markers within each tile will be saved and used later to reconstruct the position of each tile within the imaged flowcell - this allows for correction between sequencing of different flowcells and different sequencers. These tiles are placed based on measured distances from electron microscopy and high resolution light microscopy images.

This is now the end of the HDMI processing.

## Spatial library processing

First we will detect the tiles that are covered by the tissue that has been profiled with the notebook `2.1.TileDetect.ipynb`. This allows us to create a whitelist containing only the barcodes from clusters in these positions. NOTE: This analysis currently assumes that chips have been generated using the whole width of the lane on the flowcell. This will provide a visual indication of the tiles covered and their location on the flowcell, as well as automatically determining these and created the appropriate whitelist for use with STARsolo.

Next, we use `2.2.Mapping.ipynb`, this utilizes the whitelist created in the previous step to generate a gene expression matrix per HDMI. Using `2.3.StatsCircle.ipynb`, we can create a close approximation of the cirlce plots provided in the HTML reports from STomics samples.

Finally, we use `2.4.gefCreation.ipynb` to create a GEF formatted file of the sample that can be loaded into python using the `stereopy` package as well as a png of the spatial location of UMIs detected, which can be used to assess sample quality.

Processing time heavily depends upon the depth of sequencing. A shallowly sequenced sample (~100 million reads 32bp R1, 75bp R2) can be processed from raw data to GEF file within approximately 6-8 hours on a 2 socket sever contiaining 2xIntel(R) Xeon(R) Platinum 8360Y.
