
# Rendering GED files to family trees 

This tool takes a file in the [GEDCOM](https://en.wikipedia.org/wiki/GEDCOM) format produced by a genealogic software 
and produces a family tree in the [Scalable Vetor Graphic](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics) 
format suitable for later editing and printing.

## Installation

_ged2svg_ tool is written in Ruby and has only one dependency -- 
Jim Weirich's [builder](https://github.com/jimweirich/builder) gem.

Simply clone this repo and:

        cd ged2svg
        bundle install

## Usage

Since rich family trees are hard to render some pruning trade-ofs were necessary. 

        ./ged2svg.rb  '@I500339@'  '@I500005@'  family.ged  output.svg

Arguments are:
1. Reference to the _root_ individual who is the oldest ancestor to render (mandatory).
2. Reference to the _central_ individual who is the ancestor of generations fully rendered (optional).
3. Path to the input family records file in the GEDCOM format (mandatory).
4. Path to the output family tree file in the SVG format (mandatory).

References ([INDI](http://homepages.rootsweb.ancestry.com/~pmcbride/gedcom/55gcch2.htm#XREF:INDI) identifiers) are used 
in the GEDCOM file to uniquelly adress records of particular individual.

If the GED file contains branches to non-root ancestors some individual records are pruned. The individual is rendered 
if he/she is the partner or the direct descendant of the root individual, recursively. It means that partner's ancestors 
or children of the partner from other families are not rendered.

If the central individual reference is missing the family tree is fully rendered from the root ancestor to the youngest 
ones (tree leafs).

When the central individual is specified by it's reference (who has to be the direct descendant of the root individual) 
than rendering of generations between root and central individuals is simplified. It means that families between root 
and central individuals are rendered but other families between them are hinted showing only siblings and their 
partners.

It is likely the resultant _output.svg_ file will have to be post-processed. Try to use un-group the tree repeatedly in 
your graphics editor.

## Limitations & Possible future improvements

* SVG outputs are tested only in [Inkscape](https://inkscape.org/en/).
* Only given names, surnames, birth and death dates are rendered in individual's box.
* Dates are in the DD.MM.YYYY format only.
* SVG formatting styles (CSS) information are hardcoded in constants in the beginning of the _render_tree.rb_ source 
file.
* More than two spouses are not supported.
* Full render mode produces big gaps since the recursive nature of the rendering algorithm. The best solution is to 
extend it to use the space allocation memories and/or shuffling heuristics. The current implementation is the balanced 
trade-of between the result tree quality and simplicity.
* Parsing the complex (and pretty outdated) GEDCOM format is somehow hacked rather than painfully 
[engineered](https://github.com/rbur004/gedcom). Some edge cases might not be parsed correctly.

## License

(c) 2017 Pavel Suchmann under [GNU v3](https://www.gnu.org/licenses/gpl-3.0.en.html).

Please help to break the walls of genealogy data gardens.
