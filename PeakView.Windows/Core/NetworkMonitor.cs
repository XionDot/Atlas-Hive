using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.NetworkInformation;
using System.Threading;
using System.Threading.Tasks;
using PeakView.Models;

namespace PeakView.Core
{
    public class NetworkMonitor
    {
        private CancellationTokenSource? _cancellationTokenSource;
        private Task? _monitoringTask;

        public List<NetworkConnection> Connections { get; private set; } = new();

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
                    UpdateConnections();
                    await Task.Delay(3000, cancellationToken);
                }
                catch (TaskCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    Debug.WriteLine($"Error in network monitor loop: {ex.Message}");
                }
            }
        }

        private void UpdateConnections()
        {
            try
            {
                var connections = new List<NetworkConnection>();
                var properties = IPGlobalProperties.GetIPGlobalProperties();

                // Get TCP connections
                var tcpConnections = properties.GetActiveTcpConnections();
                foreach (var conn in tcpConnections)
                {
                    var connection = new NetworkConnection
                    {
                        Protocol = "TCP",
                        LocalAddress = conn.LocalEndPoint.Address.ToString(),
                        LocalPort = conn.LocalEndPoint.Port,
                        RemoteAddress = conn.RemoteEndPoint.Address.ToString(),
                        RemotePort = conn.RemoteEndPoint.Port,
                        State = conn.State.ToString()
                    };

                    // Try to find the process that owns this connection
                    // This requires P/Invoke or external tools on Windows
                    // For now, we'll set it as unknown
                    connection.ProcessName = "Unknown";
                    connection.ProcessId = 0;

                    connections.Add(connection);
                }

                // Filter to only established connections
                Connections = connections.Where(c => c.State == "Established").ToList();
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error updating network connections: {ex.Message}");
            }
        }
    }
}
