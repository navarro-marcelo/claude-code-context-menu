param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# --- Detect available terminals ---
$terminals = [System.Collections.ArrayList]::new()

# CMD (always available)
[void]$terminals.Add(@{ Name = "CMD"; Exe = "cmd.exe"; Args = { param($cmd) @("/k", $cmd) } })

# Windows PowerShell 5.1
$winPs = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
if (Test-Path $winPs) {
    [void]$terminals.Add(@{ Name = "Windows PowerShell"; Exe = $winPs; Args = { param($cmd) @("-NoExit", "-Command", $cmd) } })
}

# PowerShell 7+ (pwsh)
$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
if ($pwsh) {
    [void]$terminals.Add(@{ Name = "PowerShell 7"; Exe = $pwsh.Source; Args = { param($cmd) @("-NoExit", "-Command", $cmd) } })
}

# Windows Terminal (wt)
$wt = Get-Command wt.exe -ErrorAction SilentlyContinue
if ($wt) {
    [void]$terminals.Add(@{ Name = "Windows Terminal"; Exe = $wt.Source; Args = { param($cmd) @("-d", $FolderPath, "cmd.exe", "/k", $cmd) } })
}

# Git Bash
$gitBashPaths = @(
    "$env:ProgramFiles\Git\bin\bash.exe",
    "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
)
foreach ($gp in $gitBashPaths) {
    if (Test-Path $gp) {
        [void]$terminals.Add(@{ Name = "Git Bash"; Exe = $gp; Args = { param($cmd) @("-c", "cd '$($FolderPath -replace '\\','/')' && $cmd; exec bash") } })
        break
    }
}

# Build ComboBox items XAML
$comboItemsXaml = ""
for ($i = 0; $i -lt $terminals.Count; $i++) {
    $tName = $terminals[$i].Name
    $comboItemsXaml += "                    <ComboBoxItem Content=`"$tName`" Foreground=`"#e0e0e0`"/>`n"
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Claude Code Launcher"
        Width="420" Height="340"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        Background="#1a1a2e">
    <Window.Resources>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#e0e0e0"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="Margin" Value="0,8,0,8"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
    </Window.Resources>
    <Grid Margin="30,20,30,20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="Claude Code" FontSize="22" FontWeight="Bold"
                   Foreground="#c084fc" HorizontalAlignment="Center" Margin="0,0,0,5"/>

        <TextBlock Grid.Row="1" x:Name="txtFolder" FontSize="11"
                   Foreground="#888" HorizontalAlignment="Center" Margin="0,0,0,14"
                   TextTrimming="CharacterEllipsis" MaxWidth="340"/>

        <CheckBox Grid.Row="2" x:Name="chkAdmin" Content="  Modo Administrador"/>
        <CheckBox Grid.Row="3" x:Name="chkDangerous" Content="  Dangerously Skip Permissions"/>

        <StackPanel Grid.Row="4" Orientation="Horizontal" Margin="0,10,0,0" VerticalAlignment="Center">
            <TextBlock Text="Terminal:" Foreground="#e0e0e0" FontSize="14" VerticalAlignment="Center" Margin="0,0,12,0"/>
            <ComboBox x:Name="cmbTerminal" Width="230" Height="30" FontSize="13"
                      SelectedIndex="0" Cursor="Hand"
                      Background="#2a2a4a" Foreground="#e0e0e0" BorderBrush="#444">
$comboItemsXaml
            </ComboBox>
        </StackPanel>

        <StackPanel Grid.Row="6" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,10,0,0">
            <Button x:Name="btnLaunch" Content="Iniciar" Width="120" Height="36" FontSize="14"
                    FontWeight="SemiBold" Cursor="Hand" Margin="0,0,10,0">
                <Button.Style>
                    <Style TargetType="Button">
                        <Setter Property="Background" Value="#7c3aed"/>
                        <Setter Property="Foreground" Value="White"/>
                        <Setter Property="BorderThickness" Value="0"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="Button">
                                    <Border Background="{TemplateBinding Background}"
                                            CornerRadius="6" Padding="10,5">
                                        <ContentPresenter HorizontalAlignment="Center"
                                                          VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#6d28d9"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Button.Style>
            </Button>
            <Button x:Name="btnCancel" Content="Cancelar" Width="120" Height="36" FontSize="14"
                    Cursor="Hand">
                <Button.Style>
                    <Style TargetType="Button">
                        <Setter Property="Background" Value="#333"/>
                        <Setter Property="Foreground" Value="#ccc"/>
                        <Setter Property="BorderThickness" Value="0"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="Button">
                                    <Border Background="{TemplateBinding Background}"
                                            CornerRadius="6" Padding="10,5">
                                        <ContentPresenter HorizontalAlignment="Center"
                                                          VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#444"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Button.Style>
            </Button>
        </StackPanel>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$chkAdmin    = $window.FindName("chkAdmin")
$chkDangerous = $window.FindName("chkDangerous")
$cmbTerminal = $window.FindName("cmbTerminal")
$btnLaunch   = $window.FindName("btnLaunch")
$btnCancel   = $window.FindName("btnCancel")
$txtFolder   = $window.FindName("txtFolder")

$txtFolder.Text = $FolderPath

$btnCancel.Add_Click({
    $window.Close()
})

$btnLaunch.Add_Click({
    $runAsAdmin = $chkAdmin.IsChecked
    $skipPerms  = $chkDangerous.IsChecked
    $selectedIdx = $cmbTerminal.SelectedIndex

    $terminal = $terminals[$selectedIdx]

    $claudeCmd = "claude"
    if ($skipPerms) {
        $claudeCmd = "claude --dangerously-skip-permissions"
    }

    # Build the shell command depending on terminal type
    $terminalName = $terminal.Name

    if ($terminalName -eq "CMD") {
        $shellCmd = "cd /d `"$FolderPath`" && $claudeCmd"
    }
    elseif ($terminalName -eq "Git Bash") {
        $folderUnix = $FolderPath -replace '\\','/'
        $shellCmd = "cd '$folderUnix' && $claudeCmd; exec bash"
    }
    elseif ($terminalName -eq "Windows Terminal") {
        # Windows Terminal handles -d for directory; inner command is cmd
        $shellCmd = "cd /d `"$FolderPath`" && $claudeCmd"
    }
    else {
        # PowerShell variants
        $shellCmd = "Set-Location -LiteralPath '$FolderPath'; $claudeCmd"
    }

    # Build argument list via the terminal's Args scriptblock
    $argList = & $terminal.Args $shellCmd

    $processArgs = @{
        FilePath     = $terminal.Exe
        ArgumentList = $argList
    }

    if ($runAsAdmin) {
        $processArgs["Verb"] = "RunAs"
    }

    # Windows Terminal with admin needs special handling
    if ($terminalName -eq "Windows Terminal" -and $runAsAdmin) {
        $processArgs = @{
            FilePath     = $terminal.Exe
            ArgumentList = @("-d", $FolderPath, "cmd.exe", "/k", $shellCmd)
            Verb         = "RunAs"
        }
    }

    try {
        Start-Process @processArgs
    } catch {
        [System.Windows.MessageBox]::Show(
            "Erro ao iniciar o Claude Code: $_",
            "Erro",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        )
    }

    $window.Close()
})

$window.ShowDialog() | Out-Null
