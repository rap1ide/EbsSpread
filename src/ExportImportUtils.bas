Attribute VB_Name = "ExportImportUtils"
'  This macro collection lets you organize your tasks and schedules
'  for you with the evidence based schedule (EBS) approach by Joel Spolsky.
'
'  Copyright (C) 2020  Christian Weihsbach
'  This program is free software; you can redistribute it and/or modify
'  it under the terms of the GNU General Public License as published by
'  the Free Software Foundation; either version 3 of the License, or
'  (at your option) any later version.
'  This program is distributed in the hope that it will be useful,
'  but WITHOUT ANY WARRANTY; without even the implied warranty of
'  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'  GNU General Public License for more details.
'  You should have received a copy of the GNU General Public License
'  along with this program; if not, write to the Free Software Foundation,
'  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
'
'  Christian Weihsbach, weihsbach.c@gmail.com

Option Explicit

Function ExportVisibleTasks()
    'This function exports all sheets of tasks that are visible in the planning sheet list.
    'Tasks are exported to a separate workbook only contaning the sheets of tasks

    Dim visibleTasks As Range
    Set visibleTasks = PlanningUtils.GetVisibleTasks
    
    'Debug info
    'Debug.Print "Visible Tasks: " & visibleTasks.Count & " out of " & hashRange.Count
    
    If Not visibleTasks Is Nothing Then
        'In case there are visible hashes store them to a special virtual storage sheet.
        
        Dim sheet As Worksheet
        Dim cll As Range
        
        For Each cll In visibleTasks
            Set sheet = TaskUtils.GetTaskSheet(cll.Value)
            'Store the sheet in a special virtual sheet with EXIMPORT_SHEET_PREFIX. Do not delete the original sheet as it still has to
            'be available inside this script
            Call VirtualSheetUtils.StoreAsVirtualSheet(sheet, EXIMPORT_SHEET_PREFIX, False)
        Next cll
    End If
End Function



Function ImportTasks()
    'This function imports all tasks of a special export worksheet
     
    ExportImportUtils.RewriteImportSheetHashes
        
    Dim vSheets As Scripting.Dictionary
    Set vSheets = VirtualSheetUtils.GetAllVirtualSheets(Constants.EXIMPORT_SHEET_PREFIX)
    Dim key As Variant
    
    For Each key In vSheets.Keys
        Dim cpHash As String: cpHash = key
        If SanityChecks.CheckHash(cpHash) Then
            Dim loadedSheet As Worksheet
            Set loadedSheet = VirtualSheetUtils.LoadVirtualSheet(cpHash, Constants.EXIMPORT_SHEET_PREFIX, ThisWorkbook.Worksheets(Constants.TASK_SHEET_TEMPLATE_NAME))
            If Not loadedSheet Is Nothing Then
                Call TaskUtils.SetHash(loadedSheet, cpHash)
                Call PlanningUtils.BacksyncTask(syncedHash:=cpHash, _
                    taskNamePostfix:=SettingUtils.GetImportedTaskPostfixSetting)
            End If
        End If
    Next key
End Function



Function RewriteImportSheetHashes()
    Dim nameCell As Range
    Dim item As Variant
    
    For Each item In VirtualSheetUtils.GetAllVirtualSheets(Constants.EXIMPORT_SHEET_PREFIX).Items
        Set nameCell = item
        nameCell.Value = Utils.CreateHashString("t")
    Next item
End Function
