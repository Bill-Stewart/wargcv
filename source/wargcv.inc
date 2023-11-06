{ Copyright (C) 2023 by Bill Stewart (bstewart at iname.com)

  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU Lesser General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option) any
  later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Lesser Public License for more
  details.

  You should have received a copy of the GNU Lesser General Public License
  along with this program. If not, see https://www.gnu.org/licenses/.

}

// Used for ParamStr(0) and CommandLinetoArgv with an empty command line
function GetFullModuleFileName(): string;
const
  MAX_CHARS = 32768;
var
  NumChars, BufSize, CharsCopied: DWORD;
  pName: LPWSTR;
begin
  result := '';
  NumChars := 512;
  repeat
    BufSize := NumChars * SizeOf(Char);
    pName := LPWSTR(LocalAlloc(GMEM_FIXED,  // UINT   uFlags
      BufSize));                            // SIZE_T uBytes
    if not Assigned(pName) then
      exit;
    CharsCopied := GetModuleFileNameW(0,  // HMODULE hModule
      pName,                              // LPWSTR  lpFilename
      NumChars);                          // DWORD   nSize
    if (CharsCopied < NumChars) and (CharsCopied <= MAX_CHARS) then
      result := string(pName)
    else
      NumChars := NumChars * 2;
    LocalFree(HLOCAL(pName));  // HLOCAL hMem
  until (CharsCopied >= MAX_CHARS) or (result <> '');
end;

// Workalike to CommandLineToArgvW function in shell32.dll, with one
// important distinction: Backslashes are not treated specially. A quote
// character (") can be in an argument by doubling it within an existing quoted
// argument. For example, the quoted argument
//     "a ""b"" c"
// is returned as
//     a "b" c
// The removal of special backslash rules simplifies quoting and reduces
// confusion.
// Special thanks to the Wine maintainers for their published version of the
// CommandLineToArgvW API function. This function uses the same basic technique
// (except for the special backslash handling).
function CommandLineToArgv(lpCmdLine: LPCWSTR; pNumArgs: PINT): PLPWSTR; {$IFDEF DLL} stdcall; {$ENDIF}
var
  FullModuleFileName: string;
  Offset, CmdLen, BufSize, NumArgs, QCount: Integer;
  pC, pD: PChar;
  argv: PLPWSTR;
begin
  result := nil;

  if (not Assigned(lpCmdLine)) or (Length(lpCmdLine) = 0) then
  begin
    // Return full path and filename of current module
    FullModuleFileName := GetFullModuleFileName();
    if FullModuleFileName = '' then
      exit;
    Offset := SizeOf(LPWSTR) * 2;
    CmdLen := (Length(FullModuleFileName) + 1) * SizeOf(Char);
    BufSize := Offset + CmdLen;
    argv := PLPWSTR(GlobalAlloc(GMEM_FIXED,  // UINT   uFlags
      BufSize));                             // SIZE_T dwBytes
    if not Assigned(argv) then
      exit;
    Move(FullModuleFileName[1], (argv + 2)^, CmdLen);
    argv[0] := PChar(argv + 2);
    argv[1] := nil;
    pNumArgs^ := 1;
    result := argv;
    exit;
  end;

  // First, count the arguments; first arg is command name
  NumArgs := 1;
  pC := lpCmdLine;
  if pC^ = '"' then
  begin
    // Command name ends at next quote, no matter what
    Inc(pC);
    while pC^ <> #0 do
    begin
      Inc(pC);
      if pC^ = '"' then
      begin
        Inc(pC);
        break;
      end;
    end;
  end
  else
  begin
    // Command name ends at next whitespace, no matter what
    while (pC^ <> #0) and (pC^ <> ' ') and (pC^ <> #9) do
      Inc(pC);
  end;
  // Skip to first command-line argument, if any
  while (pC^ = ' ') or (pC^ = #9) do
    Inc(pC);
  if pC^ <> #0 then
    Inc(NumArgs);
  // Count remaining arguments
  QCount := 0;
  while pC^ <> #0 do
  begin
    if ((pC^ = ' ') or (pC^ = #9)) and (QCount = 0) then
    begin
      while (pC^ = ' ') or (pC^ = #9) do
        Inc(pC);
      if pC^ <> #0 then
        Inc(NumArgs);
    end
    else if pC^ = '"' then
    begin
      Inc(QCount);
      Inc(pC);
      // count consecutive quotes
      while pC^ = '"' do
      begin
        Inc(QCount);
        Inc(pC);
      end;
      QCount := QCount mod 2;
    end
    else
      Inc(pC);
  end;

  // Allocate and initialize buffer
  Offset := (NumArgs + 1) * SizeOf(LPWSTR);
  CmdLen := (Length(lpCmdLine) + 1) * SizeOf(Char);
  BufSize := OffSet + CmdLen;
  argv := PLPWSTR(GlobalAlloc(GMEM_FIXED,  // UINT   uFlags
    BufSize));                             // SIZE_T dwBytes
  if not Assigned(argv) then
    exit;
  Move(lpCmdLine^, (argv + NumArgs + 1)^, CmdLen);

  // Split the arguments
  pD := PChar(argv + NumArgs + 1);
  argv[0] := pD;
  NumArgs := 1;
  if pD^ = '"' then
  begin
    // Command name ends at next quote, no matter what
    pC := pD + 1;
    while pC^ <> #0 do
    begin
      if pC^ = '"' then
      begin
        Inc(pC);
        break;
      end;
      pD^ := pC^;
      Inc(pD);
      Inc(pC);
    end;
  end
  else
  begin
    // Command name ends at next whitespace, no matter what
    while (pD^ <> #0) and (pD^ <> ' ') and (pD^ <> #9) do
      Inc(pD);
    pC := pD;
    if pC^ <> #0 then
      Inc(pC);
  end;
  // Close command name
  pD^ := #0;
  Inc(pD);
  // Skip to first argument
  while (pC^ = ' ') or (pC^ = #9) do
    Inc(pC);
  // No subsequent arguments; all done
  if pC^ = #0 then
  begin
    argv[NumArgs] := nil;
    pNumArgs^ := NumArgs;
    result := argv;
    exit;
  end;

  // Split remaining arguments
  pD := pC;
  argv[NumArgs] := pD;
  Inc(NumArgs);
  QCount := 0;
  while pC^ <> #0 do
  begin
    if ((pC^ = ' ') or (pC^ = #9)) and (QCount = 0) then
    begin
      // Close argument
      pD^ := #0;
      Inc(pD);
      repeat
        Inc(pC);
      until not ((pC^ = ' ') or (pC^ = #9));
      if pC^ <> #0 then
      begin
        argv[NumArgs] := pD;
        Inc(NumArgs);
      end;
    end
    else if pC^ = '"' then
    begin
      Inc(QCount);
      Inc(pC);
      // Count consecutive quotes
      while pC^ = '"' do
      begin
        Inc(QCount);
        if QCount = 3 then
        begin
          pD^ := '"';
          Inc(pD);
          QCount := 1;
        end;
        Inc(pC);
      end;
      if QCount = 2 then
        QCount := 0;
    end
    else
    begin
      pD^ := pC^;
      Inc(pD);
      Inc(pC);
    end;
  end;
  pD^ := #0;
  argv[NumArgs] := nil;
  pNumArgs^ := NumArgs;
  result := argv;
end;

// This function returns a pointer to the unparsed command line string starting
// at a specified argument number. Uses the same quoting rules as
// CommandLineToArgv. For example, consider the following command line string:
//     progname "Arg 1" "Arg 2" Arg3
// If you specify StartArg = 2, the function returns a pointer to the following
// string:
//     "Arg 2" Arg 3
// This is useful in cases where you want to implement "stop parsing"
// functionality and want a pointer to only part of the command line, starting
// at a particular argument number.
function GetCommandTail(lpCmdLine: LPCWSTR; StartArg: Integer): LPWSTR; {$IFDEF DLL} stdcall; {$ENDIF}
var
  pC: PChar;
  NumArgs, QCount: Integer;
begin
  result := nil;
  if ((not Assigned(lpCmdLine)) or (Length(lpCmdLine) = 0)) or (StartArg < 1) then
    exit;
  // First arg is command name
  NumArgs := 1;
  pC := lpCmdLine;
  if pC^ = '"' then
  begin
    // Command name ends at next quote, no matter what
    Inc(pC);
    while pC^ <> #0 do
    begin
      Inc(pC);
      if pC^ = '"' then
      begin
        Inc(pC);
        break;
      end;
    end;
  end
  else
  begin
    // Command name ends at next whitespace, no matter what
    while (pC^ <> #0) and (pC^ <> ' ') and (pC^ <> #9) do
      Inc(pC);
  end;
  // Skip to first command-line argument, if any
  while (pC^ = ' ') or (pC^ = #9) do
    Inc(pC);
  if StartArg = 1 then
  begin
    // Return pointer to entire command line tail after command name
    result := pC;
    exit;
  end;
  if pC^ <> #0 then
    Inc(NumArgs);
  // Iterate through rest of command line
  QCount := 0;
  while pC^ <> #0 do
  begin
    if StartArg = NumArgs - 1 then
    begin
      // Found it
      result := pC;
      break;
    end;
    if ((pC^ = ' ') or (pC^ = #9)) and (QCount = 0) then
    begin
      while (pC^ = ' ') or (pC^ = #9) do
        Inc(pC);
      if pC^ <> #0 then
        Inc(NumArgs);
    end
    else if pC^ = '"' then
    begin
      Inc(QCount);
      Inc(pC);
      // Count consecutive quotes
      while pC^ = '"' do
      begin
        Inc(QCount);
        Inc(pC);
      end;
      QCount := QCount mod 2;
    end
    else
      Inc(pC);
  end;
end;
