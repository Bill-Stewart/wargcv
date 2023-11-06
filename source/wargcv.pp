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

{ OVERVIEW

  wargcv is a Free Pascal (FPC) unit that implements Unicode argv/ParamStr for
  the Windows platform.

  Whitespace (spaces and tabs) separate the arguments on a command line. To
  include whitespace within an argument, enclose the argument in quote
  characters ("). The quote characters themselves are not included in the
  argument. A quote character can be included in an argument by doubling it
  within a quoted string. For example,
      "Arg ""test"" string"
  is a single argument containing the following string:
      Arg "test" string

  The argc and argv variables should be treated as read-only.


  VARIABLES

  argc - Integer representing the count of arguments on the command line. The
  first argument on a command line is always a command name.

  argv - Pointer to an array of null-terminated strings, each representing an
  argument on the command line. argv[0] points to the command name, argv[1]
  points to the first command line argument, and so forth. Valid array indices
  are 0 through argc - 1. Accessing an index outside of this range will result
  in a runtime error.


  FUNCTIONS

  ParamCount - Returns the number of command line arguments. If there are no
  arguments, ParamCount returns 0.

  ParamStr(N: Integer) - Returns the Nth command-line argument from the command
  line as a string. If N = 0, the function returns the current module's full
  path and file name (usually, this is the full path and filename of the
  currently running executable). If N > ParamCount, the function returns an
  empty string.

  GetCommandTail(lpCmdLine: PChar; StartArg: Integer) - returns a pointer to
  the unparsed command line starting at the specified argument.

}

unit wargcv;

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}

interface

type
  PPChar = ^PChar;

var
  argc: Integer;
  argv: PPChar;

function GetCommandTail(lpCmdLine: PChar; StartArg: Integer): PChar;

function ParamCount(): Integer;

function ParamStr(const N: Integer): string;

implementation

uses
  Windows;

var
  FullModuleFileName: string;

{$UNDEF DLL}
{$INCLUDE 'wargcv.inc'}

function ParamCount(): Integer;
begin
  result := argc - 1;
end;

function ParamStr(const N: Integer): string;
begin
  result := '';
  if N = 0 then
  begin
    if FullModuleFileName = '' then
      FullModuleFileName := GetFullModuleFileName();
    result := FullModuleFileName;
    exit;
  end;
  if N > argc then
    exit;
  result := argv[N];
end;

procedure Init();
begin
  argv := CommandLineToArgv(GetCommandLineW(), @argc);
  FullModuleFileName := '';
end;

procedure Done();
begin
  if Assigned(argv) then
    GlobalFree(HGLOBAL(argv));
end;

initialization

  Init();

finalization

  Done();

end.
