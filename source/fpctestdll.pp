{ Copyright (C) 2023-2024 by Bill Stewart (bstewart at iname.com)

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

program fpctestdll;

// Sample Free Pascal (FPC) program for testing the CommandLineToArgv and
// GetCommandTail functions from wargcv.dll

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}

// When using {$MODESWITCH UNICODESTRINGS}:
//   type
//     PChar = PWideChar;
//     string = UnicodeString;
// ...etc. See FPC docs for more information.

uses
  Windows;

// Notes on below types, affected by {$MODESWITCH UNICODESTRINGS}:
// * 'PPChar = ^PChar' was an omission in FPC that should be fixed later
// * 'TArrayOfString' is a dynamic array of UnicodeStrings

type
  PPChar = ^PChar;
  TArrayOfString = array of string;

function CommandLineToArgv(lpCmdLine: LPCWSTR; pNumArgs: PINT): PLPWSTR;
  stdcall; external 'wargcvlib.dll';

function GetCommandTail(lpCmdLine: LPCWSTR; StartArg: Integer): LPWSTR;
  stdcall; external 'wargcvlib.dll';

function SplitCommandLine(const CmdLine: PChar): TArrayOfString;
var
  argv: PPChar;
  argc, I: Integer;
  Args: TArrayOfString;
begin
  argv := CommandLineToArgv(CmdLine, @argc);
  SetLength(Args, argc);
  for I := 0 to argc - 1 do
    Args[I] := argv[I];
  result := Args;
  GlobalFree(HLOCAL(argv));
end;

var
  CmdLine: PChar;
  Args: TArrayOfString;
  I: Integer;
  Tail: string;

begin
  CmdLine := GetCommandLineW();

  Args := SplitCommandLine(CmdLine);
  for I := 0 to Length(Args) - 1 do
    WriteLn(I, ' - [', Args[I], ']');

  I := 2;
  Tail := string(GetCommandTail(CmdLine, I));
  WriteLn('Unparsed command line starting at arg ', I, ': ', Tail);
end.
