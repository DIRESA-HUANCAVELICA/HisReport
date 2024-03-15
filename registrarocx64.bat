xcopy mscomct2.ocx %windir%\syswow64\ /y
cd %windir%\syswow64\\
regsvr32 mscomct2.ocx