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
# .\merge-csvs-dir.ps1 -dir ".\out" -out ".\out\merged.csv"

#########################################
#        SCRIPT PARAMETERS              #
#########################################
param (
    # directory in which to find input csv files
    [string]$dir = ".",
    # file to store results in of merging
    [string]$out = ".\out\merged.csv"
)


#########################################
#               MAIN                    #
#########################################

#Get-ChildItem $dir -Filter *.csv | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv $out -NoTypeInformation -Append -Encoding UTF8
$items = Get-ChildItem $dir -Filter *.csv | Select-Object -ExpandProperty FullName
Write-Output "... found files:"
Write-Output $items
Write-Output "... merging files into `"$out`""
Import-Csv $items | Export-Csv $out -NoTypeInformation -Append -Encoding UTF8