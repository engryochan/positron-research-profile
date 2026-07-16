$keywords=@(
"cache",
"Cache",
"CachedData",
"Code Cache",
"GPUCache",
"Crashpad",
"Temp",
"tmp",
"logs",
"log",
"Service Worker"
)

$result=@()

Write-Host "Scanning caches..." -ForegroundColor Cyan

Get-ChildItem C:\Users -Directory | ForEach-Object{

    Get-ChildItem $_.FullName -Recurse -Directory -Force -ErrorAction SilentlyContinue |

    Where-Object{

        $n=$_.Name

        $keywords | Where-Object{$n -like "*$_*"}

    } |

    ForEach-Object{

        $size=(

            Get-ChildItem $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |

            Measure-Object Length -Sum

        ).Sum

        $result+=[PSCustomObject]@{

            Folder=$_.FullName

            SizeGB=[math]::Round($size/1GB,2)

        }

    }

}

$result |

Sort-Object SizeGB -Descending |

Export-Csv "$HOME\Desktop\Caches.csv" -Encoding UTF8 -NoTypeInformation

$result |

Sort-Object SizeGB -Descending |

Format-Table -AutoSize
