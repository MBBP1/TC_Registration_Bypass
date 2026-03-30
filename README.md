# TotalC_Registration_Bypass

Script that automatically clicks the correct number when Total Commander starts.

## Setup Instructions

1. **Create a PowerShell file on your Desktop**  
   - Right-click → New → Text Document → rename it to `your.ps1`  
   - Make sure the file extension is `.ps1`, not `.txt`.

2. **Copy the script**  
   - Open `autoSetup.ps1`  
   - Copy the entire content and paste it into `your.ps1`

3. **Run the script**  
   - Open Command Prompt (cmd) in the folder where the script is located  
   - Run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\your.ps1
   ```
   (This temporarily allows the PowerShell autoSetup script to run for this session only. It does not change system settings.)



> Alternatively, you can download and extract the repository and run the script directly in Visual Studio Code.
