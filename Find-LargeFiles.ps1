Get-ChildItem C:\ -Recurse -File -Force -ErrorAction SilentlyContinue |

Where-Object{

    $_.Length -gt 500MB

} |

Select-Object FullName,

@{N="SizeGB";E={[math]::Round($_.Length/1GB,2)}} |

Sort-Object SizeGB -Descending |

Export-Csv "$HOME\Desktop\LargeFiles.csv" -NoTypeInformation -Encoding UTF8

Import-Csv "$HOME\Desktop\LargeFiles.csv" |

Format-Table -AutoSize
