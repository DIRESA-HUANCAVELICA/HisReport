xcopy mscomct2.ocx %windir%\system32\ /y
cd %windir%\system32\
regsvr32 mscomct2.ocx