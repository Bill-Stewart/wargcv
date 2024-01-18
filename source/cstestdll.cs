/* Copyright (C) 2023-2024 by Bill Stewart (bstewart at iname.com)

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU Lesser General Public License as published by the
   Free Software Foundation; either version 3 of the License, or (at your
   option) any later version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Lesser Public License
   for more details.

   You should have received a copy of the GNU Lesser General Public License
   along with this program. If not, see https://www.gnu.org/licenses/.

*/

// C# sample program demonstrating use of GetCommandLine Windows API
// and the CommandLineToArgv and GetCommandTail functions from wargcv.dll

using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

class cstestdll {
  [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
  static extern IntPtr GetCommandLineW();

  [DllImport("wargcvlib.dll", CharSet = CharSet.Unicode, SetLastError = true)]
  static extern IntPtr CommandLineToArgv(string lpCmdLine, out int pNumArgs);

  [DllImport("wargcvlib.dll", CharSet = CharSet.Unicode, SetLastError = true)]
  static extern IntPtr GetCommandTail(string lpCmdLine, int StartArg);

  static string[] SplitCommandLine(string cmdline) {
    int argc = 0;
    IntPtr argv = CommandLineToArgv(cmdline, out argc);
    if (argv == IntPtr.Zero)
      throw new Win32Exception();
    try {
      string[] args = new string[argc];
      for (int i = 0; i < args.Length; i++) {
        IntPtr arg = Marshal.ReadIntPtr(argv, i * IntPtr.Size);
        args[i] = Marshal.PtrToStringAuto(arg);
      }
      return args;
    }
    finally {
      Marshal.FreeHGlobal(argv);
    }
  }

  static void Main() {
    string cmdline = Marshal.PtrToStringAuto(GetCommandLineW());

    string[] args = SplitCommandLine(cmdline);
    for (int i = 0; i < args.Length; i++) {
      Console.WriteLine(string.Format("{0} - [{1}]", i, args[i]));
    }

    int n = 2;
    string tail = Marshal.PtrToStringAuto(GetCommandTail(cmdline, n));
    Console.WriteLine(string.Format("Unparsed command line starting at arg {0}: {1}", n, tail));
  }
}
