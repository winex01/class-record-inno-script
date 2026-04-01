Option Explicit

Dim WshShell, HerdPath
Dim StartTime, Timeout, RetryDelay

Set WshShell = CreateObject("WScript.Shell")

HerdPath = "C:\Program Files\Herd\Herd.exe"
Timeout = 60        ' seconds
RetryDelay = 2000   ' ms

' --- Start Herd if not running ---
If Not IsProcessRunning("Herd.exe") Then
    WshShell.Run """" & HerdPath & """", 0, False  ' 0 = hidden, False = don't wait
End If

' --- Poll until PHP is available ---
StartTime = Now()
Do While DateDiff("s", StartTime, Now()) < Timeout
    If IsHerdReady() Then
        WScript.Echo "Herd is ready."
        WScript.Quit 0
    End If
    WScript.Sleep RetryDelay
Loop

WScript.Echo "WARNING: Herd did not respond in time."
WScript.Quit 1

' =============================
Function IsProcessRunning(ProcessName)
    Dim objWMIService, colProcesses
    Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2")
    Set colProcesses = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE Name='" & ProcessName & "'")
    IsProcessRunning = (colProcesses.Count > 0)
End Function

Function IsHerdReady()
    Dim objHTTP
    On Error Resume Next
    Set objHTTP = CreateObject("MSXML2.XMLHTTP")
    objHTTP.Open "GET", "http://localhost", False
    objHTTP.Send
    If Err.Number = 0 And (objHTTP.Status = 200 Or objHTTP.Status = 404) Then
        IsHerdReady = True  ' Any HTTP response means the server is up
    Else
        IsHerdReady = False
    End If
    Set objHTTP = Nothing
    On Error GoTo 0
End Function