using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Shapes;

namespace PeakView.Views
{
    /// <summary>
    /// Interaction logic for AtlasView.xaml
    /// </summary>
    public partial class AtlasView : Window
    {
        private readonly List<AtlasCommand> _allCommands;
        private bool _isSamaritanMode = false;

        public AtlasView()
        {
            InitializeComponent();

            _allCommands = new List<AtlasCommand>
            {
                new() { Name = "Network Monitor", Description = "Traffic & Speed Analysis", Icon = "📊", Keywords = new[] { "network", "traffic", "bandwidth", "speed", "internet" } },
                new() { Name = "CPU Analytics", Description = "Processor Metrics", Icon = "⚡", Keywords = new[] { "cpu", "processor", "performance" } },
                new() { Name = "Memory Status", Description = "RAM Usage & Pressure", Icon = "💾", Keywords = new[] { "memory", "ram", "swap" } },
                new() { Name = "Disk Analysis", Description = "Storage Metrics", Icon = "💿", Keywords = new[] { "disk", "storage", "drive" } },
                new() { Name = "Process Manager", Description = "Running Applications", Icon = "📦", Keywords = new[] { "processes", "apps", "tasks" } },
                new() { Name = "System Overview", Description = "Complete Metrics", Icon = "📈", Keywords = new[] { "system", "overview", "complete" } },
                new() { Name = "All Metrics", Description = "Everything At Once", Icon = "🎯", Keywords = new[] { "all", "everything", "full", "complete", "atlas" } },
                new() { Name = "Exit Atlas Mode", Description = "Return to Normal View", Icon = "⬅️", Keywords = new[] { "exit", "leave", "return", "normal", "back" } },
                new() { Name = "Theme: Samaritan", Description = "Red Terminal Theme", Icon = "🔴", Keywords = new[] { "theme", "samaritan", "red", "terminal" } },
                new() { Name = "Theme: Pure Black", Description = "Pure Black Theme", Icon = "🌑", Keywords = new[] { "theme", "black", "dark", "pure" } },
            };
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            DrawGrid();
            CommandInput.Focus();
        }

        private void DrawGrid()
        {
            GridCanvas.Children.Clear();
            var gridSpacing = 60.0;
            var accentColor = _isSamaritanMode ? Color.FromRgb(255, 51, 51) : Color.FromRgb(51, 153, 255);
            var gridBrush = new SolidColorBrush(accentColor) { Opacity = 0.1 };

            // Vertical lines
            for (double x = 0; x <= ActualWidth; x += gridSpacing)
            {
                var line = new Line
                {
                    X1 = x,
                    Y1 = 0,
                    X2 = x,
                    Y2 = ActualHeight,
                    Stroke = gridBrush,
                    StrokeThickness = 1
                };
                GridCanvas.Children.Add(line);
            }

            // Horizontal lines
            for (double y = 0; y <= ActualHeight; y += gridSpacing)
            {
                var line = new Line
                {
                    X1 = 0,
                    Y1 = y,
                    X2 = ActualWidth,
                    Y2 = y,
                    Stroke = gridBrush,
                    StrokeThickness = 1
                };
                GridCanvas.Children.Add(line);
            }
        }

        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            // ESC: Reset to initial state
            if (e.Key == Key.Escape)
            {
                InitialScreen.Visibility = Visibility.Visible;
                WidgetScreen.Visibility = Visibility.Collapsed;
                CommandInput.Text = "";
                CommandInput.Focus();
            }

            // Ctrl+K or Cmd+K: Toggle command palette
            if ((Keyboard.Modifiers & ModifierKeys.Control) == ModifierKeys.Control && e.Key == Key.K)
            {
                ToggleCommandPalette();
            }
        }

        private void CommandInput_TextChanged(object sender, System.Windows.Controls.TextChangedEventArgs e)
        {
            var searchText = CommandInput.Text.ToLower();

            if (string.IsNullOrWhiteSpace(searchText))
            {
                SuggestionsPanel.Visibility = Visibility.Collapsed;
                return;
            }

            var filteredCommands = _allCommands
                .Where(cmd => cmd.Name.ToLower().Contains(searchText) ||
                             cmd.Keywords.Any(k => k.ToLower().Contains(searchText)))
                .Take(8)
                .ToList();

            if (filteredCommands.Any())
            {
                SuggestionsPanel.ItemsSource = filteredCommands;
                SuggestionsPanel.Visibility = Visibility.Visible;
            }
            else
            {
                SuggestionsPanel.Visibility = Visibility.Collapsed;
            }
        }

        private void CommandInput_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter && !string.IsNullOrWhiteSpace(CommandInput.Text))
            {
                ExecuteCommand(CommandInput.Text);
            }
        }

        private void ExecuteCommand(string command)
        {
            var cmd = _allCommands.FirstOrDefault(c =>
                c.Name.Equals(command, StringComparison.OrdinalIgnoreCase) ||
                c.Keywords.Any(k => k.Equals(command, StringComparison.OrdinalIgnoreCase)));

            if (cmd != null)
            {
                HandleCommand(cmd);
            }
        }

        private void HandleCommand(AtlasCommand command)
        {
            if (command.Name == "Exit Atlas Mode")
            {
                Close();
            }
            else if (command.Name == "Theme: Samaritan")
            {
                ApplySamaritanTheme();
            }
            else if (command.Name == "Theme: Pure Black")
            {
                ApplyPureBlackTheme();
            }
            else
            {
                // Show widget screen
                InitialScreen.Visibility = Visibility.Collapsed;
                WidgetScreen.Visibility = Visibility.Visible;

                // TODO: Load widget content based on command
            }
        }

        private void ApplySamaritanTheme()
        {
            _isSamaritanMode = true;
            SubtitleText.Text = "SAMARITAN SYSTEM INTERFACE";
            ScanlinesOverlay.Visibility = Visibility.Visible;
            DrawGrid();
        }

        private void ApplyPureBlackTheme()
        {
            _isSamaritanMode = false;
            SubtitleText.Text = "System Interface";
            ScanlinesOverlay.Visibility = Visibility.Collapsed;
            DrawGrid();
        }

        private void FloatingCommandButton_Click(object sender, RoutedEventArgs e)
        {
            ToggleCommandPalette();
        }

        private void ToggleCommandPalette()
        {
            OverlayCommandPalette.Visibility =
                OverlayCommandPalette.Visibility == Visibility.Visible
                    ? Visibility.Collapsed
                    : Visibility.Visible;
        }
    }

    public class AtlasCommand
    {
        public string Name { get; set; } = "";
        public string Description { get; set; } = "";
        public string Icon { get; set; } = "";
        public string[] Keywords { get; set; } = Array.Empty<string>();
    }
}
