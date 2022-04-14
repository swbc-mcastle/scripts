Function Get-DU
  {   Param (
    $Path = "."
  )
  $AllFileInfo = @()
  ForEach ($File in (Get-ChildItem $Path))
    {   If ($File.PSisContainer)
      {   $Size = [Math]::Round((Get-ChildItem $File.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1KB,2)
        $Folder = "True"
      }
    Else
      {   $Size = $File.Length
        $Folder = ""
      }
      $FileInfo = New-Object System.Object
      $FileInfo | Add-Member -type NoteProperty -name Name -value $File.name
      $FileInfo | Add-Member -type NoteProperty -name Folder -value $Folder
      $FileInfo | Add-Member -type NoteProperty -name Size -value $Size
      $AllFileInfo += $FileInfo
  }
  $AllFileInfo
}