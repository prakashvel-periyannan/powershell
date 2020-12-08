#
#PURPOSE        :   Read the INI File , Copy the Folder to a Different Repro and Checkin.
#
#DATE           :   8-DEC-2020 
#AUTHOR         :   prakashvel.periyannan@gmail.com
#LICENSE        :   MIT License
#REFERENCES     :   https://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
#               :   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/copy-item?view=powershell-7.1

#DECLARATION
$FOLDER_TO_BE_COPIED_COLLECTION    = @()
$FILE_TO_BE_COPIED_COLLECTION      = @()

#INI PATH
$INI_Path = "config.ini"

Function Get-IniContent {  
    <#  
    .Synopsis  
        Gets the content of an INI file  
          
    .Description  
        Gets the content of an INI file and returns it as a hashtable  
          
    .Notes  
        Author        : Oliver Lipkau <oliver@lipkau.net>  
        Blog        : http://oliver.lipkau.net/blog/  
        Source        : https://github.com/lipkau/PsIni 
                      http://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91 
        Version        : 1.0 - 2010/03/12 - Initial release  
                      1.1 - 2014/12/11 - Typo (Thx SLDR) 
                                         Typo (Thx Dave Stiff) 
          
        #Requires -Version 2.0  
          
    .Inputs  
        System.String  
          
    .Outputs  
        System.Collections.Hashtable  
          
    .Parameter FilePath  
        Specifies the path to the input file.  
          
    .Example  
        $FileContent = Get-IniContent "C:\myinifile.ini"  
        -----------  
        Description  
        Saves the content of the c:\myinifile.ini in a hashtable called $FileContent  
      
    .Example  
        $inifilepath | $FileContent = Get-IniContent  
        -----------  
        Description  
        Gets the content of the ini file passed through the pipe into a hashtable called $FileContent  
      
    .Example  
        C:\PS>$FileContent = Get-IniContent "c:\settings.ini"  
        C:\PS>$FileContent["Section"]["Key"]  
        -----------  
        Description  
        Returns the key "Key" of the section "Section" from the C:\settings.ini file  
          
    .Link  
        Out-IniFile  
    #>  
      
    [CmdletBinding()]  
    Param(  
        [ValidateNotNullOrEmpty()]  
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]  
        [Parameter(ValueFromPipeline=$True,Mandatory=$True)]  
        [string]$FilePath  
    )  
      
    Begin  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"}  
          
    Process  
    {  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath"  
              
        $ini = @{}  
        switch -regex -file $FilePath  
        {  
            "^\[(.+)\]$" # Section  
            {  
                $section = $matches[1]  
                $ini[$section] = @{}  
                $CommentCount = 0  
            }  
            "^(;.*)$" # Comment  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $value = $matches[1]  
                $CommentCount = $CommentCount + 1  
                $name = "Comment" + $CommentCount  
                $ini[$section][$name] = $value  
            }   
            "(.+?)\s*=\s*(.*)" # Key  
            {  
                if (!($section))  
                {  
                    $section = "No-Section"  
                    $ini[$section] = @{}  
                }  
                $name,$value = $matches[1..2]  
                $ini[$section][$name] = $value  
            }  
        }  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $FilePath"  
        Return $ini  
    }  
          
    End  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}  
} 

#Get the INI Content into Variable.
$INIFile = Get-IniContent $INI_Path

#List And add all the Keys Under Each Section.
$INIFile["FOLDER_TO_COPY"].Keys
$FOLDER_TO_BE_COPIED_COLLECTION += $INIFile["FOLDER_TO_COPY"].Keys     #Folder


#List and add all the Keys Under Each Section. 
$INIFile["FILE_TO_COPY"].Keys
$FILE_TO_BE_COPIED_COLLECTION   += $INIFile["FILE_TO_COPY"].Keys       #File

Write-Host "DEBUG: FOLDERS_TO_BE_COPIED:" ,$FOLDER_TO_BE_COPIED.count 
Write-Host "DEBUG: FILES_TO_BE_COPIED  :" ,$FILE_TO_BE_COPIED.count 

# Iterate with all the Values under the Section Folder to be copied.
foreach ($Folder in $FOLDER_TO_BE_COPIED_COLLECTION) {
        $INIFile["FOLDER_TO_COPY"][$Folder]
        #Example 2: Copy directory contents to an existing directory
        #Copy-Item -Path "C:\Logfiles\*" -Destination "C:\Drawings" -Recurse
}

# Iterate with all the Values under the Section Files to be copied.
foreach ($File in $FILE_TO_BE_COPIED_COLLECTION) {
        $INIFile["FILE_TO_COPY"][$File]
        #Example 1: Copy a file to the specified directory
        #Copy-Item "C:\Wabash\Logfiles\mar1604.log.txt" -Destination "C:\Presentation"
}
