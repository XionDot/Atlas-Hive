using System.Windows;
using PeakView.Core;

namespace PeakView
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private ConfigManager? _configManager;

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);

            // Initialize configuration
            _configManager = new ConfigManager();
            _configManager.LoadConfig();

            // Set shutdown mode to explicit (app continues when main window closes)
            ShutdownMode = ShutdownMode.OnExplicitShutdown;
        }

        protected override void OnExit(ExitEventArgs e)
        {
            // Save configuration on exit
            _configManager?.SaveConfig();
            base.OnExit(e);
        }
    }
}
