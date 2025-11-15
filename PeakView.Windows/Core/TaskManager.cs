using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using PeakView.Models;

namespace PeakView.Core
{
    public class TaskManager
    {
        private CancellationTokenSource? _cancellationTokenSource;
        private Task? _monitoringTask;
        private Dictionary<int, (DateTime, TimeSpan)> _processCpuTimes = new();

        public List<ProcessData> Processes { get; private set; } = new();

        public void StartMonitoring()
        {
            _cancellationTokenSource = new CancellationTokenSource();
            _monitoringTask = Task.Run(() => MonitoringLoop(_cancellationTokenSource.Token));
        }

        public void StopMonitoring()
        {
            _cancellationTokenSource?.Cancel();
            _monitoringTask?.Wait();
        }

        private async Task MonitoringLoop(CancellationToken cancellationToken)
        {
            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    UpdateProcesses();
                    await Task.Delay(2000, cancellationToken);
                }
                catch (TaskCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    Debug.WriteLine($"Error in task manager loop: {ex.Message}");
                }
            }
        }

        private void UpdateProcesses()
        {
            try
            {
                var processes = Process.GetProcesses();
                var processList = new List<ProcessData>();
                var newCpuTimes = new Dictionary<int, (DateTime, TimeSpan)>();
                var now = DateTime.Now;

                foreach (var process in processes)
                {
                    try
                    {
                        var processData = new ProcessData
                        {
                            Pid = process.Id,
                            Name = process.ProcessName,
                            MemoryMB = process.WorkingSet64 / 1024.0 / 1024.0,
                            CpuUsage = 0
                        };

                        // Calculate CPU usage
                        try
                        {
                            var totalProcessorTime = process.TotalProcessorTime;
                            newCpuTimes[process.Id] = (now, totalProcessorTime);

                            if (_processCpuTimes.TryGetValue(process.Id, out var previousTime))
                            {
                                var timeDiff = (now - previousTime.Item1).TotalMilliseconds;
                                var cpuDiff = (totalProcessorTime - previousTime.Item2).TotalMilliseconds;

                                if (timeDiff > 0)
                                {
                                    var cpuUsage = (cpuDiff / timeDiff / Environment.ProcessorCount) * 100;
                                    processData.CpuUsage = Math.Max(0, Math.Min(100, cpuUsage));
                                }
                            }
                        }
                        catch
                        {
                            // CPU calculation failed, keep at 0
                        }

                        try
                        {
                            processData.Path = process.MainModule?.FileName ?? "";
                        }
                        catch
                        {
                            // Access denied for some system processes
                        }

                        processList.Add(processData);
                    }
                    catch
                    {
                        // Process may have exited, skip it
                    }
                    finally
                    {
                        process.Dispose();
                    }
                }

                _processCpuTimes = newCpuTimes;

                // Sort by CPU usage (descending)
                Processes = processList.OrderByDescending(p => p.CpuUsage).ToList();
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error updating processes: {ex.Message}");
            }
        }

        public bool KillProcess(int pid)
        {
            try
            {
                var process = Process.GetProcessById(pid);
                process.Kill();
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
