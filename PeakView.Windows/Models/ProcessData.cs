namespace PeakView.Models
{
    public class ProcessData
    {
        public int Pid { get; set; }
        public string Name { get; set; } = string.Empty;
        public double CpuUsage { get; set; }
        public double MemoryMB { get; set; }
        public string Path { get; set; } = string.Empty;
    }
}
