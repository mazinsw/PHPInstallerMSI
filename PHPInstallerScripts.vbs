Const ForReading = 1
Const ForWriting = 2

Sub configApache

    Dim objFSO
    Dim objFile

    Args = Split( Session.Property("CustomActionData"), "," )
    strApacheDir = Args(0)
    strInstallDir = Args(1)
    strWebServerType = Args(2)
    
    If ( right(strApacheDir,1) <> "\" ) then 
        strApacheDir = strApacheDir & "\"
    End If
    
    ' Bug 55778 - Use forward slashes in Windows 7
    If ( FormatNumber(GetWindowsVersion) >= FormatNumber("7.0") ) Then
        strPHPPath = Replace(strInstallDir,"\","/")
    Else    
        strPHPPath = strInstallDir
    End If
    
    strDirective = vbCrLf & "#BEGIN PHP INSTALLER EDITS - REMOVE ONLY ON UNINSTALL" & vbCrLf
    If ( strWebServerType = "apacheCGI" ) Then
        strDirective = strDirective & "ScriptAlias /php/ """ & strPHPPath & """" & vbCrLf
        strDirective = strDirective & "Action application/x-httpd-php """ & strPHPPath & "php-cgi.exe""" & vbCrLf
    End If
    
    If ( strWebServerType = "apache22" ) Then
        strDirective = strDirective & "PHPIniDir """ & strPHPPath & """" & vbCrLf
        strDirective = strDirective & "LoadModule php5_module """ & strPHPPath & "php5apache2_2.dll""" & vbCrLf
    End If
    
    If ( strWebServerType = "apache24" ) Then
        strDirective = strDirective & "PHPIniDir """ & strPHPPath & """" & vbCrLf
        strDirective = strDirective & "LoadModule php5_module """ & strPHPPath & "php5apache2_4.dll""" & vbCrLf
    End If
    
    strDirective = strDirective &  "#END PHP INSTALLER EDITS - REMOVE ONLY ON UNINSTALL"
    
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFileName = strApacheDir & "httpd.conf"
    If objFSO.FileExists(strFileName) Then
        Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
    Else
        strFileName = strApacheDir & "conf\httpd.conf"
        If objFSO.FileExists(strFileName) Then
            Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
        Else
            FatalError ("Error trying access httpd.conf file.")
            Exit Sub
        End If    
    End If        
    strText = objFile.ReadAll
    objFile.Close
    
    ' try and comment out old directives if they exist
    strText = Replace(strText,"ScriptAlias /php/","#ScriptAlias /php/")
    strText = Replace(strText,"Action application/x-httpd-php","#Action application/x-httpd-php")
    strText = Replace(strText,"PHPIniDir","#PHPIniDir")
    strText = Replace(strText,"LoadModule _module","#LoadModule _module")
    strText = Replace(strText,"LoadModule php5_module","#LoadModule php5_module")
    strText = Replace(strText,"DirectoryIndex index.html","DirectoryIndex index.php index.html")
    strText  = strText & strDirective
    
    ' backup old file
    strBackupFileName = strFileName & ".bak"
    objFSO.CopyFile strFileName, strBackupFileName 
    
    Set objFile = objFSO.OpenTextFile( strFileName, ForWriting)
    objFile.Write strText
    objFile.Close
    
    strFileName = strApacheDir & "mime.types"
    If objFSO.FileExists(strFileName) Then
        Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
    Else
        strFileName = strApacheDir & "conf\mime.types"
        If objFSO.FileExists(strFileName) Then
            Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
        Else
            FatalError ("Error trying access mime.types file.")
            Exit Sub
        End If    
    End If
    
    strText = objFile.ReadAll
    objFile.Close
    
    If ( InStr(strText,"application/x-httpd-php") = 0 ) Then
        strText = strText & vbCrLf & "application/x-httpd-php" & vbTab & "php"
    End If
    
    If ( InStr(strText,"application/x-httpd-php-source") = 0 ) Then
        strText = strText & vbCrLf & "application/x-httpd-php-source" & vbTab & "phps"
    End If
    
    ' backup old file
    strBackupFileName = strFileName & ".bak"
    objFSO.CopyFile strFileName, strBackupFileName
    
    Set objFile = objFSO.OpenTextFile( strFileName, ForWriting)
    objFile.Write strText
    objFile.Close
    
End Sub

Sub unconfigApache

    Dim objFSO
    Dim objFile

    strApacheDir = GetRegistryValue("Software\PHP","ApacheDir")
    If ( right(strApacheDir,1) <> "\" ) then 
        strApacheDir = strApacheDir & "\"
    End If

    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFileName = strApacheDir & "httpd.conf"
    If objFSO.FileExists(strFileName) Then
        Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
    Else
        strFileName = strApacheDir & "conf\httpd.conf"
        If objFSO.FileExists(strFileName) Then
            Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
        Else
            FatalError ("Error trying access httpd.conf file.")
            Exit Sub
        End If    
    End If
    vbLine = ""
    do while objFile.AtEndOfStream = false
        strText = objFile.ReadLine
        strText = Replace(strText,"DirectoryIndex index.php index.html","DirectoryIndex index.html")
        
        If ( strText = "#BEGIN PHP INSTALLER EDITS - REMOVE ONLY ON UNINSTALL" ) Then
            strEndText = objFile.ReadLine
            do while strEndText <> "#END PHP INSTALLER EDITS - REMOVE ONLY ON UNINSTALL"
                strEndText = objFile.ReadLine
            loop    
        Else
            strNewText = strNewText & vbLine & strText
            vbLine = vbCrLf
        End If
    loop
    
    objFile.Close
    
    Set objFile = objFSO.OpenTextFile(strFileName, ForWriting)
    objFile.Write strNewText
    objFile.Close


    strFileName = strApacheDir & "mime.types"
    If objFSO.FileExists(strFileName) Then
        Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
    Else
        strFileName = strApacheDir & "conf\mime.types"
        If objFSO.FileExists(strFileName) Then
            Set objFile = objFSO.OpenTextFile( strFileName, ForReading)
        Else
            FatalError ("Error trying access mime.types file.")
            Exit Sub
        End If    
    End If
    vbLine = ""
    do while objFile.AtEndOfStream = false
        strText = objFile.ReadLine
        
        If ( InStr(strText,"application/x-httpd-php") = 0 ) And ( InStr(strText,"application/x-httpd-php-source") = 0 ) Then
            strNewMimeText = strNewMimeText & vbLine & strText
            vbLine = vbCrLf
        End If
    loop
    
    objFile.Close
    
    Set objFile = objFSO.OpenTextFile(strFileName, ForWriting)
    objFile.Write strNewMimeText
    objFile.Close

End Sub

Sub configIIS4

    Dim WebService
    Dim WebService1
    Dim Paths
    Dim Nodes()
    Dim NumExtensions
    Dim PHPExecutable
    Dim NodeCount
    Dim FullPath
    Dim Args, Arg, ArgCount
    Dim I
    Dim J
    Dim K
    Dim MapNode, ScriptMaps, OutMaps(), Map, MapBits
    Dim fAddScriptMap
    Dim DefaultDocuments

    fAddScriptMap = TRUE
    Args = Split( Session.Property("CustomActionData"), "," )
    strPHPPath = Args(0)
    strWebServerType = Args(1)
    If ( right(strPHPPath,1) <> "\" ) then 
        strPHPPath = strPHPPath & "\"
    End If
    If ( strWebServerType = "iis4CGI" ) Then
        PHPExecutable = strPHPPath & "php-cgi.exe"
    End If
    If ( strWebServerType = "iis4ISAPI" ) Then
        PHPExecutable = strPHPPath & "php5isapi.dll"
    End If
    If ( strWebServerType = "iis4FastCGI" ) Then
        fAddScriptMap = FALSE
    End If
    
    'it could all go dreadfully wrong - so set error handler for graceful exits
    On Error Resume Next
 
    Set WebService = GetObject("IIS://LocalHost/W3SVC")
    If (Err.Number <> 0) Then
        FatalError ("Error trying access the local web service: GetObject Failed.")
        Exit Sub
    End If

    ' Add index.php to default documents list at server level
    DefaultDocuments = WebService.DefaultDoc
    If ( InStr(DefaultDocuments,"index.php") = 0 ) Then
        DefaultDocuments = DefaultDocuments & ",index.php"
        WebService.DefaultDoc = DefaultDocuments
        WebService.SetInfo
    End If

    ' Add index.php to default documents list of SiteId 1
    Set WebService1 = GetObject("IIS://LocalHost/W3SVC/1")
    If (Err.Number = 0) Then
        DefaultDocuments = WebService1.DefaultDoc
        If ( InStr(DefaultDocuments,"index.php") = 0 ) Then
            DefaultDocuments = DefaultDocuments & ",index.php"
            WebService1.DefaultDoc = DefaultDocuments
            WebService1.SetInfo
        End If
    End If

    If ( fAddScriptMap = TRUE ) Then
        If ( FormatNumber(GetWindowsVersion) < FormatNumber("5.2") ) Then
            'use short path syntax here
            Set objFSO = CreateObject("Scripting.FileSystemObject")
            Set objFile = objFSO.GetFile(PHPExecutable)
            PHPExecutable = objFile.ShortPath
        Else
            'use quotes and long name syntax
            PHPExecutable = """" & PHPExecutable & """"
        End If
    
        'I may be doing the wrong thing with inheritance here - it seems to work, however!
        Paths = WebService.GetDataPaths("scriptmaps", IIS_DATA_INHERIT)
        If Err.Number <> 0 Then Paths = WebService.GetDataPaths("scriptmaps", IIS_DATA_NO_INHERIT)
        If (Err.Number <> 0) Then
            FatalError ("Error trying to find the nodes containing scriptmaps :GetDataPaths Failed.")
            Exit Sub
        End If
        For Each FullPath In Paths
            Set MapNode = GetObject(FullPath)
            ReDim OutMaps(0)
            J = 0
            For Each Map In MapNode.ScriptMaps
                'split the extension from the scriptmap entry
                MapBits = Split(Map, ",")
                If MapBits(0) <> ".php" Then
                    'if the extension doesn't match any of our php ones, preserve it
                    ReDim Preserve OutMaps(J)
                    OutMaps(J) = Map
                    J = J + 1
                End If
            Next

            ReDim Preserve OutMaps(J + 1 - 1)

            'add our php extensions to OutMaps
            OutMaps(J) = ".php" & "," & PHPExecutable & ",1"
   
            'write the Outmap to the current node
            MapNode.Put "ScriptMaps", (OutMaps)
            'setinfo to make it so
            MapNode.SetInfo
        Next
    End If
    
End Sub

Sub unconfigIIS4

    Dim WebService
    Dim Paths
    Dim Nodes()
    Dim NumExtensions
    Dim PHPExecutable
    Dim NodeCount
    Dim FullPath
    Dim Args, Arg, ArgCount
    Dim I
    Dim J
    Dim K
    Dim MapNode, ScriptMaps, OutMaps(), Map, MapBits
    Dim fRemoveScriptMap
 
    fRemoveScriptMap = TRUE

    'it could all go dreadfully wrong - so set error handler for graceful exits
    On Error Resume Next

    strWebServerType = GetRegistryValue("Software\PHP","WebServerType")
    If ( strWebServerType = "iis4FastCGI" ) Then
        fRemoveScriptMap = FALSE
    End If
 
    Set WebService = GetObject("IIS://LocalHost/W3SVC")
    If (Err.Number <> 0) Then
        FatalError ("Error trying access the local web service: GetObject Failed.")
        Exit Sub
    End If

    If ( fRemoveScriptMap = TRUE ) Then
        'I may be doing the wrong thing with inheritance here - it seems to work, however!
        Paths = WebService.GetDataPaths("scriptmaps", IIS_DATA_INHERIT)
        If Err.Number <> 0 Then Paths = WebService.GetDataPaths("scriptmaps", IIS_DATA_NO_INHERIT)
        If (Err.Number <> 0) Then
            FatalError ("Error trying to find the nodes containing scriptmaps :GetDataPaths Failed.")
            Exit Sub
        End If
        For Each FullPath In Paths
            Set MapNode = GetObject(FullPath)
            ReDim OutMaps(0)
            J = 0
            For Each Map In MapNode.ScriptMaps
                'split the extension from the scriptmap entry
                MapBits = Split(Map, ",")
                If MapBits(0) <> ".php" Then
                    'if the extension doesn't match any of our php ones, preserve it
                    ReDim Preserve OutMaps(J)
                    OutMaps(J) = Map
                    J = J + 1
                End If
            Next

            'write the Outmap to the current node
            MapNode.Put "ScriptMaps", (OutMaps)
            'setinfo to make it so
            MapNode.SetInfo
        Next
    End If

End Sub

Sub FatalError(Message)
    MsgBox Message & " You will need to manually configure the web server.", vbExclamation, "Error"
End Sub

Function GetWindowsVersion
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colItems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem",,48)
    For Each objItem in colItems
        ver=objItem.Version
    Next
    GetWindowsVersion = Left(ver,3)
End Function

Function GetRegistryValue(strKeyPath,strValueName)
    const HKEY_LOCAL_MACHINE = &H80000002
    strComputer = "."
    
    Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
        strComputer & "\root\default:StdRegProv")

    oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
    
    GetRegistryValue = strValue
End Function
