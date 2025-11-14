# SPDX-License-Identifier: GPL-3.0-or-later
# Author: Sander Stolk <s.s.stolk@hum.leidenuniv.nl>
# Copyright (C) 2025  Leiden University

# LICENSE STATEMENT:
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


#########################################
#           EXAMPLE USE                 #
#########################################
# Run the following in PowerShell
# .\kalliope-letters2csv.ps1 -url "..URL-HERE.."


#########################################
#        SCRIPT PARAMETERS              #
#########################################
param (
    # url of website search
    [string]$url, #= "https://kalliope-verbund.info/de/query?q=sievers&htmlFull=false&fq=%2Bgi.unitdate_end%3A%5B1800%20TO%209999%5D%20%2Bgi.unitdate_start%3A%5B-9999%20TO%202000%5D&fq=ead.creator.index%3A%28%22Sievers%2C%20Eduard%20%281850-1932%29%22%29&lang=de&fq=ead.addressee.index%3A%28%22Zarncke%2C%20Friedrich%20%281825-1891%29%22%29&lastparam=true",
       # DECODED = "https://kalliope-verbund.info/de/query?q=sievers&htmlFull=false&fq=+gi.unitdate_end:[1800 TO 9999] +gi.unitdate_start:[-9999 TO 2000]&fq=ead.creator.index:("Sievers, Eduard (1850-1932)")&lang=de&fq=ead.addressee.index:("Zarncke, Friedrich (1825-1891)")&lastparam=true"
    [string]$dir, #=".\out",
    [string]$xslt #=".\kalliopeLetters2csv.xslt"
)


#########################################
#               MAIN                    #
#########################################
If (!$url) {
  Write-Output 'Please provide a Kalliope website search URL, e.g.,
  
./kalliope-letters2csv -url "https://kalliope-verbund.info/de/query?q=sievers&htmlFull=false&fq=%2Bgi.unitdate_end%3A%5B1800%20TO%209999%5D%20%2Bgi.unitdate_start%3A%5B-9999%20TO%202000%5D&fq=ead.creator.index%3A%28%22Sievers%2C%20Eduard%20%281850-1932%29%22%29&lang=de&fq=ead.addressee.index%3A%28%22Zarncke%2C%20Friedrich%20%281825-1891%29%22%29&lastparam=true"

or provide a Kalliope SRU URL, e.g.,

./kalliope-letters2csv -url https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query=ead.unitdate<=2020%20AND%20ead.unitdate>=1800%20AND%20ead.creator.index="Sievers%2C%20Eduard%20%281850-1932%29"%20AND%20ead.addressee.index="Zarncke%2C%20Friedrich%20%281825-1891%29"';
  Exit 0;
}
If (!$dir) {
  $dir = ".\out"
}
If (!$xslt) {
  $xslt = ".\kalliopeLetters2csv.xslt";
}

If (!$url.StartsWith("https://kalliope-verbund.info/sru")) {
  $url =  & "./kalliope-site2sru.ps1" -url $url
  Write-Output ".. transformed Kalliope website url to SRU url: $($url)"
}

$recordcount = & "./kalliope-recordcount.ps1" -url $url
Write-Output ".. retrieved the following record count for the query: $($recordcount)"

Write-Output '.. starting to fetch records'
& "./fetch-pages.ps1" -url $url -itemCount $recordcount -itemOne 1 -pageSize 5000 -pageSizeVariable "maximumRecords" -itemStartVariable "startRecord" -dir "$($dir)" -ext "xml"

Write-Output '.. starting to transform XML record files to CSV files'
& "./xslt-transform-dir.ps1" -script "$($xslt)" -dirIn "$($dir)" -dirOut "$($dir)" -ext "csv"

Write-Output '.. starting to merge CSV files'
& "./merge-csvs-dir.ps1" -dir "$($dir)" -out "$($dir)\merged.csv"
