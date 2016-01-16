#########################################################################################
# Author: Ganguly, Kushal; 
# Date: 29.10.2015
# 
# Description: 
# The script parses log file, stores the parsed lastline number to 'lastLineNumber.txt' file and starts parsing the appended lines of the log file from the last parsed line during next execution. 
# The parameter $inputFilePath specifies the path of the textfile containing list of error and warning search strings along with their corresponding comma separated exitcode, count threshold and display message. 
# If error search string count becomes more than its threshold, it returns 2 and a message string containing all the above threshold count number of the corresponding error and warning search strings. 
# When all the error search string counts are below their corresponding threshold and any warning search string count is above threshold, it returns 1 and the message string containing all the above threshold count number 
# of the corresponding warning search strings. It returns 0 and the message string OK, when all error and warning strings are below their threshold.
# 
#  Nagios return values:
#  0 = OK
#  1 = WARNING
#  2 = CRITICAL
#  3 = UNKNOWN
#  and a message string containing each search string counts whenever the count becomes more than its threshold.   
#
#
# History:
#
# Date             Author                     Comment
# ----------       -------------------------- --------------------------------------------
# 29.10.2015       Kushal Ganguly             Initial version
# 
##########################################################################################
<#
.SYNOPSIS
Log parsing script

.DESCRIPTION
The script parses log file, stores the parsed lastline number to 'lastLineNumber.txt' file and starts parsing the appended lines of the log file from the last parsed line during next execution. 
The parameter $inputFilePath specifies the textfile containing list of error and warning search strings along with their corresponding comma separated exitcode, count threshold and display message. 
If error search string count becomes more than its threshold, it returns 2 and a message string containing all the above threshold count number of the corresponding error and warning search strings. 
When all the error search string counts are below their corresponding threshold and any warning search string count is above threshold, it returns 1 and the message string containing all the above threshold count number 
of the corresponding warning search strings. It returns 0 and the message string OK, when all error and warning strings are below their threshold.
  
.PARAMETER inputFilePath
Specifies the path of the textfile containing list of error and warning search strings along with their corresponding comma separated exitcode and count threshold.

.PARAMETER logFilePath
Specifies the path of the logfile to be parsed.

.EXAMPLE
.\logFileParser.ps1 -input C:\Programs\data\inputStrings.txt -file C:\Programs\data\server2.log

.NOTES
Version: 1.0.0
Author : Ganguly, Kushal;
#>

Param(
  [parameter(Mandatory=$true)]
  [alias("input")]
  [string]$inputFilePath,
  [parameter(Mandatory=$true)]
  [alias("file")]
  [string]$logFilePath
)
   
$countFilePath = $logFilePath.Replace($logFilePath.Split("\")[-1],"")+$logFilePath.Split("\")[-1].Split(".")[0]+"_lastLineNumber.txt";

If((Test-Path $countFilePath) -eq $False) {
 Set-Content -Value 0 -Path $countFilePath;
    }

$lastLineNumber = Get-Content $countFilePath;

$lineNum = [decimal]$lastLineNumber;
$outputMessage ="";
$errorPresent=0;
$warningPresent=0;

try{
$inputStringArray = Get-Content $inputFilePath -ErrorAction Stop;
}
 Catch [System.Management.Automation.ActionPreferenceStopException] {
write-host "$_" 
exit 3
}
          
try{
$file = New-Object IO.StreamReader([System.IO.File]::Open($logFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite));
$count = 1;
$countArray = @();
for($i=0; $i -lt $inputStringArray.Length; $i++)
{
   $countArray += 0; 
} 

 while($file.EndOfStream -ne $true)            
    {
    
      if($lineNum -gt $count)
      {
        $line=$file.ReadLine(); 
      }
      else 
      {
            $line=$file.ReadLine();                
               
            for($i=0; $i -lt $inputStringArray.Length; $i++)
            {   
                $splitArray = @();
                $inputStringArray[$i].Split(";") | ForEach {
                      
                      $splitArray +="$_";
                }
                $searchString = $splitArray[0];
                $returnCode = $splitArray[1];
                $allowedNumber = $splitArray[2];
                
                if($line.Contains($searchString))            
                 {  
                    $countArray +=$countArray[$i]++;
                    if($returnCode -eq 2 -And $countArray[$i] -gt $allowedNumber){$errorPresent=1;}
                    if($returnCode -eq 1 -And $countArray[$i] -gt $allowedNumber){$warningPresent=1;}
                            
                 }
                 
            }
                        
      }  
             
     $count++;    
                         
    } 
                
 $file.Close();

if($lineNum -ge $count){
$newfile = New-Object IO.StreamReader([System.IO.File]::Open($logFilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite));
$count = 1;
              
 while($newfile.EndOfStream -ne $true)            
    {               
            $newline=$newfile.ReadLine();  

            for($i=0; $i -lt $inputStringArray.Length; $i++)
            {   
                $splitArray = @();
                $inputStringArray[$i].Split(";") | ForEach {
                      
                      $splitArray +="$_";
                }
                $searchString = $splitArray[0];
                $returnCode = $splitArray[1];
                $allowedNumber = $splitArray[2];
                
                if($newline.Contains($searchString))            
                 {  
                    $countArray +=$countArray[$i]++;
                    if($returnCode -eq 2 -And $countArray[$i] -gt $allowedNumber){$errorPresent=1;}
                    if($returnCode -eq 1 -And $countArray[$i] -gt $allowedNumber){$warningPresent=1;}
                            
                 }
                 
            }
     $count++;    
                         
    } 
                
 $newfile.Close();
 }

 $count--;
 Set-Content -Value $count -Path $countFilePath; 
}
Catch [System.Management.Automation.RuntimeException] {
write-host "$_" 
exit 3
}    

for($i=0; $i -lt $inputStringArray.Length; $i++)
{
  $divideArray = @();
  $inputStringArray[$i].Split(";") | ForEach {
                      
           $divideArray +="$_";
               
   }    
                
   if($countArray[$i] -gt $divideArray[2])
   {
    $outputMessage +="'"+$divideArray[3]+"' comes "+$countArray[$i]+" times;";
   }
   
} 

 if($errorPresent -eq $true)
 {
  write-host  $outputMessage;
  exit 2
 }
 if($warningPresent -eq $true)
 {
  write-host  $outputMessage;
  exit 1
 }
 else
 {
 write-host "OK. There is no error and warning above threshold level."
 exit 0
 }
 