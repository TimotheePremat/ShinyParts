This is a simple, user-friendly R script intended to provide visualisations of
parts of texts for textometrics. It is distributed under GNU-GPL 3 license.
It has been developed by Timothée Premat, then postdoctoral researcher at Univ.
Paris-Est Créteil (Céditec lab. & associated to Modyco lab.) in the ArchivU
project (<https://archivu.hypotheses.org>).

# Requisites

Script only uses R; the needed packages are downloaded if missing and loaded
automatically.

# Run the script

Open `main.R` in your R software (R, RStudio, etc.) and run it. A Graphic User
Interface (GUI) should then open in a web browser.

# What does it do?

This script is intended to allow for the visualisation of the size and position
of environments in texts, based on extraction from corpus linguistics software
such as TXM. It also produces a number of graphs describing the distribution of
envs in the corpus.

The Shiny graphic user interface (GUI) allows the user to apply some changes to
the dataset and to customise the plots. Plots are not automatically saved; user
must save them through the GUI before closing the app.

### Plot produced

Environments are plots against the rest of the text, called `background` (every
word of the text(s) that is not parsed into one of the studied environment).

> The following examples come from the work of the ArchivU project, in particular our work on
lists in academic reporting. `liste-vert` is short for `vertical lists`, and
'listes-horiz' is short for `horizontal lists`, i.e. lists inline.

#### Description of envs in corpus
The program produces the following plots:

#### Relative size of the environments
<img src="https://phonodiachro.hypotheses.org/files/2025/11/qty_plot_2025-11-06-scaled.png" alt="Plot of size of texts in a corpus of French academic reporting" width="500">

#### Size of the texts of the corpus
<img src="https://phonodiachro.hypotheses.org/files/2025/11/size_plot_2025-11-06-scaled.png" alt="Plot of relative size of lists in a corpus of French academic reporting" width="700">

#### Chronological evolution of the relative size of the environments
<img src="https://phonodiachro.hypotheses.org/files/2025/11/time_series_2025-11-06-scaled.png" alt="Plot of the chronology of relative size of lists in a corpus of French academic reporting" width="700">

#### Mapping of envs onto text lenght
<img src="https://phonodiachro.hypotheses.org/files/2025/11/map_all_2025-11-06-1.png" alt="Plot mapping the lists onto text lenght in a corpus of French academic reporting" width="700">

Where:
- every word of the text is mapped by position (from left to right: x-axis)
- y-axis is meaningless
- colours match a typological information (here: type of list)
- both individual plots and plot of all the texts are available

## Input files

The script works with two input methods, either:
- **Multi-file method**: one file comprising all the words of the corpus and
one file per environment comprising all the words of this environment, with their
type as file name.
- **One file method**: one file comprising all the words of the corpus and one
file comprising all the words of the environments to be studied, with their type
in one or several columns.

> Following our example above, the second file would contain all the words
belonging to a list.

In all cases, the following requisites apply:
- a column must contain a date information
- a column must contain a unique text-ID
- a column must contain the number the word in the text
- there should be only one token per line (usually, one word)

For the *One file method* (which mean: one file *for the environments*, not in total),
there is an additional requisite:
- one or several columns must contain the type of environment applied to the word

The *One file method* allows to deal with nested environments, with one column
for envs of level 1, one for envs of level 2, and so on. The GUI asks the user
if they want to favour low-lavel or high-level envs, by keeping the first or last
non-null value in the set of columns defined as containing nesting types.

The GUI asks the user to select the obligatory columns, so that columns names in
the imported dataset is irrelevant.

## For use with TXM

Datasets can be produced through different corpus linguistics softwares. For use
with TXM, the French textometry software, one can follow this procedure:
- use concordancer
- empty right and left context (useless and heavy)
- parse into col Reference the needed metadata (obligatory: text_id, n, date)

To access words comprised in environments in TXM CQL queries, you can simply
put the name of the environment between brackets. `[list]` outputs every word that
is parsed under a `<list>` node in the XML structure.

To access words belonging to an environment of a given type, you can use the `_.`
syntax: `[._list_type="inline"]` outputs every word that is parsed under a `<list type="inline">`
node in the XML structure.

By default, such queries do not access nesting and only 'sees' the first level.
During import, TXM appends indices to nested structural properties, so that a nested
env has a different name than a non-nested one: `[_.list_type1="inline"]` outputs
every word that is parsed under a `<list type="inline">` node itself parsed under another
`<list>` node in the XML structure.

For the plots exemplified above, using the *Multi-file* input method, the queries used are:
- `[]` to capture every word of the texts
- `[_.list_type="inline"]` to capture words that are part of inline lists
- `[_.list_type!="inline"]` to capture words that are part of non-inline lists
(if there are several type of lists that are not inline, e.g. "numbered", "bulleted")

## Caveat

### A note on overlapping
On the textograph, overlapping between environments is to be avoided by carefully designing the queries in the corpus query software (or other). For instance, if
one wants to work on lists and headings,
and if lists have headings, they should design requests for headings that are not
list-headings, lists bodies (excluding the headings), and list-headings.
Stacking of bars in a graph signals overlapping.

> Background always overlap envs; the script deletes from background every word
that is found in envs (based on text-ID and number match)


### A note on performance
For large corpora, the computational load can be heavy. In such cases, the Shiny
interface might take a few seconds to refresh after each operation. This might
be a bit frustrating, be patient, nothing shows up but the script is (probably)
just doing its thing.
