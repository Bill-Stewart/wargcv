# wargcvlib.dll - Windows DLL for Splitting a Command Line into Arguments

- [wargcvlib.dll - Windows DLL for Splitting a Command Line into Arguments](#wargcvlibdll---windows-dll-for-splitting-a-command-line-into-arguments)
  - [Copyright and Author](#copyright-and-author)
  - [License](#license)
  - [Overview](#overview)
  - [Reference](#reference)
    - [Command Line Parsing Rules](#command-line-parsing-rules)
    - [PowerShell Command Line Quoting](#powershell-command-line-quoting)
    - [CommandLineToArgv](#commandlinetoargv)
      - [Syntax](#syntax)
      - [Parameters](#parameters)
      - [Return Value](#return-value)
      - [Remarks](#remarks)
    - [GetCommandTail](#getcommandtail)
      - [Syntax](#syntax-1)
      - [Parameters](#parameters-1)
      - [Return Value](#return-value-1)
      - [Remarks](#remarks-1)
  - [Examples](#examples)

## Copyright and Author

Copyright (C) 2023 by Bill Stewart (bstewart at iname.com)

## License

**wargcvlib.dll** is covered by the GNU Lesser Public License (LGPL). See the file `LICENSE` for details.

## Overview

**wargcvlib.dll** allows a Windows program to split its command line into arguments. It provides the following functions:

| Function              | Description
| --------              | -----------
| **CommandLineToArgv** | Parses a command line string and returns an array of pointers to the command line arguments and the number of arguments
| **GetCommandTail**    | Returns the command line string starting at a specified argument number

The **CommandLineToArgv** function in **argcvwlib.dll** works the same as the **CommandLineToArgvW** Windows API function, with one important difference: Backslash characters (`\`) are not treated specially. Instead, a pair of quote characters (i.e., `""`) are interpreted as a single quote character within a quoted string. (This parsing rule is simpler and more straightforward than the parsing rules used by the Windows API function.)

The **GetCommandTail** function returns the unparsed command line string starting at a specified argument number. This function is useful for programs that need "stop parsing" functionality (for example, to pass along a partial command line to another program without any further parsing).

## Reference

This section describes the argument parsing rules and functions available in **wargcvlib.dll**.

### Command Line Parsing Rules

Command line arguments are delimited by whitespace (spaces or tabs). Whitespace can be included in an argument by enclosing the argument in quote characters (`"`). To include a quote character in an argument, double the quoted character (i.e., `""`) within the quoted string. Quote marks that enclose arguments containing whitespace are not part of the argument. See the following table for examples:

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

### CommandLineToArgv

Parses a command line string and returns an array of pointers to the command line arguments and a count of the arguments.

#### Syntax

C/C++:

`LPWSTR* CommandLineToArgv(LPCWSTR lpCmdLine, int *pNumArgs);`

Pascal:

`function CommandLineToArgv(lpCmdLine: LPCWSTR; pNumArgs: PINT): PLPWSTR;`

#### Parameters

`lpCmdLine` - Pointer to a null-terminated Unicode string that contains the full command line. If this parameter is an empty string, the function returns the full path and filename of the current module file (usually, the curent executable file).

`pNumArgs` - Pointer to an integer that receives the number of array elements returned.

#### Return Value

The function returns a pointer to an array of null-terminated strings. Each string in the array contains a command line argument.

If the function fails, the return value is a null pointer (`NULL` in C/C++, `nil` in Pascal).

#### Remarks

The address returned by **CommandLineToArgv** is the address of the first element in an array of null-terminated strings; the number of pointers in this array is returned in `pNumArgs`. Each pointer to a null-terminated string represents an individual argument found on the command line.

**CommandLineToArgv** allocates a block of contiguous memory for pointers to the argument strings and for the argument strings themselves. The calling application must free this memory when it is no longer needed. Use a single call to the **GlobalFree** function to free the memory.

To parse the command line for the current program, use the **GetCommandLineW** Windows API function for the `lpCmdLine` parameter.

The function accepts command lines that contain a program name; the program name can optionally be enclosed in quote characters (`"`). Command line arguments are delimited by whitespace (spaces or tabs). To include whitespace in an argument, enclose the argument within quote characters. To include a quote character in an argument, double the quote character within the quoted string. For arguments enclosed within quote characters, the quote characters are not included as a part of the argument.

Unlike the Windows **CommandLineToArgvW** API function, there is no special interpretation for backslash (`\`) characters. 

If the command line string starts with any amount of whitespace, the function considers the first argument to be an empty string. The function ignores excess whitespace at the end of the command line string.

### GetCommandTail

Returns the unparsed remainder of a command line string starting at a specified argument.

#### Syntax

C/C++:

`LPWSTR GetCommandTail(LPCWSTR lpCmdLine; StartArg: int);`

Pascal:

`function GetCommandTail(lpCmdLine: LPCWSTR; StartArg: PINT): LPWSTR;`

#### Parameters

`lpCmdLine` - Pointer to a null-terminated Unicode string that contains the full command line.

`StartArg` - Returns the unparsed portion of the command line specified in `lpCmdLine` starting at this argument. This parameter must be 1 or greater.

#### Return Value

The function returns a pointer to the unparsed portion of the command line, starting with the argument number specified by `StartArg`.

#### Remarks

This function is useful for programs that need "stop parsing" functionality (for example, to pass along a partial command line to another program without any further parsing).

To return an unparsed portion of the current program's command line, use the **GetCommandLineW** Windows API function for the `lpCmdLine` parameter.

For example, consider the following command line:

    myapp.exe "arg 1" "test ""quote"" arg" arg3 "arg 4"

The following table lists the results from calling the **GetCommandTail** function:

| Function Call                          | Return Value
| -------------                          | ------------
| `GetCommandTail(GetCommandLineW(), 2)` | `"test ""quote"" arg" arg3 "arg 4"`
| `GetCommandTail(GetCommandLineW(), 3)` | `arg3 "arg 4"`

## Examples

The following table lists sample programs that demonstrate how to use the functions from `wargcvlib.dll`:

| File            | Description
| ----------      | -----------
| `cstestdll.cs`  | C# sample
| `fpctestdll.pp` | Free Pascal (FPC) sample
