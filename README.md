# Infrastructure

Repository to organize infrastructure needs for projects.  I am working in AWS currently, and this repository houses infrastructure as code with terraform.  I use python and credstash for dynamic variables and credential storage.

## Usage

Many terraform commands should be run via the `tf.py` script.  For example:

+ ./tf.py data-eng init
+ ./tf.py data-eng apply
+ ./tf.py data-eng destroy
+ ./tf.py data-eng plan

This is currently a very minimal script that only `cd`s into the directory and injects the additional variables for each project.  

These additional variables are defined in that folders `arguments.py` module in the `load_arguments` function.
