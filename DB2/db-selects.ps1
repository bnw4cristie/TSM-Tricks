#! /bin/bash

##############################################################################
# changelog
# date        version remark
# 2024-04-08  0.0.1   recoded to powershell using MS copilot 
#                     DOES NOT WORK, JUST FIRST ATTEMPT
# 2020-08-XX  0.0.0   initial coding using bash
#
##############################################################################
#
# db-selects.ps1
# 
#   a script collecting some information from DB2 for offline reorg
#
#   The Author:
#   (C) 2020 -- 2024 Bjørn Nachtwey, tsm@bjoernsoe.net
#
#   Grateful Thanks to the Companies, who allowed to do the development
#   (C) 2023, 2024   Cristie Data Gmbh, www.cristie.de
#   (C) 2020 -- 2023 GWDG, www.gwdg.de
#
##############################################################################
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
##############################################################################

# MISSING: some checks, e.g. if current user can access DB2 and TSMDB1!

# list of tables to process
$tables = @(
    "ACTIVITY_LOG",
    "AF_SEGMENTS",
    "AF_BITFILES",
    "ARCHIVE_OBJECTS",
    "AS_SEGMENTS",
    "BACKUP_OBJECTS",
    "BF_AGGREGATE_ATTRIBUTES",
    "BF_AGGREGATED_BITFILES",
    "BF_BITFILE_EXTENTS",
    "BF_DEREFERENCED_CHUNKS",
    "GROUP_LEADERS",
    "EXPORT_OBJECTS",
    "REPLICATED_OBJECTS",
    "REPLICATING_OBJECTS",
    "SC_OBJECT_TRACKER",
    "SD_CHUNK_LOCATIONS",
    "SD_CHUNK_COPIES",
    "SD_RECON_ORDER",
    "SD_REFCOUNT_UPDATES",
    "SD_REPLICATING_CHUNKS",
    "SD_NON_DEDUP_LOCATIONS",
    "SD_REPLICATED_CHUNKS",
    "TSMMON_STATUS"
)

# Print headline
Write-Host ("{0,-25} ; {1,-15} ; {2,-15} ; {3,-15} ; {4,-25} ; {5,-10}" -f "Tabname", "object-Count", "est. time (sec)", "object-space", "space occupied by table", "Pagesize")

# For loop on all tables
foreach ($tab in $tables) 
{
  # get numbers
  $count = (db2 connect to tsmdb1 2>&1>/dev/null && db2 "select count_big(*) from tsmdb1.$tab" | Select-Object -Last 4 | Select-Object -First 1 | ForEach-Object { $_ -replace ' ', '' } -replace '\.$')
  $estim = [math]::Round($count / 140000, 3)
  $tabsize = (db2 connect to tsmdb1 2>&1>/dev/null && db2 "call sysproc.reorgchk_tb_stats('T','tsmdb1.$tab')" > $null && db2 "select tsize from session.tb_stats" | Select-Object -Last 4 | Select-Object -First 1 | ForEach-Object { $_ -replace ' ', '' } -replace '\.$')
  $tabspace = [math]::Round($tabsize / 1024 / 1024 / 1024, 3)
  $pages = (db2 connect to tsmdb1 2>&1>/dev/null && db2 "select t1.PAGESIZE from syscat.tablespaces t1 left join syscat.tables t2 on (t1.TBSPACEID=t2.TBSPACEID) where t2.tabname='$tab'" | Select-Object -Last 4 | Select-Object -First 1 | ForEach-Object { $_ -replace ' ', '' } -replace '\.$')
  $pagesize = [math]::Round($pages / 1024, 0)

  # write output line
  Write-Host ("{0,-25} ; {1,-15} ; {2,-15} ; {3,-15} ; {4,-25} ; {5,-10}" -f $tab, $count, $estim, $tabsize, "$tabspace GB", "${pagesize}K")
}
