using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Threading;
using PeakView.Core;

namespace PeakView
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly SystemMonitor _systemMonitor;
        private readonly TaskManager _taskManager;
        private readonly DispatcherTimer _updateTimer;

        public MainWindow()
        {
            InitializeComponent();

            _systemMonitor = new SystemMonitor();
            _taskManager = new TaskManager();

            // Setup update timer (2 second interval)
            _updateTimer = new DispatcherTimer
            {
                Interval = TimeSpan.FromSeconds(2)
            };
            _updateTimer.Tick += UpdateTimer_Tick;
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            // Start monitoring
            _systemMonitor.StartMonitoring();
            _taskManager.StartMonitoring();
            _updateTimer.Start();

            // Initial update
            UpdateUI();
        }

        private void Window_Closing(object? sender, CancelEventArgs e)
        {
            // Stop monitoring
            _updateTimer.Stop();
            _systemMonitor.StopMonitoring();
            _taskManager.StopMonitoring();
        }

        private void UpdateTimer_Tick(object? sender, EventArgs e)
        {
            UpdateUI();
        }

        private void UpdateUI()
        {
            // Update system monitor
            CpuUsageText.Text = $"{_systemMonitor.CpuUsage:F1}%";
            MemoryUsageText.Text = $"{_systemMonitor.MemoryUsage:F1}%";
            MemoryDetailsText.Text = $"{FormatBytes(_systemMonitor.MemoryUsed)} / {FormatBytes(_systemMonitor.MemoryTotal)}";
            NetworkDownloadText.Text = $"{FormatBytes(_systemMonitor.NetworkDownload)}/s";
            NetworkUploadText.Text = $"{FormatBytes(_systemMonitor.NetworkUpload)}/s";
            DiskUsageText.Text = $"{_systemMonitor.DiskUsage:F1}%";
            DiskDetailsText.Text = $"{FormatBytes(_systemMonitor.DiskFree)} free of {FormatBytes(_systemMonitor.DiskTotal)}";

            // Update task manager
            ProcessCountText.Text = $"{_taskManager.Processes.Count} processes";
            ProcessDataGrid.ItemsSource = null;
            ProcessDataGrid.ItemsSource = _taskManager.Processes;
        }

        private static string FormatBytes(double bytes)
        {
            if (bytes < 1024)
                return $"{bytes:F0} B";
            if (bytes < 1024 * 1024)
                return $"{bytes / 1024:F1} KB";
            if (bytes < 1024 * 1024 * 1024)
                return $"{bytes / 1024 / 1024:F1} MB";
            return $"{bytes / 1024 / 1024 / 1024:F2} GB";
        }
    }
}
