#!/usr/bin/env python

__VERSION__ = "0.5.3"

usage = """usage: %prog [options] [FILE]+"""

description = """\
Provides enhanced "tee" function.

- Input is always written unmodified to specified FILEs.
- Input (possibly modified) will be written to standard out.
- Input lines matching the supplied REGEX will be suppressed:
  - For N consecutive matching lines before a non-matching line, the first N-1
    lines will be suppressed, and the last will be kept for context.
  - Suppressed lines are overwritten in-place with subsequent lines (or, with
    --strip, they are suppressed entirely).
- Multiple --regex options will be joined with the logical "OR" operator, "|".
"""
import sys
import re
import os
import logging
from optparse import OptionParser, IndentedHelpFormatter

class Formatter(IndentedHelpFormatter):
    def format_description(self, description):
        if description:
            return description
        else:
            return ""

logger = logging.getLogger()
logger.addHandler(logging.StreamHandler(sys.stdout))

# Holds contents of most recent "status" line.
lastStatusLine = ""

def writeOut(s):
    sys.stdout.write(s)
    sys.stdout.flush()

def putLine(line, regex=""):
    global lastStatusLine
    if regex and re.search(regex, line):
        # This is just for status.
        line = line.rstrip()
        if not options.strip:
            width = max(len(line), len(lastStatusLine))
            writeOut(line.ljust(width) + "\r")
        lastStatusLine = line
    else:
        if lastStatusLine:
            if options.strip:
                writeOut(lastStatusLine)
            writeOut("\n")
        writeOut(line)
        lastStatusLine = ""

def tee(regex="", outNames=[], append=False):
    if append:
        mode = "a"
    else:
        mode = "w"
    outFiles = [open(f, mode) for f in outNames]
    while 1:
        line = sys.stdin.readline()
        if line:
            putLine(line, regex)
            for f in outFiles:
                f.write(line)
                f.flush()
        else:
            break
    if lastStatusLine and not options.strip:
        writeOut(" " * len(lastStatusLine) + "\r")
        #writeOut("\n")
    for f in outFiles:
        f.close()

def main():
    MAKE_REGEX = (
            r"^\s+\[.+\]|"
            r"^make\[\d+\]: (`|Entering |Leaving |Nothing )|"
            r"^make -r |"
            r"^\w+ finished$|"
            r"^(\S*/)?\bgcc\s"
            )

    parser = OptionParser(version="%prog" + __VERSION__,
            formatter=Formatter())
    parser.set_usage(usage)
    parser.set_description(description)
    parser.add_option("-a", "--append", action="store_true", dest="append",
            help="append to given files, do not overwrite")
    parser.add_option("-v", "--verbose", action="store_const", dest="verbose",
            const=logging.DEBUG,
            help="verbose output for debugging")
    parser.add_option("-q", "--quiet", action="store_const", dest="verbose",
            const=logging.WARNING,
            help="suppress informational output")
    parser.add_option("--regex", action="append", dest="regexList",
            default=[],
            metavar="REGEX",
            help="append a 'status' regular expression (e.g., " +
                "'^#.*' for comment lines)")
    parser.add_option("--make", action="append_const", dest="regexList",
            const=MAKE_REGEX,
            help="short for --regex '" + MAKE_REGEX +
                "'; useful for the output of a " +
                "`make` invocation")
    parser.add_option("--strip", action="store_true", dest="strip",
            default=False,
            help="strip out informational output that doesn't " +
                "immediately precede non-informational output, rather " +
                "than display and overwrite it in place")

    global options
    (options, args) = parser.parse_args()

    if options.verbose is None:
        logger.setLevel(logging.INFO)
    else:
        logger.setLevel(options.verbose)

    logger.debug('Finished option processing, options=%r' % options)

    logger.debug('arguments:')

    for arg in args:
        logger.debug('arg: %s' % arg)

    regex = r'|'.join(options.regexList)
    tee(regex, args, append=options.append)

    logger.debug('Finished.')

if __name__ == '__main__':
    main()

