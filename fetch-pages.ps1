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
# .\fetch-pages.ps1 -url "https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query=ead.repository.index=(%22Universit%C3%A4tsbibliothek+Leipzig%22)%20AND%20ead.genre.index=(%22Brief%22)%20AND%20ead.unitdate%3E=1786%20AND%20ead.unitdate%3C=1914" -itemCount 127138 -itemOne 1 -pageSize 5000 -pageSizeVariable "maximumRecords" -itemStartVariable "startRecord" -dir ".\out" -ext "xml"


#########################################
#        SCRIPT PARAMETERS              #
#########################################
param (
    # url to fetch, without parameters for page or start item etc.
    [string]$url,
    # directory in which to store files
    [string]$dir = ".\out",
    # file extension of fetched resources
    [string]$ext = 'xml',

    # item variables 
    [int]$itemCount,
    [int]$itemOne = 1,   # is the first item considered item 0 or item 1?
    [string]$itemStartVariable = "startRecord",

    # page variables
    [string]$pageSizeVariable = "maximumRecords",
    [int]$pageSize = 5000,
    [int]$pageOne = 1,   # is the first item considered page 0 or page 1?
    [int]$pageCount,
    [string]$pageStartVariable
)


#########################################
#            FUNCTIONS                  #
#########################################

#########################################
# Function: downloads the $url and stores it as the path indicated by $file
#########################################
function Download {
  param (
    [string]$url,
    [string]$file
  )
  
#  Remove-Item alias:curl
#  curl $Url

  $dest = "$dir\$file"
  Write-Output "... downloading to `"$dest`""
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  Invoke-WebRequest -Uri $url -OutFile $dest
}


#########################################
#               MAIN                    #
#########################################

If ($pageStartVariable) {
  if ($pageCount -eq $null) {
    $pageCount = ($itemCount / $pageSize) + 1
  }
  For ($pagesRequested=0; $pagesRequested -lt $pageCount; $pagesRequested++) {
    $pageStart = $pageOne + $pagesRequested
    $file = "p$pageStart.$ext"
    Download -url "$url&$pageSizeVariable=$pageSize&$pageStartVariable=$pageStart" -file $file
  }
}
ElseIf ($itemStartVariable) {
  For ($itemsRequested=0; $itemsRequested -lt $itemCount; $itemsRequested+=$pageSize) {
    $itemStart = $itemOne + $itemsRequested
    $itemEnd = ($itemStart + $pageSize)-1
    If ($itemStart -gt $itemCount) {
      Break
    }
    If ($itemEnd -gt $itemCount) {
      $itemEnd = $itemCount
    }
    $file = "i$itemStart-$itemEnd.$ext"
    Download -url "$url&$pageSizeVariable=$pageSize&$itemStartVariable=$itemStart" -file $file
  }
}
