$str = $args[0]

$UserDir = Get-ChildItem -Directory \\swbc.local\profile\CL03\Containers -Filter "*$str*"
#UserDir2 = Get-ChildItem -Directory \\swbc.local\profile\CL06\Containers -Filter "$str"
$ContainerPath = $UserDir | select -ExpandProperty Name
$VHD = Get-ChildItem "\\swbc.local\profile\CL03\Containers\$UserDir\*.VHDX" | select -ExpandProperty Name
$VHDPath = "\\swbc.local\profile\CL06\Containers\$ContainerPath\$VHD"
Mount-VHD -Path $VHDPath