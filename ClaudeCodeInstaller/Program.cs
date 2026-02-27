using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Windows.Forms;
using Microsoft.Win32;

namespace ClaudeCodeInstaller;

static class Program
{
    const string InstallDir = @"C:\Program Files\ClaudeCodeLauncher";
    const string LauncherFileName = "claude-code-launcher.ps1";
    const string RegPathFolder = @"SOFTWARE\Classes\Directory\shell\ClaudeCode";
    const string RegPathBackground = @"SOFTWARE\Classes\Directory\Background\shell\ClaudeCode";

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new InstallerForm());
    }

    class InstallerForm : Form
    {
        private Label titleLabel = null!;
        private Label subtitleLabel = null!;
        private Label statusLabel = null!;
        private Button installButton = null!;
        private Button uninstallButton = null!;
        private ProgressBar progressBar = null!;
        private Panel headerPanel = null!;

        public InstallerForm()
        {
            InitializeComponent();
            CheckInstalledState();
        }

        void InitializeComponent()
        {
            Text = "Claude Code - Context Menu Installer";
            Size = new Size(520, 380);
            StartPosition = FormStartPosition.CenterScreen;
            FormBorderStyle = FormBorderStyle.FixedSingle;
            MaximizeBox = false;
            BackColor = Color.FromArgb(26, 26, 46);
            ForeColor = Color.FromArgb(224, 224, 224);
            Font = new Font("Segoe UI", 10);

            // Header panel
            headerPanel = new Panel
            {
                Dock = DockStyle.Top,
                Height = 100,
                BackColor = Color.FromArgb(30, 30, 60),
            };
            Controls.Add(headerPanel);

            titleLabel = new Label
            {
                Text = "Claude Code",
                Font = new Font("Segoe UI", 24, FontStyle.Bold),
                ForeColor = Color.FromArgb(192, 132, 252),
                AutoSize = false,
                Size = new Size(480, 45),
                Location = new Point(10, 15),
                TextAlign = ContentAlignment.MiddleCenter,
            };
            headerPanel.Controls.Add(titleLabel);

            subtitleLabel = new Label
            {
                Text = "Windows Explorer Context Menu Installer",
                Font = new Font("Segoe UI", 11),
                ForeColor = Color.FromArgb(160, 160, 180),
                AutoSize = false,
                Size = new Size(480, 25),
                Location = new Point(10, 60),
                TextAlign = ContentAlignment.MiddleCenter,
            };
            headerPanel.Controls.Add(subtitleLabel);

            // Description
            var descLabel = new Label
            {
                Text = "Este instalador adiciona a opcao \"Claude Code\" ao menu de contexto\n" +
                       "(botao direito) de pastas no Windows Explorer.\n\n" +
                       "Ao clicar, um formulario permite escolher:\n" +
                       "  - Modo Administrador\n" +
                       "  - Dangerously Skip Permissions",
                Font = new Font("Segoe UI", 9.5f),
                ForeColor = Color.FromArgb(180, 180, 200),
                AutoSize = false,
                Size = new Size(460, 110),
                Location = new Point(25, 115),
            };
            Controls.Add(descLabel);

            // Progress bar
            progressBar = new ProgressBar
            {
                Size = new Size(460, 6),
                Location = new Point(25, 238),
                Style = ProgressBarStyle.Continuous,
                Visible = false,
            };
            Controls.Add(progressBar);

            // Status label
            statusLabel = new Label
            {
                Text = "",
                Font = new Font("Segoe UI", 9),
                ForeColor = Color.FromArgb(100, 200, 100),
                AutoSize = false,
                Size = new Size(460, 22),
                Location = new Point(25, 248),
                TextAlign = ContentAlignment.MiddleCenter,
            };
            Controls.Add(statusLabel);

            // Install button
            installButton = new Button
            {
                Text = "Instalar",
                Size = new Size(200, 45),
                Location = new Point(40, 280),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.FromArgb(124, 58, 237),
                ForeColor = Color.White,
                Font = new Font("Segoe UI", 12, FontStyle.Bold),
                Cursor = Cursors.Hand,
            };
            installButton.FlatAppearance.BorderSize = 0;
            installButton.Click += InstallButton_Click;
            Controls.Add(installButton);

            // Uninstall button
            uninstallButton = new Button
            {
                Text = "Desinstalar",
                Size = new Size(200, 45),
                Location = new Point(265, 280),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.FromArgb(60, 60, 80),
                ForeColor = Color.FromArgb(200, 200, 200),
                Font = new Font("Segoe UI", 12),
                Cursor = Cursors.Hand,
            };
            uninstallButton.FlatAppearance.BorderSize = 0;
            uninstallButton.Click += UninstallButton_Click;
            Controls.Add(uninstallButton);
        }

        void CheckInstalledState()
        {
            bool installed = IsInstalled();
            if (installed)
            {
                statusLabel.Text = "Status: Instalado";
                statusLabel.ForeColor = Color.FromArgb(100, 200, 100);
                installButton.Text = "Reinstalar";
            }
            else
            {
                statusLabel.Text = "Status: Nao instalado";
                statusLabel.ForeColor = Color.FromArgb(200, 200, 100);
            }
        }

        static bool IsInstalled()
        {
            using var key = Registry.LocalMachine.OpenSubKey(RegPathFolder);
            return key != null;
        }

        void InstallButton_Click(object? sender, EventArgs e)
        {
            try
            {
                progressBar.Visible = true;
                progressBar.Value = 20;
                statusLabel.Text = "Instalando...";
                statusLabel.ForeColor = Color.FromArgb(200, 200, 100);
                Application.DoEvents();

                // 1. Create install directory
                Directory.CreateDirectory(InstallDir);
                progressBar.Value = 40;
                Application.DoEvents();

                // 2. Extract embedded launcher script
                string launcherContent = GetEmbeddedResource("ClaudeCodeInstaller.Resources.claude-code-launcher.ps1");
                string launcherPath = Path.Combine(InstallDir, LauncherFileName);
                File.WriteAllText(launcherPath, launcherContent);
                progressBar.Value = 60;
                Application.DoEvents();

                // 3. Register context menu
                string command = $"powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File \"{launcherPath}\" -FolderPath \"%V\"";

                RegisterContextMenu(RegPathFolder, command);
                progressBar.Value = 80;
                Application.DoEvents();

                RegisterContextMenu(RegPathBackground, command);
                progressBar.Value = 100;
                Application.DoEvents();

                statusLabel.Text = "Instalado com sucesso!";
                statusLabel.ForeColor = Color.FromArgb(100, 200, 100);
                installButton.Text = "Reinstalar";

                MessageBox.Show(
                    "Claude Code foi adicionado ao menu de contexto do Explorer!\n\n" +
                    "Clique com o botao direito em qualquer pasta para usar.",
                    "Sucesso",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );
            }
            catch (Exception ex)
            {
                statusLabel.Text = "Erro na instalacao!";
                statusLabel.ForeColor = Color.FromArgb(255, 100, 100);
                MessageBox.Show(
                    $"Erro ao instalar: {ex.Message}\n\n" +
                    "Certifique-se de executar como Administrador.",
                    "Erro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
            finally
            {
                progressBar.Visible = false;
            }
        }

        void UninstallButton_Click(object? sender, EventArgs e)
        {
            if (!IsInstalled())
            {
                MessageBox.Show("Claude Code nao esta instalado.", "Info", MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }

            var result = MessageBox.Show(
                "Deseja remover o Claude Code do menu de contexto?",
                "Confirmar Desinstalacao",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question
            );

            if (result != DialogResult.Yes) return;

            try
            {
                progressBar.Visible = true;
                progressBar.Value = 30;
                statusLabel.Text = "Desinstalando...";
                Application.DoEvents();

                // Remove registry entries
                try { Registry.LocalMachine.DeleteSubKeyTree(RegPathFolder, false); } catch { }
                progressBar.Value = 50;
                Application.DoEvents();

                try { Registry.LocalMachine.DeleteSubKeyTree(RegPathBackground, false); } catch { }
                progressBar.Value = 70;
                Application.DoEvents();

                // Remove installed files
                if (Directory.Exists(InstallDir))
                {
                    Directory.Delete(InstallDir, true);
                }
                progressBar.Value = 100;
                Application.DoEvents();

                statusLabel.Text = "Desinstalado com sucesso!";
                statusLabel.ForeColor = Color.FromArgb(200, 200, 100);
                installButton.Text = "Instalar";

                MessageBox.Show(
                    "Claude Code foi removido do menu de contexto.",
                    "Desinstalado",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );
            }
            catch (Exception ex)
            {
                statusLabel.Text = "Erro na desinstalacao!";
                statusLabel.ForeColor = Color.FromArgb(255, 100, 100);
                MessageBox.Show(
                    $"Erro ao desinstalar: {ex.Message}",
                    "Erro",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
            finally
            {
                progressBar.Visible = false;
            }
        }

        static void RegisterContextMenu(string regPath, string command)
        {
            using var key = Registry.LocalMachine.CreateSubKey(regPath);
            key.SetValue("", "Claude Code");
            key.SetValue("Position", "Top");

            using var cmdKey = Registry.LocalMachine.CreateSubKey(regPath + @"\command");
            cmdKey.SetValue("", command);
        }

        static string GetEmbeddedResource(string resourceName)
        {
            var assembly = Assembly.GetExecutingAssembly();
            using var stream = assembly.GetManifestResourceStream(resourceName)
                ?? throw new Exception($"Resource not found: {resourceName}");
            using var reader = new StreamReader(stream);
            return reader.ReadToEnd();
        }
    }
}
