---
title: 'TraitDB: Web application database of phenotypic trait data.'
tags:
  - trait
  - rails
  - csv
authors:
 - name: Dan Leehr
   orcid: 0000-0003-3221-9579
   affiliation: "1"
 - name: Mercedes Gosby
   affiliation: "1"
affiliations:
 - name: National Evolutionary Synthesis Center
   index: 1
date: 20 July 2018
bibliography: paper.bib
---

# Summary

TraitDB is a web application built to facilitate storage, searching, subsetting, and sharing trait data from multiple sources.

Many software packages are available to store structured and unstructured relational data alike. From graphical spreadsheets to query-powered database engines, these software excel at the direct ingesting, storing, and vending homogenous datasets.

When synthesizing multiple heterogenous datasets together, these software can still serve as vital infrastructure, but by design do not enforce requirements on organization, categorization, or uniformity.

As a result, well-intentioned efforts to maintain data integrity can easily fall short in the face of building complicated validation and transformation routines to fit datasets into a common schema.

Through work with multiple [NESCent](http://nescent.org/) working groups, we observed and supported real-world efforts to build a database of traits by collecting and organizing thousands of trait data observations. We evaluated software including [OpenRefine](http://openrefine.org/), [SQLite Manager](https://addons.mozilla.org/en-US/firefox/addon/sqlite-manager-webext/), and [mx](https://github.com/mx3/mx) that aim to address many of these challenges.

While these software are technically proficient can facilitate robust operations, we found that individual researchers were most productive tabulating data from specimens or literature into local spreadsheets rather than an online application. At this level, they needed frictionless data entry of the records they had available, rather than tedious interactions. After collecting their data, they needed a robust process to validate, reconcile, and ingest records into the larger body.

Through collaboration, and iteration, we designed and built TraitDB to serve the use cases of these researchers. Primarily, TraitDB aids the ingest of datasets from different researchers working to synthesize a single, uniform dataset. Data ingest is driven by a flexible YAML template system, managed by the group. The process provides validation and cell-level feedback on input CSV datasets. It indicates which fields are required, warns of duplicate records, and performs validation on categorical and continuous variables. Prior to ingesting the data, TraitDB provides a structured report of warnings and requires  that any errors are corrected.

Once ingested, TraitDB provides several mechanisms for querying, browsing, subsetting, and fetching data via its web interface. It implements simple summary calculations of trait data over taxonomic levels, and provides CSV download of synthesized datasets for further analysis.

TraitDB has been used to gather and produce datasets hosted by the [Tree of Sex](http://bbrowse.biol.berkeley.edu/treeV2/styled/index.html).

# Acknowledgements

TraitDB is a project of [National Evolutionary Synthesis Center](http://nescent.org/)

# References
