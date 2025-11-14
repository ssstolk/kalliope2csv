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
# .\kalliope-recordcount.ps1 -url "https://kalliope-verbund.info/sru?version=1.2&operation=searchRetrieve&recordSchema=mods37&query=ead.repository.index=(%22Universit%C3%A4tsbibliothek+Leipzig%22)%20AND%20ead.genre.index=(%22Brief%22)%20AND%20ead.unitdate%3E=1786%20AND%20ead.unitdate%3C=1914"


#########################################
#        SCRIPT PARAMETERS              #
#########################################
param (
    # url to fetch, without parameters for page or start item etc.
    [string]$url
)


#########################################
#               MAIN                    #
#########################################

$url = "$($url)&maximumRecords=1"
$response = Invoke-WebRequest -Uri $url
[ xml ]$xml = $response
$ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
$ns.AddNamespace("srw", "http://www.loc.gov/zing/srw/")
$xpath = "/srw:searchRetrieveResponse/srw:numberOfRecords"
$recordCount = $xml.SelectSingleNode($xpath, $ns)  | Select-Object -Expand '#text'
return $recordCount
