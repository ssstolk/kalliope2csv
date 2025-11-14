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
# .\xslt-transform-dir.ps1 -script ".\kalliopeLetters2csv.xslt" -dirIn ".\out" -dirOut ".\out" -ext "csv"

#########################################
#        SCRIPT PARAMETERS              #
#########################################
param (
    # file path to XSLT transformation stylesheet
    [string]$script,
    # directory in which to find input files
    [string]$dirIn = ".",
    # directory in which to store transformed files
    [string]$dirOut = ".\out",
    # file extension of transformed files
    [string]$ext
)


#########################################
#            FUNCTIONS                  #
#########################################

#########################################
# Function: applies the XSLT $script to $file and stores the outcome in the output directory
#########################################
function Transform {
  param (
    [string]$file,
    [string]$script
  )
  
  $in = "$dirIn\$file"
  $inFullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($in)
  $out = [System.IO.Path]::ChangeExtension("$dirOut\$file", ".$ext")
  $outFullPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($out)
  New-Item -ItemType Directory -Force -Path $dirOut | Out-Null
  $inCreationDate = (Get-Item $inFullPath).CreationTime.ToString("yyyy-MM-dd")
  
  $xsltSettings = New-Object System.Xml.Xsl.XsltSettings
  $xsltSettings.EnableDocumentFunction = 1
  [Xml]$xsltScript = Get-content -Encoding UTF8 $script -Raw
  
  $argList = New-Object System.Xml.Xsl.XsltArgumentList
  $argList.AddParam("content-date", "", $inCreationDate)

  $xslt = New-Object System.Xml.Xsl.XslCompiledTransform
  $xslt.Load($xsltScript, $xsltSettings, $(New-Object System.Xml.XmlUrlResolver))

  Write-Output "... creating `"$outFullPath`"  [content-date: $inCreationDate]"
#  $outStream = New-Object IO.FileStream $outFullPath, ([System.IO.FileMode]::Create)
  $outStream = [IO.StreamWriter]::New($outFullPath, [Text.UTF8Encoding])
  $xslt.Transform($inFullPath, $argList, $outStream)
  $outStream.Dispose()
}

   
#########################################
#               MAIN                    #
#########################################

Get-ChildItem $dirIn -Filter *.xml | ForEach-Object {
    Transform -file $_.Name -script $script
}
