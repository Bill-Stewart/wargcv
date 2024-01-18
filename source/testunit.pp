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

program testunit;

// Sample Windows program for testing the wargcv unit

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}

// With {$MODESWITCH UNICODESTRINGS}, the following apply:
//   type
//     string = UnicodeString;
//     PChar = PWideChar;
// In addition to the above, when using the wargcv unit:
//   type
//     PPChar = ^PChar;  // i.e., PPChar = PPWideChar
// (The added PPChar type in wargcv shouldn't be needed past FPC 3.2.2)

uses
  Windows,
  wargcv;

var
  I, C: Integer;
  Tail: string;

begin
  WriteLn('argc = ', argc);
  for I := 0 to argc - 1 do
    WriteLn('argv[', I, '] - [', string(argv[I]), ']');

  WriteLn();
  C := ParamCount();
  WriteLn('ParamCount() returned ', C);
  for I := 0 to C do
    WriteLn('ParamStr(', I, ') - [', ParamStr(I), ']');

  WriteLn();
  I := 2;
  Tail := string(GetCommandTail(GetCommandLineW(), I));
  WriteLn('Unparsed command line starting at arg ', I, ': ', Tail);
end.
