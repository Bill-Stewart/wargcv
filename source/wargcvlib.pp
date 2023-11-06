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

  wargcvlib.dll is a Windows DLL that provides a simple way to split the
  Unicode command line string into separated arguments.

  Whitespace (spaces and tabs) separate the arguments on a command line. To
  include whitespace within an argument, enclose the argument in quote
  characters ("). The quote characters themselves are not included in the
  argument. A quote character can be included in an argument by doubling it
  within a quoted string. For example,
      "Arg ""test"" string"
  is a single argument containing the following string:
      Arg "test" string


  EXPORTED FUNCTIONS

  CommandLineToArgv - Workalike to CommandLineToArgvW function in shell32.dll,
  with one important distinction: Backslashes are not treated specially. A
  quote character (") can be in an argument by doubling it within an existing
  quoted argument. For example, the quoted argument
      "a ""b"" c"
  is returned as
      a "b" c
  The removal of special backslash rules simplifies quoting and reduces
  confusion.

  GetCommandTail - Returns a pointer to the "raw" command line string starting
  at a specified argument number. Uses the same quoting rules as
  CommandLineToArgv. For example, consider the following command line string:
      progname "Arg 1" "Arg 2" Arg3
  If you specify StartArg = 2, the function returns a pointer to the following
  string:
      "Arg 2" Arg 3
  This is useful in cases where you want to implement "stop parsing"
  functionality and want a pointer to only part of the command line, starting
  at a particular argument number.

}

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}
{$R *.res}

library wargcvlib;

uses
  Windows;

{$DEFINE DLL}
{$INCLUDE 'wargcv.inc'}

exports
  CommandLineToArgv,
  GetCommandTail;

end.
