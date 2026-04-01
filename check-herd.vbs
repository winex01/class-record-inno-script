Dim objHTTP
On Error Resume Next
Set objHTTP = CreateObject("MSXML2.XMLHTTP")
objHTTP.Open "GET", "http://localhost", False
objHTTP.Send
If Err.Number = 0 And (objHTTP.Status = 200 Or objHTTP.Status = 404) Then
    WScript.Echo "1"
Else
    WScript.Echo "0"
End If
Set objHTTP = Nothing