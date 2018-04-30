$manifest = @{
    Path              = '.\azure-tm-monitor.psd1'
    RootModule        = '.\azure-tm-momitor.psm1' 
    Author            = 'Luke Brady'
    Company           = "University of North Georgia"
}
New-ModuleManifest @manifest