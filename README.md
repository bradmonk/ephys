# ephys
----

What is this git repo?

A compilation of analysis Rx for electrophysiology data. (or, it will be, soon)


## The Haps

Prerequisite to building-out this ephys analysis toolbox code is defining a standard format for data import. Each import will consist of two files:

* ephys data
* annotation info

Preferably, both of these should be the same file type (e.g. csv, xls, xlsx). In fact, if using an Excel format, both the ephys data and the annotation info can be two different sheets in the same workbook. I think this is preferable as it ensures those files stay together. If we go this route, its important to standardize the sheet names. I propose that, in all lowercase, these sheet names are

* info
* ephys

So the first xls sheet is the annotation info, while the second xls sheet is the ephys data. There should be no other sheets in these workbooks.


Below is an example of the dataset exported from Igor. The first column indicates sweep time (ms). Subsequent columns are samples of electrical current (pA) for each sweep. All sweeps are the same duration (number of rows).

<a href="http://bradleymonk.com/git/readmedia/ephys/data.png" target="_blank">
<img src="http://bradleymonk.com/git/readmedia/ephys/data.png" width="300" border="10" />
</a>


The annotations file shall describe the experimental parameters in-play during each sweep. Since there are 100s of sweeps during the course of an experiment, and since experimental manipulations are performed in a block-design, the annotation file need not be the same size/shape of the data file. Instead pairs of columns are used to indicate the start and stop columns in the datafile that belong to a given parameter block. 


<a href="http://bradleymonk.com/git/readmedia/ephys/anno.png" target="_blank">
<img src="http://bradleymonk.com/git/readmedia/ephys/anno.png" width="300" border="10" />
</a>




## TBD
* Build-out code to import ephys dataset and descriptions files
* Build-out code to auto-organize data based on descriptions
