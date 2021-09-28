$param = $args[0]
$exePath = ""

if (Test-Path -Path ((Get-Location).toString() + "/SetUserFTA.exe") -PathType Leaf) {
    $exePath = ((Get-Location).toString() + "/SetUserFTA.exe")
} else {
    $exePath = (get-command SetUserFTA.exe).Path
}

function Enable-Dev {
    # (get-command edge_dev_switch).Path
    Invoke-Expression ("$exePath http MSEdgeDHTML")
    Invoke-Expression ("$exePath https MSEdgeDHTML")
    Invoke-Expression ("$exePath microsoft-edge-dev MSEdgeDHTML")
    Invoke-Expression ("$exePath .htm MSEdgeDHTML")
    Invoke-Expression ("$exePath .html MSEdgeDHTML")
    Invoke-Expression ("$exePath .svg MSEdgeDHTML")
    Invoke-Expression ("$exePath .html MSEdgeDHTML")
    Invoke-Expression ("$exePath read MSEdgeDHTML")
}

function Disable-Dev {
    Invoke-Expression ("$exePath http MSEdgeHTM")
    Invoke-Expression ("$exePath https MSEdgeHTM")
    Invoke-Expression ("$exePath microsoft-edge MSEdgeHTM")
    Invoke-Expression ("$exePath .htm MSEdgeHTM")
    Invoke-Expression ("$exePath .html MSEdgeHTM")
    Invoke-Expression ("$exePath .svg MSEdgeHTM")
    Invoke-Expression ("$exePath .html MSEdgeHTM")
    Invoke-Expression ("$exePath read MSEdgeHTM")
}

if($param.Equals("off")) {
    Disable-Dev
} elseif ($param.Equals("on")) {
    Enable-Dev    
} elseif ($param.Equals("switch")) {
    $currentBrowser = (Invoke-Expression "$exePath get" | Select-string https)
    $currentBrowser = "$currentBrowser".replace("https, ", "")
    
    if ($currentBrowser.Equals("MSEdgeHTM")) {
        Enable-Dev
    } else {
        Disable-Dev
    }
} elseif ($param.Equals("install")) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $currentDir = (Get-Location).toString()
        $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
        
        $currentDirIsInPath = 0
        
        $oldpath.Split(';').ForEach({
            if ("$_".Equals($currentDir)) {
                $currentDirIsInPath = 1
            }
        })
        
        if ($currentDirIsInPath.Equals(0)) {
            $newpath = "$oldpath;$currentDir"
            
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
        
            "Current directory added to path"
        } else {
            "Current directory has already been added to path"
        }
    } else {
        "Administrator level required to install"
    }
} elseif ($param.Equals("uninstall")) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    
    if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $currentDir = (Get-Location).toString()
        $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
        
        $currentDirIsInPath = 1
        
        $oldpath.Split(';').ForEach({
            if ("$_".Equals($currentDir)) {
                $currentDirIsInPath = 0
            }
        })
        
        if ($currentDirIsInPath.Equals(1)) {
            $newpath = $oldpath.replace(";$currentDir", "")
            
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
        
            "Current directory removed from path"
        } else {
            "Current directory has already been removed from path"
        }
    } else {
        "Administrator level required to uninstall"
    }
}