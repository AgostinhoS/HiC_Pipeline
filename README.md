# Hi-C Pipeline 
Guided implementation of end-to-end Hi-C pipeline, utilizing nextflow scripts and various docker images. Data was pulled from 4D Nucleosome via tsv and json files.
# Reflection

This experience was much more trying in terms of using docker containers. I attempted for a good several days to create a docker container with cooltools, which did not work (I believe for requiring pip and another requirements that did not run well within dockerfile). In the end I utilized a container from the 4D Nucleosome Project. 

Many intial steps borrowed from my first bioinformatics project, such as downloading a reference, indexing and aligning, but a notable different was obtaining a reference chromosome size from the reference.
