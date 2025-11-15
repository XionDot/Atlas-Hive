using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace PeakView.Models
{
    public class Config
    {
        [JsonPropertyName("version")]
        public string Version { get; set; } = "1.0";

        [JsonPropertyName("theme")]
        public string Theme { get; set; } = "dark";

        [JsonPropertyName("viewMode")]
        public string ViewMode { get; set; } = "simple";

        [JsonPropertyName("atlasMode")]
        public bool AtlasMode { get; set; } = false;

        [JsonPropertyName("updateInterval")]
        public double UpdateInterval { get; set; } = 2.0;

        [JsonPropertyName("showWindowOnLaunch")]
        public bool ShowWindowOnLaunch { get; set; } = true;

        [JsonPropertyName("menuBar")]
        public MenuBarConfig MenuBar { get; set; } = new();

        [JsonPropertyName("thresholds")]
        public ThresholdConfig Thresholds { get; set; } = new();

        [JsonPropertyName("sectionOrder")]
        public List<string> SectionOrder { get; set; } = new() { "cpu", "memory", "network", "disk", "battery" };

        [JsonPropertyName("platform")]
        public string Platform { get; set; } = "Windows";
    }

    public class MenuBarConfig
    {
        [JsonPropertyName("showCPU")]
        public bool ShowCPU { get; set; } = false;

        [JsonPropertyName("showMemory")]
        public bool ShowMemory { get; set; } = false;

        [JsonPropertyName("showMiniGraph")]
        public bool ShowMiniGraph { get; set; } = false;
    }

    public class ThresholdConfig
    {
        [JsonPropertyName("cpu")]
        public double Cpu { get; set; } = 80.0;

        [JsonPropertyName("memory")]
        public double Memory { get; set; } = 85.0;

        [JsonPropertyName("disk")]
        public double Disk { get; set; } = 90.0;

        [JsonPropertyName("enableAlerts")]
        public bool EnableAlerts { get; set; } = false;
    }
}
