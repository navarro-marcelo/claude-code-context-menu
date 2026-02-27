param(
    [Parameter(Mandatory=$true)]
    [string]$FolderPath
)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Claude Code Launcher"
        Width="420" Height="280"
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
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0" Text="Claude Code" FontSize="22" FontWeight="Bold"
                   Foreground="#c084fc" HorizontalAlignment="Center" Margin="0,0,0,5"/>

        <TextBlock Grid.Row="1" Text="{Binding FolderDisplay}" FontSize="11"
                   Foreground="#888" HorizontalAlignment="Center" Margin="0,0,0,18"
                   TextTrimming="CharacterEllipsis" MaxWidth="340"/>

        <CheckBox Grid.Row="2" x:Name="chkAdmin" Content="  Modo Administrador"/>
        <CheckBox Grid.Row="3" x:Name="chkDangerous" Content="  Dangerously Skip Permissions"/>

        <StackPanel Grid.Row="5" Orientation="Horizontal" HorizontalAlignment="Center" Margin="0,10,0,0">
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

$chkAdmin = $window.FindName("chkAdmin")
$chkDangerous = $window.FindName("chkDangerous")
$btnLaunch = $window.FindName("btnLaunch")
$btnCancel = $window.FindName("btnCancel")

# Show truncated folder path in the subtitle
$folderDisplay = $window.FindName("_")  # won't find, that's fine
$subtitleBlock = $window.Content.Children | Where-Object {
    $_ -is [System.Windows.Controls.TextBlock] -and $_.FontSize -eq 11
}
if ($subtitleBlock) {
    $subtitleBlock.Text = $FolderPath
}

$btnCancel.Add_Click({
    $window.Close()
})

$btnLaunch.Add_Click({
    $runAsAdmin = $chkAdmin.IsChecked
    $skipPerms  = $chkDangerous.IsChecked

    $cmdArgs = "claude"
    if ($skipPerms) {
        $cmdArgs = "claude --dangerously-skip-permissions"
    }

    # Build the command that will run inside the terminal
    $terminalCmd = "cd /d `"$FolderPath`" && $cmdArgs"

    if ($runAsAdmin) {
        $processArgs = @{
            FilePath     = "cmd.exe"
            ArgumentList = "/k", $terminalCmd
            Verb         = "RunAs"
        }
    } else {
        $processArgs = @{
            FilePath     = "cmd.exe"
            ArgumentList = "/k", $terminalCmd
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
