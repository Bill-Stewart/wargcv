# wargcv - FPC/Windows/Unicode ParamCount/ParamStr Unit

- [wargcv - FPC/Windows/Unicode ParamCount/ParamStr Unit](#wargcv---fpcwindowsunicode-paramcountparamstr-unit)
  - [Copyright and Author](#copyright-and-author)
  - [License](#license)
  - [FPC Unit Overview](#fpc-unit-overview)
    - [The Unicode Problem](#the-unicode-problem)
    - [The Solution](#the-solution)
  - [Reference](#reference)
    - [Command Line Parsing Rules](#command-line-parsing-rules)
    - [PowerShell Command Line Quoting](#powershell-command-line-quoting)
    - [Variables](#variables)
      - [argc](#argc)
      - [argv](#argv)
    - [Functions](#functions)
      - [ParamCount](#paramcount)
      - [ParamStr](#paramstr)
      - [GetCommandTail](#getcommandtail)
  - [Example](#example)

## Copyright and Author

Copyright (C) 2023 by Bill Stewart (bstewart at iname.com)

## License

**wargcv** is covered by the GNU Lesser Public License (LGPL). See the file `LICENSE` for details.

## FPC Unit Overview

Free Pascal (FPC) provides access to a program's command line using the **ParamStr** function. For example, `ParamStr(2)` returns the program's second command line argument. As with C/C++ programs, you can also access the command line arguments using the **argv** array. The **ParamStr** function is normally preferred in Pascal programs rather than accessing the **argv** array because it's safer (it won't crash the program if you specify a non-existent argument index) and it returns strings rather than character pointers.

### The Unicode Problem

The problem, as of FPC 3.2.2 on the Windows platform, is that command line strings are retrieved using the non-Unicode command line. For typical English characters, this doesn't often cause a noticeable problem because there's a straightforward conversion between the "ANSI" and Unicode representations of characters. However, it can be a problem if you're designing a program that needs access to the Unicode representation of the command line. For example, consider the following program:

    // testprogram.pp
    {$MODE OBJFPC}
    {$H+}

    uses
      Windows;

    begin
      // Does not diplay the string correctly...
      MessageBox(0, PChar(ParamStr(1)), 'Test', MB_OK);
    end.

Now run this program with a Greek word on the command line; e.g.:

    testprogram δείγμα

The message box will display incorrect characters because the **ParamStr** function is reading the non-Unicode version of the command line. This still happens if we specify the Unicode version of the **MessageBox** function (**MessageBoxW**) and cast to `PWideChar` rather than `PChar`:

    // testprogram.pp
    {$MODE OBJFPC}
    {$H+}

    uses
      Windows;

    begin
      // Still does not diplay the string correctly...
      MessageBoxW(0, PWideChar(ParamStr(1)), 'Test', MB_OK);
    end.

The root of the problem is that FPC's **ParamStr** function uses the non-Unicode copy of the command line.

### The Solution

To remedy this, add the **wargcv** unit to the program's `uses` clause, as follows:

    // testprogram.pp
    {$MODE OBJFPC}
    {$H+}

    uses
      Windows,
      wargcv;

    begin
      // Now it works!
      MessageBoxW(0, PWideChar(ParamStr(1)), 'Test', MB_OK);
    end.

You can even enable the **UNICODESTRINGS** mode in FPC and cast to `PChar`:

    // testprogram.pp
    {$MODE OBJFPC}
    {$MODESWITCH UNICODESTRINGS}

    uses
      Windows,
      wargcv;

    begin
      // Still works! In UNICODESTRINGS mode, PChar = PWideChar
      MessageBoxW(0, PChar(ParamStr(1)), 'Test', MB_OK);
    end.

This works because the **ParamStr** function in the **wargcv** unit reads the Unicode copy of the program's command line. Specifying the **wargcv** unit after Windows in the **uses** declaration ensures the program uses the **ParamStr** function from the **wargcv** unit.

## Reference

This section describes the argument parsing rules, variables, and functions available in the **wargcv** unit.

### Command Line Parsing Rules

Command line arguments are delimited by whitespace (spaces or tabs). Whitespace can be included in an argument by enclosing the argument in quote characters (`"`). To include a quote character in an argument, double the quote character (i.e., `""`) within the quoted string. Quote marks that enclose arguments containing whitespace are not part of the argument. See the following table for examples:

| Command Line        | Program Name | 1st Argument | 2nd Argument
| ------------        | ------------ | ------------ | ------------
| `"abc" d e`         | `abc`        | `d`          | `e`
| `abc "d e" f`       | `abc`        | `d e`        | `f`
| `abc "d ""e"" f" g` | `abc`        | `d "e" f`    | `g`
| `"a b" "c d" ef`    | `a b`        | `c d`        | `ef`

> NOTE: Unlike the Windows **CommandLineToArgvW** API function and the Microsoft C/C++ command line parsing rules, the backslash character (`\`) has no special interpretation.

### PowerShell Command Line Quoting

If you are running a program from the PowerShell command line, keep in mind that PowerShell parses the command line before passing it to your program. This is normally only a problem in the case with embedded quote characters in an argument.

| Argument              | Result    | Reason
| --------              | ------    | ------
| `"a ""b"" c"`         | `a b c`   | `""` evaluated as `"`
| `"a """"b"""" c"`     | `a "b" c` | `""""` evaluated as `""`
| `'a ""b"" c'`         | `a "b" c` | Outer `'` evaluated as `"`
| `'a ''b'' c`          | `a 'b' c` | Inner `''` evaluated as `'`

(In the above table, the **Argument** column refers to an argument specified on the PowerShell command line.)

> NOTE: You can also escape quotes within a quoted string using the backtick (**`**) character.

### Variables

#### argc

The `argc` variable is an `Integer` that contains the count of arguments on the command line and is always at least 1. The command name at the beginning of the command line is numbered 0, the command's first command line argument is numbered 1, and so forth. The number of arguments specified on a program's command line is thus `argc - 1`. The `argc` variable should be treated as read-only.

It is recommended to use the **ParamCount** function (below) rather than the **argc** variable.

#### argv

The `argv` variable is an array of pointers to null-terminated strings (`PPWideChar`), where each string is an individual argument on the command line. The pseudocode to iterate all of the command line arguments is as follows (where `I` is an `Integer` variable):

    for I := 0 to argc - 1 do
      // argv[I] is an individual argument from the command line

The `argv` array is dynamically allocated and automatically disposed, and should be treated as read-only. Accessing an array index higher than `argc - 1` will cause a run-time error and crash the program.

It is recommended to use the **ParamStr** function (below) rather than the `argv` variable.

### Functions

#### ParamCount

Syntax: `function ParamCount(): Integer;`

The **ParamCount** function returns the number of arguments (sometimes also called _parameters_) on the program's command line. If the program was started without any command line parameters, **ParamCount** returns 0.

#### ParamStr

Syntax: `function ParamStr(N: Integer): UnicodeString;`

> NOTE: If FPC's **UNICODESTRINGS** mode is on, `string = UnicodeString`.

The **ParamStr** function returns an argument from the command line as a string by its index. The program's first command line argument is index 1, the second argument is index 2, and so forth. Index 0 is the full path and filename of the current program. Specifying a non-existent argument index returns an empty string.

For example, consider the following command line:

    C:\Apps\myapp.exe "arg 1" "test ""quoted"" arg"

The following table lists the results from calling the **ParamStr** function:

| Function Call | Return Value
| ------------- | ------------
| `ParamStr(0)` | `C:\Apps\myapp.exe`
| `ParamStr(1)` | `arg 1`
| `ParamStr(2)` | `test "quoted" arg`

#### GetCommandTail

Syntax: `function GetCommandTail(lpCmdLine: PWideChar; StartArg: Integer): PWideChar;`

> NOTE: If FPC's **UNICODESTRINGS** mode is on, `PChar  = PWideChar`.

The **GetCommandTail** function returns a pointer to a null terminated string that represents the unparsed remainder of the command line starting at a specified argument. This function is useful for programs that need "stop parsing" functionality (for example, to pass along a partial command line to another program without any further parsing).

Use the **GetCommandLineW** Windows API function for the `lpCmdLine` parameter (i.e., the full command line for the current program).

For example, consider the following command line:

    myapp.exe "arg 1" "test ""quote"" arg" arg3 "arg 4"

The following table lists the results from calling the **GetCommandTail** function:

| Function Call                          | Return Value
| -------------                          | ------------
| `GetCommandTail(GetCommandLineW(), 2)` | `"test ""quote"" arg" arg3 "arg 4"`
| `GetCommandTail(GetCommandLineW(), 3)` | `arg3 "arg 4"`

## Example

See the `testunit.pp` FPC program for an example of how to use the variables and functions in the **wargcv** unit.
