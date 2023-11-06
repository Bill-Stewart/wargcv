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

// Sample Free Pascal (FPC) program for testing the wgetopts unit

// Supported command line options and syntax:
// --alpha
// --bravo
// --bravo=<optional_argument>
// --charlie <required_argument>
// --charlie=<required_argument>
// -d
// -e
// -e <optional_argument>
// -f <required_argument>
// <optional_argument> and <required_argument> can be enclosed in quote
// characters (") if they contain spaces. To embed a quote character in an
// argument, double it within the quoted string. For example:
//   --charlie="required ""test"" argument"
// In the above, option --charlie was specified with the following argument:
//   required "test" argument

program testwgetopts;

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}

uses
  wgetopts;

var
  Args: array[1..4] of TOption;
  Opt: Char;
  I: Integer;

procedure SetupOptions();
begin
  with Args[1] do
  begin
    Name := 'alpha';
    Has_arg := No_Argument;
    Flag := nil;
    Value := #0;
  end;
  with Args[2] do
  begin
    Name := 'bravo';
    Has_arg := Optional_Argument;
    Flag := nil;
    Value := #0;
  end;
  with Args[3] do
  begin
    Name := 'charlie';
    Has_arg := Required_Argument;
    Flag := nil;
    Value := #0;
  end;
  // Final entry needed with empty Name
  with Args[4] do
  begin
    Name := '';
    Has_arg := No_Argument;
    Flag := nil;
    Value := #0;
  end;
end;

begin
  SetupOptions();
  repeat
    Opt := GetLongOpts('de::f:', @Args[1], I);
    case Opt of
      'd':
        WriteLn('Got -d');
      'e':
      begin
        if OptArg = '' then
          WriteLn('Got -e without optional argument')
        else
          WriteLn('Got -e with optional argument: ', OptArg);
      end;
      'f':
        WriteLn('Got -f with required argument: ', OptArg);
      #0:
      begin
        if Args[I].Has_arg = No_Argument then
          WriteLn('Got --', Args[I].Name)
        else if Args[I].Has_arg = Optional_Argument then
        begin
          if OptArg = '' then
            WriteLn('Got --', Args[I].Name, ' without optional argument')
          else
            WriteLn('Got --', Args[I].Name, ' with optional argument: ', OptArg);
        end
        else if Args[I].Has_arg = Required_Argument then
          WriteLn('Got --', Args[I].Name, ' with required argument: ', OptArg);
      end;
    end;
  until Opt = EndOfOptions;
end.
