# kalliope2csv

This repository contains a number of helpful Powershell scripts to work with Kalliope data.
- `fetch-pages.ps1` - Fetches Kalliope records, storing them across multiple files if necessary
- `kalliope-recordcount.ps1` - Fetches the number of records behind a Kalliope SRU URL 
- `kalliope-site2sru.ps1` - Changes a Kalliope website search URL to a Kalliope SRU URL 
- `merge-csvs-dir.ps1` - Merges multiple CSVs found in a directory
- `xslt-transform-dir.ps1` - Transforms all XMLs in a directory using an XSLT stylesheet

Additionally, it contains two files specifically used within the research project [EMERGENCE](https://www.universiteitleiden.nl/en/research/research-projects/humanities/emergence).
- `kalliope-letters2csv.ps1` - Powershell to help fetch and transform Kalliope data on Letters, utilizing all scripts mentioned above in the desired order
- `kalliopeLetters2csv.xslt` - XSLT stylesheet to transform Kalliope XML files on Letters to appropriate CSV files

Use of these scripts are shown as comments inside each script itself.
Running the main script can be as simple as opening Powershell in Windows and running:

```./kalliope-letters2csv -url "..URL HERE.."```

Examples (the first using the URL of a Kalliope website search, the second using their SRU):

```./kalliope-letters2csv -url "https://kalliope-verbund.info/de/query?q=sievers&htmlFull=false&fq=%2Bgi.unitdate_end%3A%5B1800%20TO%209999%5D%20%2Bgi.unitdate_start%3A%5B-9999%20TO%202000%5D&fq=ead.creator.index%3A%28%22Sievers%2C%20Eduard%20%281850-1932%29%22%29&lang=de&fq=ead.addressee.index%3A%28%22Zarncke%2C%20Friedrich%20%281825-1891%29%22%29&lastparam=true"```

```./kalliope-letters2csv -url https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query=ead.unitdate<=2020%20AND%20ead.unitdate>=1800%20AND%20ead.creator.index="Sievers%2C%20Eduard%20%281850-1932%29"%20AND%20ead.addressee.index="Zarncke%2C%20Friedrich%20%281825-1891%29"```

## Credits and thanks
Author scripts: Sander Stolk
Author stylesheet: Sander Stolk, Thijs Porck
Made possible with the ERC funding for the [EMERGENCE](https://www.universiteitleiden.nl/en/research/research-projects/humanities/emergence) project.

## License
GNU General Public License v3
