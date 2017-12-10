DMAtools for Galaxy
========================
Galaxy tools for use within the Deep Metabolome Annotation (DMA) project. Currently only for mass spectrometry data, the tools are primarily for additional data processing (including directed fragmentation tools) and for interaction with Deep Metabolome Annotation Database ([DMAdb](https://github.com/computational-metabolomics/dmadb) -  public soon)

Warning
------
Proceed with caution these tools are in active development so tools may change! Stable release coming soon.

Galaxy
------
[Galaxy](https://galaxyproject.org/) is an open, web-based platform for data intensive biomedical research. Whether on the free public server or your own instance, you can perform, reproduce, and share complete analyses. 

Dependencies
------
Dependencies for these Galaxy tools should be handled by CONDA. The packages used currently for dmatools-galaxy are 

* deconrank: A python tool for deconvoluting and ranking precursors to use for fragmentation experiments
* cameraDIMS: A 'hack' of the R package CAMERA so that it can be run on direct infusion datasets (DIMS)
* xcmsWrapper: An R package for LC-MS various processing (e.g blank subtraction, directed fragmentation 'nearline' methods)

The dependencies are currently found on channel  [tomnl](https://anaconda.org/tomnl/r-xcmswrapper) on [anaconda](https://anaconda.org/tomnl/r-xcmswrapper)

Developers & Contributors
-------------------------
 - Thomas N. Lawson (tnl495@bham.ac.uk) - [University of Birmingham (UK)](http://www.birmingham.ac.uk/index.aspx) 
 - Martin R. Jones (m.r.jones.1@bham.ac.uk) - [University of Birmingham (UK)](http://www.birmingham.ac.uk/index.aspx)

Related galaxy tools outside of this repository
-------------------------
 -  https://github.com/computational-metabolomics/dimspy-galaxy
 -  https://github.com/computational-metabolomics/mspurity-galaxy

Workflow4metabolomics tools have also been used for DMA. [W4M](http://workflow4metabolomics.org/)



Changes
-------

