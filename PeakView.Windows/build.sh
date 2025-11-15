#!/bin/bash

# PeakView Windows Build Script
# Creates a portable executable for easy transfer to Windows devices

set -e

echo "🔨 Building PeakView for Windows..."
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if dotnet is installed
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}❌ .NET SDK not found!${NC}"
    echo "Please install .NET 8.0 SDK from: https://dotnet.microsoft.com/download"
    exit 1
fi

# Navigate to the Windows project directory
cd "$(dirname "$0")"

echo -e "${YELLOW}📦 Restoring dependencies...${NC}"
dotnet restore

echo ""
echo -e "${YELLOW}🔧 Building Release configuration...${NC}"
dotnet build -c Release

echo ""
echo -e "${YELLOW}📦 Creating portable executable...${NC}"
echo "   (Self-contained build with .NET runtime included)"

# Create self-contained portable build
dotnet publish -c Release \
    -r win-x64 \
    --self-contained true \
    -p:PublishSingleFile=true \
    -p:IncludeNativeLibrariesForSelfExtract=true \
    -p:PublishTrimmed=false \
    -p:EnableCompressionInSingleFile=true

echo ""
echo -e "${GREEN}✅ Build complete!${NC}"
echo ""
echo "Portable executable location:"
echo "  $(pwd)/bin/Release/net8.0-windows/win-x64/publish/PeakView.exe"
echo ""
echo "📋 File size:"
ls -lh bin/Release/net8.0-windows/win-x64/publish/PeakView.exe | awk '{print "  " $5}'
echo ""
echo -e "${GREEN}📱 Transfer Instructions:${NC}"
echo "  1. Copy PeakView.exe to your Windows device"
echo "  2. Double-click to run (no installation needed)"
echo "  3. Windows Defender SmartScreen may show a warning (click 'More info' → 'Run anyway')"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} For a smaller file size (requires .NET 8.0 runtime on target):"
echo "  dotnet publish -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true"
echo ""
