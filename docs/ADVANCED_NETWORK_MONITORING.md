# Advanced Network Monitoring

PeakView's Advanced Network Monitoring provides enterprise-grade network visibility with SNMP support, deep packet inspection, AI-ready analytics, and real-time alerting.

## Features Overview

### 1. SNMP Device Discovery & Monitoring
- **Automatic Network Scanning**: Discover SNMP-enabled devices on your network
- **Multi-Version Support**: SNMPv1, SNMPv2c, SNMPv3
- **Device Classification**: Automatic detection of routers, switches, firewalls, access points
- **Real-time Polling**: Monitor device health, interfaces, and metrics
- **Interface Monitoring**: Track bandwidth, errors, discards per interface

### 2. Deep Packet Inspection (DPI)
- **Network Flow Tracking**: Monitor 5-tuple flows (src IP/port, dst IP/port, protocol)
- **Protocol Detection**: Automatically identify HTTP, HTTPS, SSH, DNS, SMTP, and more
- **Application Awareness**: Detect applications based on traffic patterns
- **Performance Metrics**: RTT, jitter, packet loss, retransmissions per flow
- **Protocol Categorization**: Web, Email, File Transfer, Streaming, Gaming, etc.

### 3. AI-Ready Time-Series Analytics
- **Historical Data Collection**: 10-second intervals, up to 27+ hours of data
- **Anomaly Detection**: Statistical analysis using 3-sigma rule
- **ML-Ready Export**: JSON format compatible with TensorFlow, PyTorch, scikit-learn
- **Data Points Include**:
  - Bytes in/out
  - Packets in/out
  - Active connections
  - Latency measurements
  - Packet loss percentages
  - Per-protocol breakdown

### 4. Network Topology Visualization
- **Device Mapping**: Visual representation of network devices
- **Connection Tracking**: See relationships between devices
- **Real-time Status**: Live updates on device availability
- **Geographic Awareness**: Support for lat/lon positioning

### 5. Advanced Alert System
- **Configurable Rules**: Set thresholds for bandwidth, latency, packet loss, etc.
- **Multi-Severity Levels**: Critical, Warning, Info
- **Alert Categories**: Bandwidth, Latency, Device Down, Security, Anomaly
- **Duration-Based Triggers**: Alerts only fire if condition persists
- **Acknowledgment System**: Track which alerts have been addressed

## Usage

### SNMP Device Discovery

```swift
let advancedMonitor = AdvancedNetworkMonitor()

// Discover devices on 192.168.1.0/24 with community string "public"
advancedMonitor.discoverSNMPDevices(network: "192.168.1", community: "public")
```

**Discovered Information:**
- System description (sysDescr)
- Uptime (sysUpTime)
- Contact (sysContact)
- Name (sysName)
- Location (sysLocation)
- Network interfaces
- Performance metrics

### Monitoring Network Flows

The monitor automatically tracks all network flows and provides:
- Source and destination IP:port
- Protocol (TCP/UDP/ICMP)
- Packet count and byte count
- Duration and throughput
- RTT and performance metrics

### Time-Series Data Export

```swift
// Export for ML training
let jsonData = advancedMonitor.exportHistoricalData()
// Save to file for training with:
// - TensorFlow/Keras LSTM networks
// - PyTorch autoencoders
// - scikit-learn Isolation Forest
// - Custom anomaly detection models
```

**Data Format:**
```json
{
  "timestamp": "2024-11-22T12:00:00Z",
  "bytesIn": 1048576,
  "bytesOut": 524288,
  "packetsIn": 1024,
  "packetsOut": 512,
  "activeConnections": 42,
  "latency": 15.5,
  "packetLoss": 0.1,
  "protocolBreakdown": {
    "HTTP": 524288,
    "HTTPS": 262144,
    "DNS": 4096
  },
  "isAnomaly": false,
  "anomalyScore": 1.2,
  "anomalyReason": null
}
```

### Alert Rules

```swift
let rule = AlertRule(
    isEnabled: true,
    metric: .totalBandwidth,
    condition: .greaterThan,
    threshold: 100_000_000, // 100 MB/s
    duration: 60, // seconds
    severity: .warning
)

advancedMonitor.alertRules.append(rule)
```

**Available Metrics:**
- `bandwidthIn` - Incoming bandwidth
- `bandwidthOut` - Outgoing bandwidth
- `totalBandwidth` - Total bandwidth
- `latency` - Network latency (ms)
- `packetLoss` - Packet loss percentage
- `cpuUsage` - Device CPU usage (SNMP)
- `memoryUsage` - Device memory usage (SNMP)
- `connectionCount` - Active connection count
- `errorRate` - Network error rate

## Architecture

### Data Flow

```
┌─────────────────┐
│ Network Traffic │
└────────┬────────┘
         │
         v
┌─────────────────┐
│  netstat/lsof   │  ← Basic connection tracking
└────────┬────────┘
         │
         v
┌─────────────────┐
│  SNMP Polling   │  ← Device discovery & metrics
└────────┬────────┘
         │
         v
┌─────────────────┐
│  Flow Analysis  │  ← DPI & protocol detection
└────────┬────────┘
         │
         v
┌─────────────────┐
│  Time-Series    │  ← Historical data collection
│   Collection    │
└────────┬────────┘
         │
         v
┌─────────────────┐
│    Anomaly      │  ← Statistical analysis
│   Detection     │
└────────┬────────┘
         │
         v
┌─────────────────┐
│  Alert Engine   │  ← Rule evaluation
└────────┬────────┘
         │
         v
┌─────────────────┐
│   User/Export   │  ← Visualization & ML export
└─────────────────┘
```

### Components

#### AdvancedNetworkMonitor.swift
Core monitoring engine with:
- SNMP device discovery
- Flow collection
- Time-series data management
- Anomaly detection
- Alert rule engine

#### AdvancedNetworkView.swift
SwiftUI interface with 7 tabs:
1. **Overview** - Key metrics and bandwidth graphs
2. **Topology** - Visual network map
3. **SNMP Devices** - Discovered device list and details
4. **Network Flows** - Active connection streams
5. **Protocols** - Detected protocols by category
6. **AI Analytics** - Historical data and ML export
7. **Alerts** - Real-time alerts and acknowledgment

## AI/ML Integration

### Supported Use Cases

#### 1. Anomaly Detection
Train models to detect unusual network behavior:
- Bandwidth spikes
- Unusual protocols
- Connection pattern changes
- Device availability issues

**Recommended Models:**
- Isolation Forest (scikit-learn)
- One-Class SVM
- LSTM Autoencoders (TensorFlow/PyTorch)
- Variational Autoencoders (VAE)

#### 2. Predictive Maintenance
Predict device failures before they occur:
- Uptime patterns
- Error rate trends
- Performance degradation

**Recommended Models:**
- LSTM networks for time-series forecasting
- Prophet (Facebook)
- ARIMA models

#### 3. Traffic Classification
Classify traffic types and applications:
- Protocol identification
- Application detection
- QoS classification

**Recommended Models:**
- Random Forest
- XGBoost
- Neural networks

#### 4. Security Threat Detection
Identify potential security threats:
- DDoS attacks
- Port scanning
- Data exfiltration
- Botnet activity

**Recommended Models:**
- Deep learning classifiers
- Ensemble methods
- Behavioral analysis models

### Training Data Preparation

```python
import json
import pandas as pd
from sklearn.preprocessing import StandardScaler

# Load exported data
with open('network_timeseries.json') as f:
    data = json.load(f)

# Convert to DataFrame
df = pd.DataFrame(data)

# Feature engineering
df['total_traffic'] = df['bytesIn'] + df['bytesOut']
df['traffic_ratio'] = df['bytesIn'] / (df['bytesOut'] + 1)
df['timestamp'] = pd.to_datetime(df['timestamp'])
df['hour'] = df['timestamp'].dt.hour
df['day_of_week'] = df['timestamp'].dt.dayofweek

# Normalize features
scaler = StandardScaler()
features = ['bytesIn', 'bytesOut', 'packetsIn', 'packetsOut',
            'activeConnections', 'latency', 'packetLoss']
df[features] = scaler.fit_transform(df[features])

# Ready for ML!
```

### Example: Anomaly Detection with Isolation Forest

```python
from sklearn.ensemble import IsolationForest
import numpy as np

# Prepare features
X = df[['bytesIn', 'bytesOut', 'latency', 'packetLoss']].values

# Train model
clf = IsolationForest(contamination=0.1, random_state=42)
clf.fit(X)

# Predict anomalies
df['ml_anomaly'] = clf.predict(X)
df['ml_anomaly_score'] = clf.score_samples(X)

# Compare with built-in anomaly detection
print(f"Built-in detected: {df['isAnomaly'].sum()} anomalies")
print(f"ML detected: {(df['ml_anomaly'] == -1).sum()} anomalies")
```

## SNMP OIDs Reference

### System Information
- `1.3.6.1.2.1.1.1.0` - sysDescr (System Description)
- `1.3.6.1.2.1.1.3.0` - sysUpTime (System Uptime)
- `1.3.6.1.2.1.1.4.0` - sysContact (Contact)
- `1.3.6.1.2.1.1.5.0` - sysName (System Name)
- `1.3.6.1.2.1.1.6.0` - sysLocation (Location)

### Interface Statistics
- `1.3.6.1.2.1.2.2.1.10` - ifInOctets (Bytes received)
- `1.3.6.1.2.1.2.2.1.16` - ifOutOctets (Bytes sent)
- `1.3.6.1.2.1.2.2.1.14` - ifInErrors (Receive errors)
- `1.3.6.1.2.1.2.2.1.20` - ifOutErrors (Transmit errors)

### Performance
- `1.3.6.1.4.1.2021.10.1.3.1` - Load Average (1 min)
- `1.3.6.1.4.1.2021.11.9.0` - CPU Idle
- `1.3.6.1.4.1.2021.4.5.0` - Memory Total
- `1.3.6.1.4.1.2021.4.6.0` - Memory Free

## Performance Considerations

### Resource Usage
- **CPU**: ~2-5% during normal operation
- **Memory**: ~50-100 MB for historical data
- **Network**: Minimal (SNMP queries are lightweight)
- **Disk**: Time-series data ~1 MB per hour

### Optimization Tips
1. **Adjust Polling Intervals**:
   - SNMP: 30 seconds (default) - increase for less critical devices
   - Flows: 5 seconds (default) - decrease for higher granularity
   - Time-series: 10 seconds (default) - adjust based on storage

2. **Limit Historical Data**:
   - Default: 10,000 points (~27 hours)
   - Increase for longer retention
   - Export and archive periodically

3. **Filter Devices**:
   - Only poll critical infrastructure
   - Skip non-SNMP devices

## Security & Privacy

### Privacy-First Design
- ✅ All processing is **local** - no cloud dependencies
- ✅ No telemetry or external reporting
- ✅ SNMP credentials stored securely in memory only
- ✅ Packet inspection does not store payload data
- ✅ Historical data stays on device

### SNMP Security
- Use SNMPv3 with authentication when possible
- Change default community strings ("public", "private")
- Limit SNMP access to trusted management networks
- Use read-only community strings

### Best Practices
- Don't hardcode SNMP credentials
- Use encrypted storage for credentials (Keychain)
- Audit SNMP access regularly
- Monitor for unauthorized SNMP queries

## Future Enhancements

### Planned Features
- [ ] ML model integration (LSTM, Isolation Forest)
- [ ] Real packet capture (libpcap integration)
- [ ] NetFlow/sFlow support
- [ ] IPFIX support
- [ ] BGP route monitoring
- [ ] Quality of Service (QoS) analysis
- [ ] VoIP quality metrics (MOS, jitter buffer)
- [ ] Application signatures database
- [ ] Geographic IP mapping
- [ ] Network path visualization (traceroute)

### AI Roadmap
- [ ] Automatic baseline learning
- [ ] Predictive alerting (predict issues before they occur)
- [ ] Natural language queries ("Why is bandwidth high?")
- [ ] Auto-remediation suggestions
- [ ] Correlation analysis across metrics
- [ ] Seasonal pattern detection
- [ ] Multi-variate anomaly detection

## Troubleshooting

### SNMP Discovery Not Working
1. **Check Network Reachability**: Devices must respond to ping
2. **Verify Community String**: Ensure correct SNMP community string
3. **Check SNMP Version**: Some devices only support v1 or v2c
4. **Firewall Rules**: UDP port 161 must be open
5. **SNMP Enabled**: Verify SNMP is enabled on target devices

### High Resource Usage
1. **Reduce Polling Frequency**: Increase timer intervals
2. **Limit Historical Data**: Reduce maxHistoricalPoints
3. **Filter Flows**: Only track relevant connections
4. **Disable Unused Features**: Turn off SNMP if not needed

### Anomaly False Positives
1. **Increase Threshold**: Change from 3-sigma to 4 or 5
2. **Longer Baseline**: Collect more data before detection
3. **Filter Expected Spikes**: Exclude scheduled backups, etc.

## API Reference

### AdvancedNetworkMonitor

#### Properties
- `snmpDevices: [SNMPDevice]` - Discovered SNMP devices
- `flows: [NetworkFlow]` - Active network flows
- `detectedProtocols: [DetectedProtocol]` - Detected protocols
- `historicalData: [NetworkDataPoint]` - Time-series data
- `alerts: [NetworkAlert]` - Active alerts
- `alertRules: [AlertRule]` - Configured alert rules

#### Methods
- `discoverSNMPDevices(network: String, community: String)` - Scan network
- `startAdvancedMonitoring()` - Start all monitoring
- `stopAdvancedMonitoring()` - Stop all monitoring
- `exportHistoricalData() -> String` - Export JSON for ML
- `exportAlerts() -> String` - Export alerts JSON

## License

Part of PeakView - Privacy-first system monitoring for macOS.

---

**Need Help?** Open an issue on GitHub or check the main README.
