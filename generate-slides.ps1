# Install Marp CLI globally if not already installed
npm install -g @marp-team/marp-cli

# Define the slides folder path
$slidesPath = ".\slides"

# Get all Markdown files in the slides folder
$mdFiles = Get-ChildItem -Path $slidesPath -Filter "*.md"

# Generate PDF for each Markdown file
foreach ($file in $mdFiles) {
    $inputPath = $file.FullName
    $outputPath = [System.IO.Path]::ChangeExtension($inputPath, "pdf")
    Write-Host "Generating PDF for $($file.Name)..."
    marp --pdf $inputPath -o $outputPath
}

Write-Host "PDF generation complete."