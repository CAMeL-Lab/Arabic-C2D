
#################################################################
### Constituency to Dependency Mapper and PATB-to-CATiB map
### Copyright (c) 2013 Columbia University. All Rights Reserved.
### Copyright (c) 2014-2021 New York University Abu Dhabi.
### Contact: Nizar Habash (nizar.habash@nyu.edu)
#################################################################

This directory contains the files needed to run the constituency
to dependency mapper to convert the Penn Arabic Treebank to CATiB
style treebank. This is version 0.8 (Apr 4, 2019).  Extensions
to version 0.7 were done by Dima Taji with Nizar Habash's help
at New York University Abu Dhabi's Computational Approaches
to Modeling Language Lab.

Files:

	LICENSE.txt		License governing the use of this code

	README.txt			This file

	C2D-4Apr2019.pl 	Mapper script

	atb3.1-catib.c2d.2Apr2019.map 	Map for PATB to CATiB

	atb3v31.sample		Two sentence sample from PATB

	atb3v31.sample.catib	Expected output

	display_tree.py		Code to pretty print the PATB trees (Python 2.7)


Running the script:

perl ./C2D-8Aug2012.pl atb3.1-catib.c2d.8Aug2012.map < atb3v31.sample

the output should be identical to atb3v31.sample.catib

python2.7 display_tree.py  atb3v31.sample

prints a readable version of the tree.

For any questions, please contact Nizar Habash (nizar.habash@nyu.edu).

#################################################################
### Copyright (c) 2013 Columbia University. All Rights Resereved.
### Copyright (c) 2014-2021 New York University Abu Dhabi.
#################################################################
