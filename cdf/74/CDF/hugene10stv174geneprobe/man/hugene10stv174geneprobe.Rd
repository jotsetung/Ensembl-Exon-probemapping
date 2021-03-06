\name{hugene10stv174geneprobe}
\docType{data}
\alias{hugene10stv174geneprobe}
\title{Probe sequence for Affymetrix HuGene microarrays.}
\description{This data object contains probe sequences for all probes/probesets defined in the hugene10stv174genecdf CDF file/package version 0.3.0.}
\usage{data(hugene10stv174geneprobe)}
\format{A data frame with xx rows and 6 columns, as follows.
  \tabular{lll}{
    sequence \tab character \tab probe sequence \cr
    x  \tab integer  \tab x-coordinate on the array \cr
    y  \tab integer  \tab y-coordinate on the array \cr
    Probe.Set.Name      \tab character \tab Affymetrix Probe Set Name \cr
    Probe.Interrogation.Position \tab integer \tab Probe Interrogation Position \cr
    Target.Strandedness \tab factor \tab Target Strandedness\cr
}}

\source{The probe sequence data was provided by Affymetrix. The probe file was generated by the make_gene_cdf_from_db.pl perl function for the generation of custom/remapped CDF files for Affymetrix Gene ST arrays.}

\keyword{datasets}
\examples{
  data( hugene10stv174geneprobe )
  as.data.frame(hugene10stv174geneprobe[1:3,])
}
