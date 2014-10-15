On Error Resume Next

' set the locale to US to prevent any unexpected locale changes to values (commas instead of periods, etc)
SetLocale(1033)

Class DirectoryFileInfo
    Public NewestFileName
    Public NewestFileDateModified
    Public NewestFileNameDir
    
    Public LargestFileName
    Public LargestFileSizeBytes
    Public LargestFileSizeKB
    Public LargestFileSizeMB
    Public LargestFileSizeGB
    Public LargestFileSizeTB
    Public LargestFileNameDir
    
    Public TotalFiles
End Class


Function NewestFileRecursive(dfi, directory, filetocheck, recursive)
    Dim oFilesys, oFolder, oFile, oDir, re
    
    ' get newest file in directory and compare with "newestfile"
    Set oFilesys = CreateObject("Scripting.FileSystemObject")
    If (directory <> "" And Not oFilesys.FolderExists(directory)) Then
        ' should never get to here (the original directory is checked before running this function)
        wscript.echo("CRIT - Directory does not exist: '" & directory & "'")
    Else
On Error Resume Next
        Set oFolder = oFileSys.getFolder(directory)
        For Each ofilename in oFolder.Files
            ' open file for info
            Set oFile = oFilesys.GetFile(ofilename)
            ' check if the file name is acceptable; or skip if no file to check
            Set re = new regexp
            re.Pattern = filetocheck
            re.IgnoreCase = true
            If ( (filetocheck = "") Or (re.Test(oFile.Name)) ) Then
                ' check if the current file is newer
                If (DateDiff("N", dfi.NewestFileDateModified, oFile.DateLastModified) <= 0) Then
                    dfi.NewestFileName = oFile.Name
                    dfi.NewestFileDateModified = oFile.DateLastModified
                    dfi.NewestFileNameDir = directory
                End If
                ' check if the current file is bigger
                If (dfi.LargestFileSizeBytes < oFile.Size) Then
                    dfi.LargestFileName = oFile.Name
                    dfi.LargestFileSizeBytes = oFile.Size
                    dfi.LargestFileNameDir = directory
                End If
                dfi.TotalFiles = dfi.TotalFiles + 1
            End If
        Next
    End If

    ' if recursive = true
    If (recursive) Then
        ' first confirm that the current directory was opened properly; oFolder should be the directory name, if not (due to permission denied error) it will be blank
        If (oFolder <> "") Then
            '  go through each sub directory and run the same check
            For Each oDir in oFolder.SubFolders
                Set dfi = NewestFileRecursive(dfi, oDir, filetocheck, recursive)
            Next
        End If
    End If
    ' return the value
    Set NewestFileRecursive = dfi
End Function : Private Sub CatchErr : If Err.Number = 0 Then Exit Sub
    Select Case Err.Number
        Case 6
            wscript.echo("Overflow handled!")
        Case Else
            wscript.echo("CRIT - Unhandled error (" & Err.Number & ") '" & Err.description & "' occurred.")
    End Select
    Err.Clear : End Sub : Private Sub Class_Terminate : CatchErr
    wscript.echo("Exiting")
End Sub


'Function DoDirectoryCheck(directory, filetocheck, recursive)
Class FuncDoDirectoryCheck
Private Sub Class_Initialize
End Sub
    
Function DoDirectoryCheck(directory, filetocheck, recursive)
    Set oFilesys = CreateObject("Scripting.FileSystemObject")
    if (directory <> "" And Not oFilesys.FolderExists(directory)) then
        wscript.echo("CRIT - Directory does not exist: '" & directory & "'")
    else
        '----------------------------------------------------
        ' Create new object that will hold all the necessary variables we need
        '----------------------------------------------------
        currentDateTime = Now()
        Set dfi = New DirectoryFileInfo
        dfi.NewestFileName = ""
        ' set the date modified to 30 years in the past (file should be newer)
        'dfi.NewestFileDateModified = FormatDateTime(DateAdd("yyyy", -30, currentDateTime), 0)
        dfi.NewestFileDateModified = currentDateTime
        dfi.NewestFileNameDir = directory
        dfi.LargestFileName = ""
        dfi.LargestFileSizeBytes = 0
        dfi.LargestFileNameDir = directory
        dfi.TotalFiles = 0

        Set dfi = NewestFileRecursive(dfi, directory, filetocheck, recursive)
        
        if (dfi.TotalFiles = 0) then
            if (filetocheck <> "") then
                wscript.echo("Message No files were matched with " & filetocheck)
            else
                wscript.echo("Message No files were found in " & directory)
            End If
        else
        
            wscript.echo("Total Files: " & dfi.TotalFiles)
            
            '----------------------------------------------------
            ' Do Conversions
            '----------------------------------------------------
            ' Bytes to other units
            dfi.LargestFileSizeKB = Round(dfi.LargestFileSizeBytes / 1024, 3)
            dfi.LargestFileSizeMB = Round(dfi.LargestFileSizeBytes / 1024 / 1024, 3)
            dfi.LargestFileSizeGB = Round(dfi.LargestFileSizeBytes / 1024 / 1024 / 1024, 3)
            dfi.LargestFileSizeTB = Round(dfi.LargestFileSizeBytes / 1024 / 1024 / 1024 / 1024, 3)
            ' Date to number of minutes ago
            minutesOld = DateDiff("N", dfi.NewestFileDateModified, currentDateTime)
            hoursOld = DateDiff("H", dfi.NewestFileDateModified, currentDateTime)
            daysOld = DateDiff("D", dfi.NewestFileDateModified, currentDateTime)
            
            '----------------------------------------------------
            ' Output Format:
            '----------------------------------------------------
            ' <message> (should say the largest file and the most recent file)(CRIT or WARN)
            ' TotalSize ##
            ' TotalFiles ##
            ' MinutesOld ##
            ' HoursOld ##
            ' DaysOld ##
            if dfi.LargestFileSizeTB > 1.0 then
                wscript.echo("Message Oldest file: " & dfi.NewestFileNameDir  & "\" & dfi.NewestFileName & " (" & minutesOld & " minutes old) -- Largest File: " & dfi.LargestFileNameDir  & "\" & dfi.LargestFileName & " (" & dfi.LargestFileSizeMB & "MB)")
            elseif dfi.LargestFileSizeGB > 1.0 then
                wscript.echo("Message Oldest file: " & dfi.NewestFileNameDir  & "\" & dfi.NewestFileName & " (" & minutesOld & " minutes old) -- Largest File: " & dfi.LargestFileNameDir  & "\" & dfi.LargestFileName & " (" & dfi.LargestFileSizeGB & "GB)")
            elseif dfi.LargestFileSizeMB > 1.0 then
                wscript.echo("Message Oldest file: " & dfi.NewestFileNameDir  & "\" & dfi.NewestFileName & " (" & minutesOld & " minutes old) -- Largest File: " & dfi.LargestFileNameDir  & "\" & dfi.LargestFileName & " (" & dfi.LargestFileSizeMB & "MB)")
            elseif dfi.LargestFileSizeKB > 1.0 then
                wscript.echo("Message Oldest file: " & dfi.NewestFileNameDir  & "\" & dfi.NewestFileName & " (" & minutesOld & " minutes old) -- Largest File: " & dfi.LargestFileNameDir  & "\" & dfi.LargestFileName & " (" & dfi.LargestFileSizeKB & "KB)")
            else
                wscript.echo("Message Oldest file: " & dfi.NewestFileNameDir  & "\" & dfi.NewestFileName & " (" & minutesOld & " minutes old) -- Largest File: " & dfi.LargestFileNameDir  & "\" & dfi.LargestFileName & " (" & dfi.LargestFileSizeBytes & "Bytes)")
            End if
            wscript.echo("TotalSizeB "  & dfi.LargestFileSizeBytes)
            wscript.echo("TotalSizeKB "  & dfi.LargestFileSizeKB)
            wscript.echo("TotalSizeMB "  & dfi.LargestFileSizeMB)
            wscript.echo("TotalSizeGB "  & dfi.LargestFileSizeGB)
            wscript.echo("TotalSizeTB "  & dfi.LargestFileSizeTB)
            wscript.echo("MinutesOld " & minutesOld)
            wscript.echo("HoursOld "   & hoursOld)
            wscript.echo("DaysOld "    & daysOld)
            wscript.echo("TotalFiles " & dfi.TotalFiles)
        End If
    End If
End Function : Private Sub CatchErr : If Err.Number = 0 Then Exit Sub
    Select Case Err.Number
        Case 6
            wscript.echo("CRIT - Overflow handled!")
        Case 70
            'wscript.echo("CRIT - Permission denied handled!")
            ' just ignore a permission denied
        Case 5018
            wscript.echo("CRIT - Invalid Regular Expression '" & filetocheck & "' (VBS Error: Unexpected quantifier)")
        Case Else
            wscript.echo("CRIT - Unhandled error (" & Err.Number & ") '" & Err.description & "' occurred.")
    End Select
    Err.Clear : End Sub : Private Sub Class_Terminate : CatchErr
End Sub

End Class




Dim check, directory, param 

if ( wscript.arguments.item(0) = null) Then
    wscript.echo ("CRIT - invalid parameters")
else
    args = Split(wscript.arguments.item(0), "#", 3, 1)
    ' Search Sub Directories (recursively)?
    If (args(0) = "true") Then
        recursive = true
    Else
        recursive = false
    End If
    directory = Replace(args(1), "@", " ")
    filetocheck = args(2)
    ' create and load a class which can handle error checking (like try/catch) in VBS
    Dim dircheck
    Set dircheck = New FuncDoDirectoryCheck
    Call dircheck.DoDirectoryCheck(directory, filetocheck, recursive)
    Set dircheck = Nothing
End If
