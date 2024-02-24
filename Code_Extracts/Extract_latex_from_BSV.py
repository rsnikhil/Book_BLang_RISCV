#!/usr/bin/env  python3

usage_line = (
    "Usage:    {0}    <root-dir-for-BSV-sources>    <dest_dir>\n")

help_lines = (
    "  Recursively traverses all files in <root-dir> and its subdirectories.\n"
    "  For each source file with '.bsv' extension, locates lines containing:\n"
    "      \\blatex{tag},\n"
    "      \\elatex{tag} or \\elatex{...tag},\n"
    "  and outputs all intervening lines (trimming leading and trailing blank lines)\n"
    "  to a file named 'tag.tex' in <dest_dir>,\n"
    "  bracketed by \begin{Verbatim} and \end{Verbatim} lines.\n"
    "  FOr \\elatex{...tag} appends a '... more ...' line at the end."
)

import sys
import os
import stat
import fileinput

# ================================================================

def main (argv = None):
    if ((len (argv) <= 1) or
        (argv [1] == '-h') or (argv [1] == '--help') or
        (len (argv) != 3)):
        sys.stdout.write (usage_line.format (argv [0]))
        sys.stdout.write ("\n")
        sys.stdout.write (help_lines)
        sys.stdout.write ("\n")
        return 0

    path      = os.path.abspath (os.path.normpath (argv [1]))
    dest_path = os.path.abspath (os.path.normpath (argv [2]))
    max_level = 3
    traverse (path, max_level, 0, path, dest_path)

def traverse (orig_path, max_level, level, path, dest_path):
    st = os.stat (path)
    is_dir = stat.S_ISDIR (st.st_mode)
    is_reg = stat.S_ISREG (st.st_mode)
    do_foreachfile_function (orig_path, level, is_dir, is_reg, path, dest_path)
    if is_dir and level < max_level:
        with os.scandir (path) as it:
            for entry in it:
                traverse (orig_path, max_level, level + 1, path + "/" + entry.name, dest_path)
    return 0

# ================================================================
# This function is applied to every path in the
# recursive traversal

def do_foreachfile_function (orig_path, level, is_dir, is_reg, path, dest_path):
    prefix = ""
    for j in range (level): prefix = "  " + prefix

    # directories
    if is_dir:
        # print ("%s%d dir %s" % (prefix, level, path))
        pass

    # regular files
    elif is_reg:
        dirname  = os.path.dirname (path)
        basename = os.path.basename (path)
        # print ("%s%d %s" % (prefix, level, path))
        do_regular_file_function (orig_path, level, dirname, basename, dest_path)

    # other files
    else:
        print ("%s%d Unknown file type: %s" % (prefix, level, os.path.basename (path)))

# ================================================================
# Process each text file, extracting lines between \blatex and \elatex tags

def do_regular_file_function (orig_path, level, dirname, basename, dest_path):
    # Ignore file if filename does not end in ".bsv" or ".bsvi" (BSV sources)
    if not (basename.endswith (".bsv") or basename.endswith (".bsvi")):
        return

    filename     = os.path.join (dirname, basename)
    rel_filename = filename.replace (orig_path, "", 1).replace ("_", "\\_")
    if rel_filename.startswith ("/"):
        rel_filename = rel_filename [1:]

    # For debugging only
    prefix = ""
    for j in range (level): prefix = "  " + prefix
    # sys.stdout.write ("{0}{1} ACTION:    {2}\n".format (prefix, level, filename))

    linenum = 0
    extracting = False
    for line in fileinput.input (filename):
        linenum = linenum + 1
        if not extracting:
            tag_begin = find_tag (filename, linenum, line, "\\blatex")
            if tag_begin != None:
                fd = open (os.path.join (dest_path, tag_begin + ".tex"), 'w')
                header = ("tag {0} from line {1}, file {2}".
                          format (tag_begin, linenum, basename))
                sys.stdout.write ("Extracting: {0}\n".format (header))
                fd.write ("% {0}\n".format (header))
                extracting = True
                state = 0            # still within leading blank lines
                pending_blank_lines = 0
        else:
            tag_end = find_tag (filename, linenum, line, "\\elatex")
            if tag_end != None:
                if (tag_end.startswith ("...")):
                    match_tag = (tag_end [3:] == tag_begin)
                else:
                    match_tag = (tag_end == tag_begin)

                if not match_tag:
                    sys.stdout.write ("WARNING: unmatched begin/end tags: {0} and {1}\n"
                                      .format (tag_begin, tag_end))
                if (tag_end.startswith ("...")):
                    fd.write ("...more...\n")
                fd.write ("\\end{Verbatim}\n")
                fd.write ("}\n")
                fd.close ()
                extracting = False
            else:
                blank = (line == "") or line.isspace()
                if blank:
                    if state == 0:
                        # leading blank line; skip
                        pass
                    else:
                        # possible trailing blank line
                        pending_blank_lines = pending_blank_lines + 1
                else:
                    if state == 0:
                        # First non-blank line
                        state = 1
                        fd.write ("{\\small\n")
                        fd.write ("\\begin{Verbatim}")
                        fd.write ("[frame=single, numbers=left, firstnumber={0}, label={1}]\n"
                                  .format(linenum, rel_filename))
                    for j in range (pending_blank_lines):
                        fd.write ("\n")
                    fd.write (line)
                    pending_blank_lines = 0

    return

def find_tag (filename, linenum, line, tag):
    j = line.find (tag)
    if j == -1: return None
    line1 = line [j + len (tag) : ]
    if not line1.startswith ("{"):
        sys.stdout.write ("WARNING: expecting '{' after {0}; ignoring\n".format (tag))
        sys.stdout.write ("    File {0}, Line num {1}\n".format (filename, linenum))
        sys.stdout.write ("    Line: '{0}'\n".format (line))
        return None
    line2 = line1 [1 : ]
    j     = line2.find ("}")
    if j == -1:
        sys.stdout.write ("WARNING: expecting '{0}' after {1}{2}; ignoring\n".
                          format ("}", tag, "{..."))
        sys.stdout.write ("    File {0}, Line num {1}\n".format (filename, linenum))
        sys.stdout.write ("    Line:{0}".format (line))
        return None
    return line2 [:j]

# ================================================================
# For non-interactive invocations, call main() and use its return value
# as the exit code.
if __name__ == '__main__':
  sys.exit (main (sys.argv))
