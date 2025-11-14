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
# .\fetch-pages.ps1 -url "https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query=ead.repository.index=(%22Universit%C3%A4tsbibliothek+Leipzig%22)%20AND%20ead.genre.index=(%22Brief%22)%20AND%20ead.unitdate%3E=1786%20AND%20ead.unitdate%3C=1914" -itemCount 127138 -itemOne 1 -pageSize 5000 -pageSizeVariable "maximumRecords" -itemStartVariable "startRecord" -dest ".\out" -ext "xml"


#########################################
#        SCRIPT PARAMETERS              #
#########################################
param (
    # url to fetch, without parameters for page or start item etc.
    [string]$url
)


#########################################
#            FUNCTIONS                  #
#########################################

#########################################
# Function: downloads the $url and stores it as the path indicated by $file
#########################################
  
  # SRU example
  # "https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query="
  # "ead.repository.index=(%22Universit%C3%A4tsbibliothek+Leipzig%22)%20AND%20ead.genre.index=(%22Brief%22)%20AND%20ead.unitdate%3E=1786%20AND%20ead.unitdate%3C=1914"


function Esc {
  param (
    [string]$s
  )
  $s = $s -replace "\\", "\\";
  $s = $s -replace "\?", "\?";
  $s = $s -replace "\.", "\.";
  return $s;
}


#########################################
#               MAIN                    #
#########################################
function Kalliope-Site2SRU {
  param (
    [string]$url
  )

  if (!$url) {
    Write-Error "No Website URL was supplied for Kalliope"
    Exit 1;
  }
  
#  https://kalliope-verbund.info/de/query?q=sievers&htmlFull=false&fq=%2Bgi.unitdate_end%3A%5B1800%20TO%209999%5D%20%2Bgi.unitdate_start%3A%5B-9999%20TO%202000%5D&fq=ead.creator.index%3A%28%22Sievers%2C%20Eduard%20%281850-1932%29%22%29&lang=de&fq=ead.addressee.index%3A%28%22Zarncke%2C%20Friedrich%20%281825-1891%29%22%29&lastparam=true
  $pattern = (Esc "htmlFull=false&");
  $url = $url -replace $pattern, "";
  $pattern = (Esc "https://kalliope-verbund.info/")+"[^\?]*"+(Esc "?");
  $url = $url -replace $pattern, "https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query=";
  $pattern = "&query=q=([^&]*)&";           #"([^f])q=([^&]*)&";
  $url = $url -replace $pattern, "&query="; # "$1"

  # ead.addressee
  # Beispiel: ead.addressee="Adenauer, Konrad"
  $pattern = (Esc "fq=ead.addressee.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.addressee.index="$1"%20AND%20';

  # ead.creator
  # Beispiel: ead.creator="Kady, Muhammed"
  $pattern = (Esc "fq=ead.creator.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.creator.index="$1"%20AND%20';
  
  # ead.genre
  # Beispiel: ead.genre="Tagebuch"
  $pattern = (Esc "fq=ead.genre.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.genre.index=(%22$1%22)%20AND%20';

  # ead.repository
  # Beispiel: ead.repository="Forschungsbibliothek Gotha"
  $pattern = (Esc "fq=ead.repository.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.repository.index=(%22$1%22)%20AND%20';

  # ead.unitdate
  # Beispiel: ead.unitdate="1855"
  $pattern = (Esc "fq=%2Bgi.unitdate_start%3A%5B-9999%20TO%")+"(....)"+(Esc "00%5D%20%2Bgi.unitdate_end%3A%5B")+"(....)"+(Esc "%20TO%209999%5D&");
  $url = $url -replace $pattern, 'ead.unitdate<=$1%20AND%20ead.unitdate>=$2%20AND%20';
  $pattern = (Esc "fq=%2Bgi.unitdate_end%3A%5B")+"(....)"+(Esc "%20TO%209999%5D%20%2Bgi.unitdate_start%3A%5B-9999%20TO%")+"(....)"+(Esc "00%5D&");
  $url = $url -replace $pattern, 'ead.unitdate<=$2%20AND%20ead.unitdate>=$1%20AND%20';
  $pattern = (Esc "fq=%2Bgi.unitdate_start%3A%5B-9999%20TO%")+"(....)"+(Esc "00%5D&");
  $url = $url -replace $pattern, 'ead.unitdate<=$1%20AND%20';
  $pattern = (Esc "fq=%2Bgi.unitdate_end%3A%5B")+"(....)"+(Esc "%20TO%209999%5D&");
  $url = $url -replace $pattern, 'ead.unitdate>=$1%20AND%20';
  
  $pattern = (Esc "%20AND%20lastparam=true");
  $url = $url -replace $pattern, "";
  
  $pattern = (Esc "lang=[^%&]*&");
  $url = $url -replace $pattern, "";
  
  # TODO: if it still contains a fq=, then throw error or log "could not translate it, so removed it, but query incomplete"

  return $url
}


#########################################
#               START                   #
#########################################

Kalliope-Site2SRU -url $url