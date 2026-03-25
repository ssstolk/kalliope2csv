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
# .\kalliope-site2sru.ps1 -url "https://kalliope-verbund.info/search.html?q=%22Siegfried%20Lenz%22&lastparam=true"


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
    Write-Error "No Website URL was supplied for Kalliope";
    Exit 1;
  }
  
  $pattern = (Esc "htmlFull=false&");
  $url = $url -replace $pattern, "";
  $pattern = (Esc "https://kalliope-verbund.info/")+"[^\?]*"+(Esc "?");
  $url = $url -replace $pattern, "https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query=";

  # ead.addressee
  # Beispiel: ead.addressee="Adenauer, Konrad"
  $pattern = "f?q="+(Esc "ead.addressee.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.addressee.index="$1"%20AND%20';
  
  $pattern = "f?q="+(Esc "ead.addressee.gnd%3D%3D%22")+"([^&]*)"+(Esc "%22&");
  $url = $url -replace $pattern, 'ead.addressee.gnd=%22$1%22%20AND%20';

  # ead.creator
  # Beispiel: ead.creator="Kady, Muhammed"
  $pattern = "f?q="+(Esc "ead.creator.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.creator.index="$1"%20AND%20';
  
  $pattern = "f?q="+(Esc "ead.creator.gnd%3D%3D%22")+"([^&]*)"+(Esc "%22&");
  $url = $url -replace $pattern, 'ead.creator.gnd=%22$1%22%20AND%20';
  
  # ead.otherroles
  # Beispiel: ead.otherroles="Kady, Muhammed"
  $pattern = "f?q="+(Esc "ead.otherroles.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.otherroles.index="$1"%20AND%20';
  
  $pattern = "f?q="+(Esc "ead.otherroles.gnd%3D%3D%22")+"([^&]*)"+(Esc "%22&");
  $url = $url -replace $pattern, 'ead.otherroles.gnd=%22$1%22%20AND%20';
  
  # ead.genre
  # Beispiel: ead.genre="Tagebuch"
  $pattern = "f?q="+(Esc "ead.genre.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.genre.index=(%22$1%22)%20AND%20';

  # ead.repository
  # Beispiel: ead.repository="Forschungsbibliothek Gotha"
  $pattern = "f?q="+(Esc "ead.repository.index%3A%28%22")+"([^&]*)"+(Esc "%22%29&");
  $url = $url -replace $pattern, 'ead.repository.index=(%22$1%22)%20AND%20';

  # ead.unitdate
  # Beispiel: ead.unitdate="1855"
  $pattern = "f?q="+(Esc "%2Bgi.unitdate_start%3A%5B-9999%20TO%")+"(....)"+(Esc "00%5D%20%2Bgi.unitdate_end%3A%5B")+"(....)"+(Esc "%20TO%209999%5D&");
  $url = $url -replace $pattern, 'ead.unitdate<=$1%20AND%20ead.unitdate>=$2%20AND%20';
  $pattern = "f?q="+(Esc "%2Bgi.unitdate_end%3A%5B")+"(....)"+(Esc "%20TO%209999%5D%20%2Bgi.unitdate_start%3A%5B-9999%20TO%20")+"(....)"+(Esc "%5D(%20)")+"?"+(Esc "&");
  $url = $url -replace $pattern, 'ead.unitdate<=$2%20AND%20ead.unitdate>=$1%20AND%20';
  $pattern = "f?q="+(Esc "%2Bgi.unitdate_start%3A%5B-9999%20TO%")+"(....)"+(Esc "00%5D&");
  $url = $url -replace $pattern, 'ead.unitdate<=$1%20AND%20';
  $pattern = "f?q="+(Esc "%2Bgi.unitdate_end%3A%5B")+"(....)"+(Esc "%20TO%209999%5D&");
  $url = $url -replace $pattern, 'ead.unitdate>=$1%20AND%20';
  
  $pattern = (Esc "%20AND%20lastparam=true");
  $url = $url -replace $pattern, "";
  
  $pattern = (Esc "lang=[^%&]*&");
  $url = $url -replace $pattern, "";
  
  # full text searches
  $pattern = "&query=q=%22([^&]*)%22&";
  $url = $url -replace $pattern, '&query=gi.index%20adj%20%22$1%22&';
  $pattern = "&query=q=([^&]*)&";
  $url = $url -replace $pattern, '&query=gi.index=$1&';

  # if query parameters remain, write error indicating untranslated parameter and exit
  if ($url -contains "fq=") {
    $pattern = ".*[?&](fq=[^&$]*).*";
    $fqparam = $url -replace $pattern, '$1';
    Write-Error "URL contains query parameter not yet supported in translation script: " + $searchparam;
    Exit 1;
  }

  return $url;
}


#########################################
#               START                   #
#########################################

Kalliope-Site2SRU -url $url