# wgetopts - FPC/Windows/Unicode Structured Command Line Parsing Unit

- [wgetopts - FPC/Windows/Unicode Structured Command Line Parsing Unit](#wgetopts---fpcwindowsunicode-structured-command-line-parsing-unit)
  - [Copyright and Author](#copyright-and-author)
  - [License](#license)
  - [Description](#description)
  - [Example](#example)

## Copyright and Author

The Free Pascal (FPC) `getopts` unit was written by members of the FPC team. The `wgetopts` unit is a modification of `getopts` for the Windows platform to support Unicode command line arguments.

## License

See the files `COPYING.FPC` and `LICENSE` for details.

## Description

The FPC `getopts` unit provides a means for access a program's command line arguments in a structured way. As of FPC 3.2.2, the FPC `getopts` unit doesn't support Unicode command line arguments on the Windows platform. The `wgetopts` unit is a drop-in replacement for `getopts` that uses the `wargcv` unit to support Unicode command line parsing.

The FPC runtime library documentation describes the use of the `getopts` unit.

## Example

See `testwgetopts.pp` for an example of how to use the `wgetopts` unit.
