using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace PeakView.Core
{
    public class SystemMonitor
    {
        private PerformanceCounter? _cpuCounter;
        private PerformanceCounter? _ramCounter;
        private PerformanceCounter? _networkSentCounter;
        private PerformanceCounter? _networkReceivedCounter;

        private CancellationTokenSource? _cancellationTokenSource;
        private Task? _monitoringTask;

        // Public properties
        public double CpuUsage { get; private set; }
        public double MemoryUsage { get; private set; }
        public double MemoryUsed { get; private set; }
        public double MemoryTotal { get; private set; }
        public double MemoryFree { get; private set; }
        public double NetworkDownload { get; private set; }
        public double NetworkUpload { get; private set; }
        public double DiskUsage { get; private set; }
        public double DiskFree { get; private set; }
        public double DiskTotal { get; private set; }

        public void StartMonitoring()
        {
            try
            {
                // Initialize performance counters
                _cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
                _ramCounter = new PerformanceCounter("Memory", "Available MBytes");

                // Network counters (using first network interface)
                var category = new PerformanceCounterCategory("Network Interface");
                var instanceNames = category.GetInstanceNames();
                if (instanceNames.Length > 0)
                {
                    var networkInterface = instanceNames.FirstOrDefault(name => !name.Contains("Loopback"));
                    if (networkInterface != null)
                    {
                        _networkSentCounter = new PerformanceCounter("Network Interface", "Bytes Sent/sec", networkInterface);
                        _networkReceivedCounter = new PerformanceCounter("Network Interface", "Bytes Received/sec", networkInterface);
                    }
                }

                // Get total memory
                var computerInfo = new Microsoft.VisualBasic.Devices.ComputerInfo();
                MemoryTotal = computerInfo.TotalPhysicalMemory;

                // Start monitoring task
                _cancellationTokenSource = new CancellationTokenSource();
                _monitoringTask = Task.Run(() => MonitoringLoop(_cancellationTokenSource.Token));
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error starting system monitor: {ex.Message}");
            }
        }

        public void StopMonitoring()
        {
            _cancellationTokenSource?.Cancel();
            _monitoringTask?.Wait();

            _cpuCounter?.Dispose();
            _ramCounter?.Dispose();
            _networkSentCounter?.Dispose();
            _networkReceivedCounter?.Dispose();
        }

        private async Task MonitoringLoop(CancellationToken cancellationToken)
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    UpdateMetrics();
                    await Task.Delay(1000, cancellationToken);
                }
                catch (TaskCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    Debug.WriteLine($"Error in monitoring loop: {ex.Message}");
                }
            }
        }

        private void UpdateMetrics()
        {
            // CPU Usage
            if (_cpuCounter != null)
            {
                CpuUsage = _cpuCounter.NextValue();
            }

            // Memory Usage
            if (_ramCounter != null)
            {
                MemoryFree = _ramCounter.NextValue() * 1024 * 1024; // Convert MB to bytes
                MemoryUsed = MemoryTotal - MemoryFree;
                MemoryUsage = (MemoryUsed / MemoryTotal) * 100;
            }

            // Network Usage
            if (_networkReceivedCounter != null)
            {
                NetworkDownload = _networkReceivedCounter.NextValue();
            }
            if (_networkSentCounter != null)
            {
                NetworkUpload = _networkSentCounter.NextValue();
            }

            // Disk Usage
            UpdateDiskMetrics();
        }

        private void UpdateDiskMetrics()
        {
            try
            {
                var drives = DriveInfo.GetDrives().Where(d => d.IsReady && d.DriveType == DriveType.Fixed);
                var systemDrive = drives.FirstOrDefault(d => d.Name == Path.GetPathRoot(Environment.SystemDirectory));

                if (systemDrive != null)
                {
                    DiskTotal = systemDrive.TotalSize;
                    DiskFree = systemDrive.AvailableFreeSpace;
                    DiskUsage = ((DiskTotal - DiskFree) / DiskTotal) * 100;
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error updating disk metrics: {ex.Message}");
            }
        }
    }
}
