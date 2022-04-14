Sub DeleteAFolder(filespec)
   Dim fso
   Set fso = CreateObject("Scripting.FileSystemObject")
   fso.DeleteFolder(filespec)
End Sub