<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgheadline15">1. Custom microarray probe alignments and annotations</a>
<ul>
<li><a href="#orgheadline7">1.1. Details</a>
<ul>
<li><a href="#orgheadline1">1.1.1. Local installation of Ensembl releases</a></li>
<li><a href="#orgheadline2">1.1.2. Probe alignment and annotation pipeline</a></li>
<li><a href="#orgheadline3">1.1.3. Perl API to the alignment and annotation databases</a></li>
<li><a href="#orgheadline4">1.1.4. Custom CDF file generation</a></li>
<li><a href="#orgheadline5">1.1.5. Generation of the <code>R</code> CDF and probe packages</a></li>
<li><a href="#orgheadline6">1.1.6. General utilities and other functions</a></li>
</ul>
</li>
<li><a href="#orgheadline9">1.2. Installation</a>
<ul>
<li><a href="#orgheadline8">1.2.1. Requirements</a></li>
</ul>
</li>
<li><a href="#orgheadline14">1.3. Development</a>
<ul>
<li><a href="#orgheadline10">1.3.1. Authors</a></li>
<li><a href="#orgheadline13">1.3.2. <span class="todo nilTODO">TODO</span> s</a></li>
</ul>
</li>
</ul>
</li>
</ul>
</div>
</div>

---

This documentation is far from complete, and also the individual scripts might
not be documented as good as they should.

# Custom microarray probe alignments and annotations<a id="orgheadline15"></a>

This package provides functions to perform an alignment of microarray probe
sequences to cDNA sequences, sequences of non-coding RNAs and to genomic
sequences and to annotate these alignments to genes/transcripts/exons.
Alignments, annotations and probe sequences are stored into a MySQL database
that can then be queried to generate custom (Affymetrix) *CEL definition files*
(CDF), which can then be used in the pre-processing of the respective Affymetrix
microarrays.

Such custom CDF files can be packaged into `R` packages that enable
pre-processing of the respective type of Affymetrix microarrays using packages
from the Bioconductor project (i.e. the `affy` package, or our `generalgcrma`
package).

**Note**: in newer releases of Bioconductor the `affy` package does no longer
allow to process the newer generation of Affymetrix microarrays (i.e. the *ST*
GeneChips). The package thus returns an error when this type of microarrays are
read using the `ReadAffy` function. We suggest that you download the source
(`tar.gz`) of the `affy` package from the Bioconductor homepage, unpack it, edit
the `read.affybatch.R` file in the *R* sub-folder of the package and comment out
the code lines that check the type of the GeneChip (i.e. search for *The affy
package is not designed for this array type*). After that install the package by
calling `R CMD INSTALL affy` in the folder where you un-archived the package.

The code and annotations heavily rely on Ensembl (<http://www.ensembl.org>),
i.e. alignments are performed against cDNA, non-coding RNA and genomic sequences
provided by Ensembl and for annotation of alignments the Ensembl `Perl` API is
employed. Thus, to use most part of the `Perl` scripts it is required to add the
Ensembl `Perl` API to the `PERL5LIB` environment variable.

## Details<a id="orgheadline7"></a>

This section provides some overview of the main tasks that can be performed and
lists and describes (hopefully) all scripts and functions.

In general, all `Perl` scripts should print their respective help and usage if
called with the parameter `-h`.

**Folder structure:**

-   *CustomCDF*: contains the `Perl` API for the annotation database.

-   *bin*: contains all `Perl` scripts and functions.
    -   *R*: contains some utility `R` functions.
    -   *compara*: contains a script to retrieve conserved elements from the Ensembl database.

-   *cdf*: folder with `Rnw` files to generate `R` CDF and probe packages needed
    for pre-processing of Affymetrix based microarrays using the custom CDFs in
    `R` (employing Bioconductor's `affy` package or our `generalgcrma` package).

-   *cfg*:

-   *fasta*:

-   *html*: ???

**MySQL access configuration:**

The file `mysql.cfg` in folder *cfg* should be configured to enable (write)
access to a local MySQL database system.

### Local installation of Ensembl releases<a id="orgheadline1"></a>

These functions can be used to fetch various files and resources from Ensembl
and install them locally.

-   `check_update_Ensembl.pl`: compares locally installed Ensembl versions with
    online versions and, if a newer version is available, downloads and installs
    it. Possible options are to download and install the Ensembl `Perl` API, the
    fasta files (for the genomic sequences as well as for cDNA and non-coding
    RNAs) and the Ensembl core database, individually, or all of them at the same
    time.

-   `getCVS.sh`: simple shell script to check out the Ensembl `Perl` API using
    `cvs`. This script is called directly by `check_update_Ensembl.pl`. Starting
    with Ensembl version 76 this function is obsolete, since the Perl API is
    fetched from github.

-   `installDB.sh`: shell script to install MySQL dumps as provided by Ensembl

-   `installEnsemblDB.pl`: script to install a specified Ensembl database locally.

### Probe alignment and annotation pipeline<a id="orgheadline2"></a>

That's the main *pipeline* that performs the alignment of probe sequences,
stores alignments into a database and annotates alignments.

-   `cdna_alignment.pl` the main `Perl` script that performs the alignment of
    probe sequences, annotation of alignments and insertion of all needed
    information to a MySQL database. Most of the settings can be specified in a
    configuration file (located in the *cfg* folder).

### Perl API to the alignment and annotation databases<a id="orgheadline3"></a>

A Perl API is available to query the annotation databases generated by functions
from the above section.

All `Perl` files contain perldoc annotations.

### Custom CDF file generation<a id="orgheadline4"></a>

Both `Perl` scripts below create CDF files (in plain text format) and annotation
text files containing annotations for each defined probe set. The
`annotateFile.pl` described further below can be used to add additional
annotations.

-   `make_cdf_from_db.pl`: create a *transcript level* CDF file for an Affymetrix
    microarray based on the respective alignment and annotation database generated
    by `cdna_alignment.pl`. This will define a probe set for each **transcript**
    defined in the Ensembl database for which probes are available on the
    microarray (with probe sets with same probe content being joined). This type
    of CDF can be used for *conventional* gene expression profiling.

-   `make_gene_cdf_from_db.pl`: create a *gene level* CDF file for an Affymetrix
    microarray based on the alignment and annotation database. This will define a
    probe set for each **gene** defined in the Ensembl database. This type of CDF
    might be used for differential splice analyses.

### Generation of the `R` CDF and probe packages<a id="orgheadline5"></a>

To make the custom CDFs available to `R` it is required that they are packaged
into `R` packages. This can be achieved using the `Rnw` files in the *cdf*
sub-folder.  The whole process is at present relatively cumbersome and might
need to be improved in future.

### General utilities and other functions<a id="orgheadline6"></a>

-   `annotateProbests.pl`: `Perl` script to retrieve annotation for all probe sets
    of a specified microarray from Ensembl.

-   `annotateFile.pl`: `Perl` script that retrieves annotations (gene symbol, gene
    name, chromosome name and strand, gene biotype) for (Ensembl) gene IDs
    provided in the input file using the Ensembl `Perl` API.

-   `annotateFileTranscript-length.pl` retrieves lengths of transcripts (in nt)
    for Ensembl transcript IDs defined in an input file.

-   `annotateFileTranscript.pl`: same as `annotateFile.pl`, just that it retrieves
    annotations for Ensembl transcript IDs instead.

-   `make_gsnap_splice_site_file.pl`: `Perl` script to generate a known splice
    site file that can be used in combination with the `gmap/gsnap`
    aligner. Defines splice (acceptor, donor) sites for all genes in Ensembl.

-   `make_index_ensembl.pl`: a `Perl` script to create the index files for the
    `bowtie` or `gmap/gsnap` aligner using genomic fasta files provided by
    Ensembl. Call `perl make_index_ensembl.pl -h` to print the help page.

-   `probeFastaFromPGFandBGP.R`: a `R` source file providing a function
    `probeFastaFromPGFandBGP` that extracts probe sequences from Affymetrix *.pgf*
    and *.bgp* files and writes them to a fasta file that can be used by the
    `cdna_alignment.pl` script. Affymetrix does not provide official fasta files
    containing the sequences of all probes on a microarrays, thus these have to be
    generated by such means. The *.pgf* and *.bgp* files are distributed inside
    the library archive files for Affymetrix software (*command console* or
    *GCOS*). This is the preferred way to define probe fasta files, since they
    will contain also the background probes designed by Affymetrix. Still, on the
    microarrays there might be many more probes, for which the probe sequences are
    however not known and not provided by Affymetrix.

-   `probeTabToFASTA.R`: a `R` source file providing the function
    `probeTabToFASTA` that converts the probe files in tabular format provided by
    Affymetrix into a fasta file. However, not all probes on the microarray (and
    also only few background probes) are provided in these probe tab files. Thus,
    the function above (`probeFastaFromPGFandBGP`) should be used.

-   `reformat_fasta.pl`: `Perl` script to re-format fasta files (as provided by
    Ensembl) to be usable for functions and tools from the `ViennaRNA` package
    (i.e. the script removes all line breaks from the sequences).

## Installation<a id="orgheadline9"></a>

### Requirements<a id="orgheadline8"></a>

The functions and scripts from this package should run on any Unix system. It has been tested on CentOS and Mac OS X.

-   Most of the tools and `Perl` scripts require the Ensembl `Perl` API, which depends on `Bioperl`.

-   A running MySQL database system might be of help.

-   `R` is never bad to have on hand.

## Development<a id="orgheadline14"></a>

As usual, everybody is invited to contribute to this package. If so, new functions/scripts should be listed in the Details section above.

### Authors<a id="orgheadline10"></a>

-   Johannes Rainer (johannes.rainer@gmail.com)

### TODO s<a id="orgheadline13"></a>

Some things that (still) need to be done.

1.  DONE Write the first draft of the `README.org`.

    -   State "DONE"       from "TODO"       <span class="timestamp-wrapper"><span class="timestamp">[2014-04-29 Tue 07:29]</span></span>

2.  DONE Place MySQL access credentials into a config file and remove it from the perl scripts <code>[1/1]</code>.

    -   State "DONE"       from "TODO"       <span class="timestamp-wrapper"><span class="timestamp">[2014-04-29 Tue 07:30]</span></span>

    -   [X] `check_update_Ensembl.pl`
