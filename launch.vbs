' =============================
' Launch.vbs - Waits for Server, then Launches App
' =============================
Option Explicit

Dim WshShell, HerdPath, EdgePath, AppURL
Dim StartTime, Timeout, RetryDelay
Dim objHTTP, Status

Set WshShell = CreateObject("WScript.Shell")

HerdPath = "C:\Program Files\Herd\Herd.exe"
EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
AppURL = "http://class-record-client.test"

' --- Configuration ---
Timeout = 30          ' Maximum seconds to wait for the server
RetryDelay = 1000     ' Check every 1 second (in milliseconds)

' --- Start Herd if necessary ---
If Not IsProcessRunning("Herd.exe") Then
    ' Launch Herd (GUI)
    WshShell.Run """" & HerdPath & """", 0, False
End If

' --- Wait for the Web Server to be Ready ---
StartTime = Now()
Do While DateDiff("s", StartTime, Now()) < Timeout
    If IsServerReady(AppURL) Then
        Exit Do
    End If
    WScript.Sleep RetryDelay
Loop

' --- Launch the Application ---
WshShell.Run """" & EdgePath & """ --app=" & AppURL, 0, False

' =============================
' Function: Check if Process Exists
' =============================
Function IsProcessRunning(ProcessName)
    Dim objWMIService, colProcesses
    Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2")
    Set colProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name='" & ProcessName & "'")
    IsProcessRunning = (colProcesses.Count > 0)
End Function

' =============================
' Function: Check if Web Server Responds with HTTP 200
' =============================
Function IsServerReady(URL)
    On Error Resume Next
    Set objHTTP = CreateObject("MSXML2.XMLHTTP")
    objHTTP.Open "GET", URL, False
    objHTTP.Send
    
    ' Status 200 = OK (Page loaded successfully)
    If Err.Number = 0 And objHTTP.Status = 200 Then
        IsServerReady = True
    Else
        IsServerReady = False
    End If
    Set objHTTP = Nothing
    On Error GoTo 0
End Function