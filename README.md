# ShinyParts

ShinyParts is a user-friendly R-based tool designed to visualise the distribution
of textual environments within corpora, for use in textometrics and corpus
linguistics. It is distributed under the GNU-GPL 3 license.

It was developed by Timothée Premat, postdoctoral researcher at Université
Paris-Est Créteil (Céditec lab., associated with Modyco lab.), as part of the
ArchivU project (<https://archivu.hypotheses.org>).

## Citation

To cite this tool in academic work, please use:

> Premat, Timothée (2026). *ShinyParts: An R tool to map the distribution of
environments in texts*. https://github.com/TimotheePremat/ShinyParts

The following paper provides the first published use of ShinyParts:

> Lethier, Virginie, Émilie Née and Timothée Premat (2026). "Des dynamiques
entre un genre de discours et un agencement textuel : le cas de la liste dans
les rapports d'activité de laboratoire (1970-2018)". [To appear in the
proceedings of the 2026 CMLF congress]

## Requirements

ShinyParts runs entirely in R. Required packages are automatically installed
if missing and loaded at startup.

## Getting started

Open `main.r` in your R environment (R, RStudio, etc.) and run it. A
graphical user interface (GUI) will open in your default web browser.

## Overview

ShinyParts allows users to visualise the size and position of textual
environments within a corpus, based on data extracted from corpus linguistics
software such as TXM. It also produces a set of graphs describing the
distribution of environments across the corpus.

The Shiny GUI allows users to modify the dataset and customise plots.
Plots are not saved automatically — they must be exported through the GUI
before closing the application.

## Plots produced

Environments are plotted against the *background* — defined as every token in
the text that does not belong to any of the studied environments.

> The examples below come from the ArchivU project, specifically work on lists
in French academic reporting. `liste-vert` refers to vertical lists;
`listes-horiz` refers to horizontal (inline) lists.

### Relative size of environments in the corpus

<img src="https://phonodiachro.hypotheses.org/files/2025/11/qty_plot_2025-11-06-scaled.png"
alt="Plot of the relative size of lists in a corpus of French academic reporting" width="500">

### Size of texts in the corpus

<img src="https://phonodiachro.hypotheses.org/files/2025/11/size_plot_2025-11-06-scaled.png"
alt="Plot of text sizes in a corpus of French academic reporting" width="700">

### Chronological evolution of the relative size of environments

<img src="https://phonodiachro.hypotheses.org/files/2025/11/time_series_2025-11-06-scaled.png"
alt="Plot of the chronological evolution of list size in a corpus of French academic reporting" width="700">

### Mapping of environments onto text length

<img src="https://phonodiachro.hypotheses.org/files/2025/11/map_all_2025-11-06-1.png"
alt="Plot mapping lists onto text length in a corpus of French academic reporting" width="700">

In this plot:
- each token is mapped by its position within the text (left to right: x-axis)
- the y-axis carries no meaning
- colours encode typological information (here: list type)
- both individual text plots and a full-corpus overview are available

## Input files

ShinyParts accepts two input methods:

- **Multi-file method**: one file containing all tokens of the corpus, and one
file per environment type containing all tokens belonging to that environment
(with the environment type as the filename).
- **One-file method**: one file containing all tokens of the corpus, and one
file containing all tokens belonging to the environments under study, with
environment types encoded in one or more columns.

> In the example above, the second file would contain all tokens belonging to a list.

In both cases, the dataset must include:
- a column with date information
- a column with a unique text identifier
- a column with the token's position within its text
- one token per row (typically, one word per line)

For the *one-file method*, an additional requirement applies:
- one or more columns must encode the environment type assigned to each token

The one-file method is the default, to activate multi-file method (typological
information stored in columns), turn on the *Manually set type* switch.

The one-file method supports **nested environments**, with one column per
nesting level. Low-level environments are always favoured (i.e., a word belonging
to a environment in another environment is attributed to the lowest environment
only).

The GUI prompts the user to identify the required columns, so column names in
the imported dataset are not constrained.

## Use with TXM

Datasets can be produced using various corpus linguistics tools. For use with
TXM (the French textometry platform), the recommended procedure is:

- use the concordancer
- set both left and right context to empty (they are unnecessary and add weight)
- encode the required metadata in the Reference column (mandatory: `text_id`, `n`, `date`)

### Querying environments in TXM

To retrieve all tokens belonging to an environment, place its name in brackets:
`[list]` returns every token parsed under a `<list>` node in the XML structure.

To filter by environment type, use the `_.` syntax:
`[._list_type="inline"]` returns every token under a `<list type="inline">` node.

By default, TXM queries do not recurse into nested structures. During import,
TXM appends indices to structural properties of nested elements, so that:
`[_.list_type1="inline"]` returns tokens under a `<list type="inline">` node
that is itself nested inside another `<list>` node.

For the plots shown above, the following queries were used with the multi-file method:
- `[]` — all tokens in the corpus
- `[_.list_type="inline"]` — tokens belonging to inline lists
- `[_.list_type!="inline"]` — tokens belonging to non-inline lists (e.g. numbered, bulleted)

## Caveats

### Overlapping environments

Overlapping environments should be avoided by carefully designing queries in
the corpus software. For instance, if studying both lists and headings where
lists may contain headings, one should define separate queries for:
list headings, list bodies (excluding headings), and standalone headings.

Overlapping environments will appear as stacked bars in the plots.

> The background always overlaps with environments by construction. ShinyParts
automatically removes from the background any token found in an environment,
based on text-ID and position matching.

### Performance

For large corpora, processing can be computationally intensive. The Shiny
interface may take several seconds to refresh after each operation. This is
expected behaviour — the application is processing in the background.
